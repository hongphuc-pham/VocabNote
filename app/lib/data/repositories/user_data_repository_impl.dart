import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_tables.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/user_data_repository.dart';

/// Drift-backed [UserDataRepository].
class UserDataRepositoryImpl implements UserDataRepository {
  /// Creates the repository.
  ///
  /// [exportDirectory] and [now] are injectable for tests; by default exports
  /// go to a folder in the OS temporary directory, which the OS may clear -
  /// right for a file whose only job is to be handed to the share sheet.
  new(
    this._db, {
    required this._appVersion,
    Future<Directory> Function()? exportDirectory,
    DateTime Function()? now,
  }) : _exportDirectory = exportDirectory ?? _defaultExportDirectory,
       _now = now ?? DateTime.now;

  final AppDatabase _db;
  final String _appVersion;
  final Future<Directory> Function() _exportDirectory;
  final DateTime Function() _now;

  static Future<Directory> _defaultExportDirectory() async => Directory(
    p.join((await getTemporaryDirectory()).path, 'vocabnote', 'export'),
  );

  @override
  AsyncResult<ExportedBackup> exportBackup() => Results.guard(
    () async {
      // One transaction, so the file is a single moment of the library - not
      // words from before a save and notes from after it.
      final tables = await _db.transaction(
        () => readBackupTables(
          (sql) async => <BackupRow>[
            for (final row in await _db.customSelect(sql).get()) row.data,
          ],
        ),
      );
      final now = _now();
      final manifest = BackupCodec.manifestFor(
        appVersion: _appVersion,
        schemaVersion: AppDatabase.latestSchemaVersion,
        exportedAt: now,
        tables: tables,
      );
      final bytes = await _encodeOffTheUiThread(manifest, tables);

      final folder = await _exportDirectory();
      await folder.create(recursive: true);
      await _clearEarlierExports(folder);

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

  /// Removes earlier exports. Each is a full copy of the user's words, and a
  /// pile of them in a cache folder helps nobody.
  static Future<void> _clearEarlierExports(Directory folder) async {
    await for (final entity in folder.list()) {
      if (entity is File && entity.path.endsWith('.vnb')) {
        await entity.delete();
      }
    }
  }
}
