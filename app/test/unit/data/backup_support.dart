/// Helpers shared by the backup import tests.
library;

import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_tables.dart';
import 'package:vocabnote/data/db/app_database.dart';

import 'db_fixtures.dart';

/// Every backed-up table in [db], exactly as a backup would read it.
///
/// Comparing two of these is the deep-equal the round trip promises: every
/// row of every table, value for value, in the same order.
Future<BackupTables> snapshot(AppDatabase db) => readBackupTables(
  (sql) async => <BackupRow>[
    for (final row in await db.customSelect(sql).get()) row.data,
  ],
);

/// The rows of one table in [db].
Future<List<BackupRow>> rowsOf(AppDatabase db, String table) async =>
    <BackupRow>[
      for (final row
          in await db.customSelect('SELECT * FROM $table ORDER BY rowid').get())
        row.data,
    ];

/// A decoded backup of [db], as if it had been exported and read back.
Future<DecodedBackup> backupOf(AppDatabase db) async {
  final tables = await snapshot(db);
  return DecodedBackup(
    manifest: BackupCodec.manifestFor(
      appVersion: '1.0.0',
      schemaVersion: AppDatabase.latestSchemaVersion,
      exportedAt: testNow,
      tables: tables,
    ),
    tables: tables,
  );
}

/// Makes every insert into [table] fail, the way a full disk or a constraint
/// would - a real database failure, so a test of rollback needs no hook in
/// the code under test.
Future<void> failInsertsInto(AppDatabase db, String table) =>
    db.customStatement(
      'CREATE TRIGGER fail_$table BEFORE INSERT ON $table '
      "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
    );

/// Milliseconds since the epoch, as the database stores time.
int ms(DateTime at) => at.millisecondsSinceEpoch;
