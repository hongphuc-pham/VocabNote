/// Which tables a backup carries, and reading them.
library;

import 'package:vocabnote/data/backup/backup_codec.dart';

/// The tables a backup carries, parents before children - the order rows are
/// restored in, so every foreign key already has its target.
///
/// `app_meta` is deliberately absent: `install_id` is local-only by promise
/// (`docs/DATA-SOURCES.md` §7), and its other keys describe this install, not
/// the user's library. `words_fts` is derived and rebuilt, never copied.
const List<String> backupTableNames = <String>[
  'words',
  'word_notes',
  'ipa_highlights',
  'word_lists',
  'word_list_items',
  'study_cards',
  'practice_sessions',
  'practice_answers',
  'settings',
];

/// Reads every [backupTableNames] table through [select].
///
/// [select] runs one `SELECT` and returns its rows as column-name maps.
/// Taking a function rather than a database is what lets the recovery screen
/// use this same code over a bare `sqlite3` handle - the one situation in
/// which Drift is, by definition, unavailable.
///
/// `SELECT *`, so a column added by a later additive migration is carried
/// without this file changing.
Future<BackupTables> readBackupTables(
  Future<List<BackupRow>> Function(String sql) select,
) async => <String, List<BackupRow>>{
  for (final table in backupTableNames)
    table: await select('SELECT * FROM $table ORDER BY rowid'),
};
