/// Checking a backup's rows against the schema this build has.
///
/// `docs/DATABASE.md` §5: readers ignore unknown fields and default missing
/// ones. Driven by the live Drift schema rather than a hand-written list, so
/// a column added by a later migration is understood without this file
/// changing, and the two can never disagree.
library;

import 'package:drift/drift.dart';
import 'package:vocabnote/core/extensions/grapheme.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_tables.dart';

/// A backup's known tables, every row already fit for this schema.
class CheckedBackup {
  /// Creates the checked backup.
  const new(this._tables, {required this.rejected});

  final Map<String, List<BackupRow>> _tables;

  /// Rows refused so far - by the codec for their shape, by the reader for
  /// their columns.
  final int rejected;

  /// The rows of [table], in the order the backup holds them.
  List<BackupRow> rows(String table) => _tables[table] ?? const <BackupRow>[];
}

/// Checks rows one table at a time.
class BackupRowReader {
  /// Creates a reader over [tables] - `AppDatabase.allTables`.
  new(Iterable<TableInfo<Table, Object?>> tables)
    : _columns = <String, List<GeneratedColumn>>{
        for (final table in tables) table.actualTableName: table.$columns,
      };

  final Map<String, List<GeneratedColumn>> _columns;

  /// Every [backupTableNames] table of [backup], checked.
  CheckedBackup check(DecodedBackup backup) {
    var rejected = backup.malformedRows;
    final tables = <String, List<BackupRow>>{};
    for (final table in backupTableNames) {
      final read = this.read(table, backup.tables[table] ?? const []);
      tables[table] = read.rows;
      rejected += read.rejected;
    }
    return CheckedBackup(tables, rejected: rejected);
  }

  /// The rows of [table] this schema can take, and how many it cannot.
  ///
  /// A kept row holds only this schema's columns, each of its SQL type. A
  /// missing column that has a default is left out so SQLite supplies it; a
  /// missing column that has none - or a value of the wrong type - refuses
  /// the row.
  ({List<BackupRow> rows, int rejected}) read(
    String table,
    List<BackupRow> rows,
  ) {
    final columns = _columns[table] ?? const <GeneratedColumn>[];
    final kept = <BackupRow>[];
    var rejected = 0;
    for (final row in rows) {
      final checked = _check(columns, row);
      if (checked == null) {
        rejected++;
      } else {
        kept.add(checked);
      }
    }
    return (rows: kept, rejected: rejected);
  }

  static BackupRow? _check(List<GeneratedColumn> columns, BackupRow row) {
    final checked = <String, Object?>{};
    for (final column in columns) {
      final name = column.name;
      final value = row[name];
      if (value == null) {
        if (column.$nullable) {
          // Present and null is kept; absent is left out. Both end as NULL.
          if (row.containsKey(name)) checked[name] = null;
        } else if (column.requiredDuringInsert) {
          return null;
        }
        continue;
      }
      final typed = _typed(column, value);
      if (typed == null) return null;
      checked[name] = typed;
    }
    return checked;
  }

  /// [value] as SQLite stores [column], or null if it is not of its type.
  static Object? _typed(GeneratedColumn column, Object value) {
    final type = column.type;
    if (type == DriftSqlType.string) return value is String ? value : null;
    if (type == DriftSqlType.int) return value is int ? value : null;
    if (type == DriftSqlType.double) {
      return value is num ? value.toDouble() : null;
    }
    if (type == DriftSqlType.bool) {
      // Stored as 0/1; a hand-edited file may say true/false.
      return switch (value) {
        true || 1 => 1,
        false || 0 => 0,
        _ => null,
      };
    }
    // No other type is used by this schema.
    return null;
  }
}

/// Whether a highlight row's range fits [ipa], counted in grapheme clusters
/// (ADR-006) - the database's CHECKs catch a reversed range, but not one that
/// runs past the end of its word.
bool highlightFits(BackupRow highlight, String ipa) {
  final start = highlight['start_grapheme'];
  final end = highlight['end_grapheme'];
  return start is int &&
      end is int &&
      start >= 0 &&
      end > start &&
      end <= ipa.graphemeLength;
}

/// Whether a study card's box is one the schema's CHECK allows (0-6).
bool cardBoxValid(BackupRow card) {
  final box = card['box'];
  return box == null || (box is int && box >= 0 && box <= 6);
}
