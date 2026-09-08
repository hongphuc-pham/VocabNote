/// Opening the database safely (`docs/DATABASE.md` §3, `ARCHITECTURE.md` §6).
///
/// The single most important promise in this project is that installing a new
/// version adopts the existing file **in place, without data loss**. There is
/// no backend to restore from, so everything here is arranged around never
/// destroying anything:
///
/// * a database written by a **newer** build is refused, not migrated down;
/// * a pending migration takes a **backup first**;
/// * a failed migration **restores the backup** and reports a recoverable
///   failure, so the app can offer *Export my data* rather than starting fresh.
///
/// There is no code path here that deletes the database. There never will be.
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/db/app_database.dart';

/// Where the database and its backups live.
class DatabaseLocation {
  /// Creates a location.
  const new({required this.file, required this.directory});

  /// The database file itself.
  final File file;

  /// The folder holding it and any backups.
  final Directory directory;

  /// The pre-migration backup taken when upgrading away from [version].
  ///
  /// Named after the version being left behind, so a user who upgrades twice
  /// keeps one backup per hop rather than overwriting the useful one.
  File backupFor(int version) =>
      File(p.join(directory.path, 'vocabnote.pre-v$version.bak'));
}

/// What a successful open produced.
class OpenedDatabase {
  /// Creates the result.
  const new({
    required this.database,
    required this.location,
    this.migratedFrom,
    this.backup,
  });

  /// The open database.
  final AppDatabase database;

  /// Where it lives.
  final DatabaseLocation location;

  /// The version found on disk when a migration ran, or null if none did.
  final int? migratedFrom;

  /// The backup taken before that migration, kept until the next one.
  final File? backup;
}

/// Opens the app database, migrating it if needed.
///
/// Never throws and never deletes: every outcome is either an [OpenedDatabase]
/// or an [AppFailure] the recovery screen can act on.
class DatabaseOpener {
  /// Creates an opener.
  ///
  /// [resolveDirectory] and [openRaw] are injectable so tests can drive the
  /// backup and recovery paths against a temporary directory without a real
  /// platform channel.
  new({
    Future<Directory> Function()? resolveDirectory,
    Database Function(String path)? openRaw,
  }) : _resolveDirectory = resolveDirectory ?? getApplicationSupportDirectory,
       _openRaw = openRaw ?? sqlite3.open;

  final Future<Directory> Function() _resolveDirectory;
  final Database Function(String path) _openRaw;

  /// Resolves the database path.
  ///
  /// `getApplicationSupportDirectory()`, never the documents directory: on
  /// iOS the latter is user-visible through Files sharing and invites
  /// accidental deletion (`docs/DATABASE.md` §1).
  Future<DatabaseLocation> resolveLocation() async {
    final support = await _resolveDirectory();
    final directory = Directory(p.join(support.path, 'vocabnote'));
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return DatabaseLocation(
      directory: directory,
      file: File(p.join(directory.path, 'vocabnote.sqlite')),
    );
  }

  /// Reads `PRAGMA user_version` without going through Drift.
  ///
  /// Drift stores the schema version there, but asking Drift for it means
  /// opening the database, which runs the migration - and the whole point is to
  /// decide **before** migrating whether we should. Returns 0 for a file that
  /// does not exist yet, and null if it cannot be read at all.
  int? readOnDiskVersion(File file) {
    if (!file.existsSync()) return 0;
    Database? raw;
    try {
      raw = _openRaw(file.path);
      final result = raw.select('PRAGMA user_version');
      if (result.isEmpty) return null;
      return result.first.values.first as int?;
    } on SqliteException {
      // An unreadable file is not an empty one. Returning null sends the
      // caller down the failure path instead of the "fresh install" path,
      // which is what stops a corrupt file being silently replaced.
      return null;
    } finally {
      raw?.close();
    }
  }

  /// Opens the database, taking a backup first if a migration is pending.
  AsyncResult<OpenedDatabase> open({DatabaseLocation? at}) async {
    final location = at ?? await resolveLocation();
    const expected = AppDatabase.latestSchemaVersion;

    final onDisk = readOnDiskVersion(location.file);
    if (onDisk == null) {
      return Err<OpenedDatabase, AppFailure>(
        FileFailure(kind: FileFailureKind.corrupt, path: location.file.path),
      );
    }

    // Downgrade is not supported, but must not destroy anything
    // (docs/DATABASE.md §3.10): refuse to open and let the user export.
    if (onDisk > expected) {
      return Err<OpenedDatabase, AppFailure>(
        SchemaTooNewFailure(onDiskVersion: onDisk, supportedVersion: expected),
      );
    }

    File? backup;
    if (onDisk > 0 && onDisk < expected) {
      final result = await _takeBackup(location, onDisk);
      if (result.isErr) {
        // A migration we cannot back up is a migration we do not run.
        return Err<OpenedDatabase, AppFailure>(result.failureOrNull!);
      }
      backup = result.valueOrNull;
    }

    final database = AppDatabase(NativeDatabase(location.file));
    try {
      // Opening is lazy; this forces the migration to run now, inside the
      // try, rather than on the first query somewhere up in the UI.
      await database.customSelect('SELECT 1').get();
    } on Object catch (error, stackTrace) {
      await database.close();
      final restored = await _restore(backup, location.file);
      return Err<OpenedDatabase, AppFailure>(
        MigrationFailure(
          fromVersion: onDisk,
          toVersion: expected,
          backupRestored: restored,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }

    return Ok<OpenedDatabase, AppFailure>(
      OpenedDatabase(
        database: database,
        location: location,
        migratedFrom: onDisk > 0 && onDisk < expected ? onDisk : null,
        backup: backup,
      ),
    );
  }

  Future<AppResult<File>> _takeBackup(
    DatabaseLocation location,
    int fromVersion,
  ) async {
    return await Results.guard(
      () async {
        final backup = location.backupFor(fromVersion);
        return await location.file.copy(backup.path);
      },
      onError: (error, stackTrace) => FileFailure(
        kind: FileFailureKind.io,
        path: location.file.path,
        cause: error,
        stackTrace: stackTrace,
      ),
    );
  }

  /// Puts the pre-migration backup back.
  ///
  /// The half-migrated file is overwritten by the copy rather than deleted
  /// first: if the copy itself fails, the user is left with the broken file and
  /// the intact backup, which is recoverable. Deleting first and then failing
  /// would leave them with nothing.
  Future<bool> _restore(File? backup, File target) async {
    if (backup == null || !backup.existsSync()) return false;
    try {
      await backup.copy(target.path);
      return true;
    } on FileSystemException {
      return false;
    }
  }
}
