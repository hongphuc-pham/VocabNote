/// The few raw statements import needs.
///
/// Raw rather than Drift companions because a backup row is a map of SQL
/// column names. Safe to build as text: table names come from
/// `backupTableNames`, a constant, and column names only from
/// `BackupRowReader`, which keeps nothing but the live schema's own columns -
/// no text from the file ever reaches the SQL itself, only the bound values.
library;

import 'package:drift/drift.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/db/app_database.dart';

/// Raw row access for import.
extension BackupSql on AppDatabase {
  /// Runs [sql] and returns its rows as column-name maps.
  Future<List<BackupRow>> selectRows(
    String sql, [
    List<Object?> args = const <Object?>[],
  ]) async => <BackupRow>[
    for (final row in await customSelect(
      sql,
      variables: <Variable<Object>>[
        for (final arg in args) Variable<Object>(arg),
      ],
    ).get())
      row.data,
  ];

  /// Inserts [row] into [table] as it stands.
  Future<void> insertRow(String table, BackupRow row) => customStatement(
    'INSERT INTO $table (${row.keys.join(', ')}) '
    'VALUES (${List<String>.filled(row.length, '?').join(', ')})',
    row.values.toList(),
  );

  /// Sets [values] on the rows of [table] where [keyColumn] is [key].
  Future<void> updateRow(
    String table,
    BackupRow values, {
    required String keyColumn,
    required Object key,
  }) async {
    if (values.isEmpty) return;
    await customStatement(
      'UPDATE $table SET ${values.keys.map((c) => '$c = ?').join(', ')} '
      'WHERE $keyColumn = ?',
      <Object?>[...values.values, key],
    );
  }
}
