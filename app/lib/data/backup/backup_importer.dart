import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_merge.dart';
import 'package:vocabnote/data/backup/backup_rows.dart';
import 'package:vocabnote/data/backup/backup_sql.dart';
import 'package:vocabnote/data/backup/library_wipe.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/backup.dart';

/// Brings a decoded backup into the database (F-074, `docs/DATABASE.md` §5).
///
/// Every import is **one transaction**: a failure part-way - a full disk, a
/// constraint - leaves the library exactly as it was, never half-imported.
/// Rows are checked against this build's schema first; what cannot be used
/// is counted and skipped, never a reason to refuse the rest.
class BackupImporter {
  /// Creates an importer over [_db].
  new(this._db) : _reader = BackupRowReader(_db.allTables);

  final AppDatabase _db;
  final BackupRowReader _reader;

  /// Adds what is new and updates what is newer; removes nothing.
  Future<ImportReport> merge(DecodedBackup backup) async {
    final checked = _reader.check(backup);
    final report = await _db.transaction(() => BackupMerge(_db, checked).run());
    // Raw SQL bypasses Drift's change tracking; every open screen re-reads.
    _db.markTablesUpdated(_db.allTables);
    return report;
  }

  /// Replaces the whole library with the backup's.
  ///
  /// The caller takes the safety copy first; this does not.
  Future<ImportReport> replace(DecodedBackup backup) async {
    final checked = _reader.check(backup);
    final report = await _db.transaction(() async {
      await clearLibraryRows(_db);
      return await _ReplaceRun(_db, checked).run();
    });
    _db.markTablesUpdated(_db.allTables);
    return report;
  }
}

/// Writes a checked backup into an empty library.
///
/// Every reference is checked before its row is written, because a single
/// failed foreign key or CHECK would abort the whole transaction: a note on a
/// word the backup lacks, a duplicate id, a highlight past the end of its
/// word, a box outside 0-6.
class _ReplaceRun {
  new(this._db, this._backup);

  final AppDatabase _db;
  final CheckedBackup _backup;
  late int _rejected = _backup.rejected;

  Future<ImportReport> run() async {
    final words = <String, BackupRow>{};
    for (final row in _backup.rows('words')) {
      if (words.containsKey(row['id'])) {
        _rejected++;
        continue;
      }
      await _db.insertRow('words', row);
      words[row['id']! as String] = row;
    }

    final notes = await _insertWhere(
      'word_notes',
      (row) => words.containsKey(row['word_id']),
    );
    final highlights = await _insertWhere('ipa_highlights', (row) {
      final ipa = words[row['word_id']]?[row['target']];
      return ipa is String && highlightFits(row, ipa);
    });
    final lists = await _insertWhere('word_lists', (_) => true);
    final listIds = <Object?>{
      for (final row in _backup.rows('word_lists')) row['id'],
    };
    await _insertWhere(
      'word_list_items',
      (row) =>
          listIds.contains(row['list_id']) && words.containsKey(row['word_id']),
      key: (row) => '${row['list_id']}|${row['word_id']}',
    );
    await _insertWhere(
      'study_cards',
      (row) => words.containsKey(row['word_id']) && cardBoxValid(row),
      key: (row) => row['word_id'],
    );
    final sessions = <Object?>{
      for (final row in _backup.rows('practice_sessions')) row['id'],
    };
    await _insertWhere('practice_sessions', (_) => true);
    await _insertWhere(
      'practice_answers',
      (row) =>
          sessions.contains(row['session_id']) &&
          words.containsKey(row['word_id']),
    );

    final settings = _backup.rows('settings').firstOrNull;
    if (settings != null) {
      // Restored as they were, but for the reminder: it needs this phone's
      // permission, and only its switch may ask (F-066).
      await _db.updateRow(
        'settings',
        <String, Object?>{...settings, 'reminder_enabled': 0}..remove('id'),
        keyColumn: 'id',
        key: 1,
      );
    }

    return ImportReport(
      wordsAdded: words.length,
      notesAdded: notes,
      highlightsAdded: highlights,
      listsAdded: lists,
      rejected: _rejected,
    );
  }

  /// Inserts the rows of [table] that pass [keep] and have not been seen
  /// already (by [key], the id by default). Returns how many went in.
  Future<int> _insertWhere(
    String table,
    bool Function(BackupRow row) keep, {
    Object? Function(BackupRow row)? key,
  }) async {
    final seen = <Object?>{};
    var inserted = 0;
    for (final row in _backup.rows(table)) {
      if (!keep(row) || !seen.add((key ?? (r) => r['id'])(row))) {
        _rejected++;
        continue;
      }
      await _db.insertRow(table, row);
      inserted++;
    }
    return inserted;
  }
}
