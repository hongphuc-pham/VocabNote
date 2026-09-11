import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_importer.dart';
import 'package:vocabnote/data/backup/backup_tables.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/user_data_repository.dart';

/// Drift-backed [UserDataRepository].
class UserDataRepositoryImpl implements UserDataRepository {
  /// Creates the repository.
  ///
  /// [exportDirectory], [safetyDirectory] and [now] are injectable for tests.
  /// By default exports go to a folder in the OS temporary directory, which
  /// the OS may clear - right for a file whose only job is to be handed to
  /// the share sheet - while safety copies go to app support, which it does
  /// not.
  new(
    this._db, {
    required this._appVersion,
    Future<Directory> Function()? exportDirectory,
    Future<Directory> Function()? safetyDirectory,
    DateTime Function()? now,
  }) : _exportDirectory = exportDirectory ?? _defaultExportDirectory,
       _safetyDirectory = safetyDirectory ?? _defaultSafetyDirectory,
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final String _appVersion;
  final Future<Directory> Function() _exportDirectory;
  final Future<Directory> Function() _safetyDirectory;
  final DateTime Function() _now;

  /// How many safety copies are kept. Each is a full copy of the library; a
  /// few is a way back, a pile is clutter in private storage.
  static const int keptSafetyCopies = 3;

  static Future<Directory> _defaultExportDirectory() async => Directory(
    p.join((await getTemporaryDirectory()).path, 'vocabnote', 'export'),
  );

  static Future<Directory> _defaultSafetyDirectory() async => Directory(
    p.join(
      (await getApplicationSupportDirectory()).path,
      'vocabnote',
      'backups',
    ),
  );

  @override
  AsyncResult<ExportedBackup> exportBackup() => Results.guard(
    () async {
      final now = _now();
      final (:manifest, :bytes) = await _snapshot(now);

      final folder = await _exportDirectory();
      await folder.create(recursive: true);
      // Each export is a full copy of the user's words; a pile of them in a
      // cache folder helps nobody.
      for (final old in await _backupFilesIn(folder)) {
        await old.delete();
      }

      final stamp = DateFormat('yyyyMMdd-HHmm').format(now.toLocal());
      final fileName = 'vocabnote-backup-$stamp.vnb';
      final file = File(p.join(folder.path, fileName));
      await file.writeAsBytes(bytes, flush: true);

      return ExportedBackup(
        path: file.path,
        fileName: fileName,
        manifest: manifest,
      );
    },
    onError: (error, stackTrace) => FileFailure(
      kind: FileFailureKind.io,
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  @override
  AsyncResult<BackupManifest> previewBackup(Uint8List bytes) async =>
      (await _decodeOffTheUiThread(bytes)).map((backup) => backup.manifest);

  @override
  AsyncResult<ImportReport> importBackup(
    Uint8List bytes,
    ImportMode mode,
  ) async {
    // Refused before anything - even the safety copy - is touched.
    final decoded = await _decodeOffTheUiThread(bytes);
    return switch (decoded) {
      Err(:final failure) => Err<ImportReport, AppFailure>(failure),
      Ok(value: final backup) => await Results.guard(
        () => _import(backup, mode),
        onError: (error, stackTrace) => error is FileSystemException
            ? FileFailure(
                kind: FileFailureKind.io,
                cause: error,
                stackTrace: stackTrace,
              )
            : DatabaseFailure(
                operation: 'import backup',
                cause: error,
                stackTrace: stackTrace,
              ),
      ),
    };
  }

  Future<ImportReport> _import(DecodedBackup backup, ImportMode mode) async {
    final importer = BackupImporter(_db);
    switch (mode) {
      case ImportMode.merge:
        return await importer.merge(backup);
      case ImportMode.replace:
        // First, and fatal if it fails: a replace with no way back does not
        // happen (DATABASE.md §5 - "takes a backup first").
        await _writeSafetyCopy();
        return await importer.replace(backup);
    }
  }

  /// The library as one moment, encoded.
  Future<({BackupManifest manifest, Uint8List bytes})> _snapshot(
    DateTime now,
  ) async {
    // One transaction, so the file is a single moment of the library - not
    // words from before a save and notes from after it.
    final tables = await _db.transaction(
      () => readBackupTables(
        (sql) async => <BackupRow>[
          for (final row in await _db.customSelect(sql).get()) row.data,
        ],
      ),
    );
    final manifest = BackupCodec.manifestFor(
      appVersion: _appVersion,
      schemaVersion: AppDatabase.latestSchemaVersion,
      exportedAt: now,
      tables: tables,
    );
    return (
      manifest: manifest,
      bytes: await _encodeOffTheUiThread(manifest, tables),
    );
  }

  /// Writes the library as it is now to the safety folder, keeping only the
  /// newest [keptSafetyCopies].
  Future<void> _writeSafetyCopy() async {
    final now = _now();
    final (:bytes, manifest: _) = await _snapshot(now);

    final folder = await _safetyDirectory();
    await folder.create(recursive: true);
    final stamp = DateFormat('yyyyMMdd-HHmmss').format(now.toLocal());
    await File(p.join(folder.path, 'vocabnote-before-replace-$stamp.vnb'))
        .writeAsBytes(bytes, flush: true);

    // Newest first: the name is the moment, so it sorts as time does.
    final copies = await _backupFilesIn(folder)
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final old in copies.skip(keptSafetyCopies)) {
      await old.delete();
    }
  }

  static Future<List<File>> _backupFilesIn(Directory folder) async => <File>[
    await for (final entity in folder.list())
      if (entity is File && entity.path.endsWith('.vnb')) entity,
  ];

  /// Encodes on another isolate: 5,000 words is megabytes of JSON to encode
  /// and compress, and the export button must not freeze the screen.
  ///
  /// Static on purpose. A closure written inside an instance method can drag
  /// `this` - and with it the open database - into the isolate message, which
  /// cannot be sent.
  static Future<Uint8List> _encodeOffTheUiThread(
    BackupManifest manifest,
    BackupTables tables,
  ) => Isolate.run(() => BackupCodec.encode(manifest, tables));

  /// Decodes on another isolate, for the same reason as encoding.
  ///
  /// Only the problem crosses back on failure: the exception the codec
  /// caught is not guaranteed to be sendable between isolates.
  static Future<AppResult<DecodedBackup>> _decodeOffTheUiThread(
    Uint8List bytes,
  ) => Isolate.run(
    () => BackupCodec.decode(bytes).mapErr<AppFailure>(
      (failure) => failure is InvalidBackupFailure
          ? InvalidBackupFailure(problem: failure.problem)
          : const UnexpectedFailure(),
    ),
  );
}
