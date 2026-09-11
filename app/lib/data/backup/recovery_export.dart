/// *Export my data* for a database Drift refused (`docs/DATABASE.md` §3.6,
/// §3.10).
library;

import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_tables.dart';
import 'package:vocabnote/data/backup/export_writer.dart';
import 'package:vocabnote/domain/entities/backup.dart';

/// Reads [database] raw and read-only into a `.vnb` in [exportDirectory].
///
/// The one situation in which Drift is, by definition, unavailable: it
/// refused the file - a schema from a newer build, a migration that failed -
/// and that is exactly when a user most needs their words out. So this uses
/// `package:sqlite3` directly, opens the file **read-only** (nothing here may
/// change it), and writes the same format as any other backup, through the
/// same `readBackupTables`: the file names its SQL columns, so no generated
/// Drift code is needed to read it.
///
/// A table the file's schema never had comes out empty rather than failing
/// the export; a file that is not a database at all is a failure.
AsyncResult<ExportedBackup> exportUnopenableDatabase({
  required File database,
  required String appVersion,
  required Directory exportDirectory,
  DateTime Function()? now,
}) => Results.guard(
  () async {
    final raw = sqlite3.open(database.path, mode: OpenMode.readOnly);
    final int schemaVersion;
    final BackupTables tables;
    try {
      schemaVersion =
          raw.select('PRAGMA user_version').single['user_version'] as int? ?? 0;
      tables = await readBackupTables((sql) async {
        try {
          return <BackupRow>[
            for (final row in raw.select(sql)) Map<String, Object?>.of(row),
          ];
        } on SqliteException {
          // A table this file's schema never had: nothing to export from it,
          // and no reason to export nothing.
          return const <BackupRow>[];
        }
      });
    } finally {
      raw.close();
    }

    final at = (now ?? DateTime.now)();
    final manifest = BackupCodec.manifestFor(
      appVersion: appVersion,
      schemaVersion: schemaVersion,
      exportedAt: at,
      tables: tables,
    );
    return await writeExport(
      folder: exportDirectory,
      bytes: await _encodeOffTheUiThread(manifest, tables),
      manifest: manifest,
      now: at,
    );
  },
  onError: (error, stackTrace) => FileFailure(
    kind: FileFailureKind.corrupt,
    path: database.path,
    cause: error,
    stackTrace: stackTrace,
  ),
);

/// A separate function, so the isolate's closure holds only plain data -
/// never the open database handle, which cannot be sent.
Future<Uint8List> _encodeOffTheUiThread(
  BackupManifest manifest,
  BackupTables tables,
) => Isolate.run(() => BackupCodec.encode(manifest, tables));
