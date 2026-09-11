/// Removing the user's whole library - for *Replace* and *Delete all data*.
///
/// A user action, never a migration: the migration rules (`docs/DATABASE.md`
/// §3) forbid destroying data on upgrade, and this file is deliberately
/// outside the paths `tool/check_migration_safety.dart` scans for that reason
/// only - it is reached from a typed confirmation, not from a version bump.
library;

import 'package:vocabnote/data/backup/backup_tables.dart';
import 'package:vocabnote/data/db/app_database.dart';

/// Deletes every row of every backed-up table and resets settings to their
/// defaults, inside whatever transaction the caller holds.
///
/// Children before parents. The foreign keys would cascade from `words`
/// anyway, but emptying each table by name means no row is left behind
/// depending on `PRAGMA foreign_keys` having been set on this connection.
///
/// `app_meta` is kept: `install_id` belongs to this install, and onboarding
/// that was finished stays finished.
Future<void> clearLibraryRows(AppDatabase db) async {
  for (final table in backupTableNames.reversed) {
    if (table == 'settings') continue;
    await db.customStatement('DELETE FROM $table');
  }
  await db.settingsDao.resetToDefaults();
}

/// [clearLibraryRows] in one transaction, then tells every watching screen.
Future<void> wipeLibrary(AppDatabase db) async {
  await db.transaction(() => clearLibraryRows(db));
  db.markTablesUpdated(db.allTables);
}

/// Leaves nothing of the deleted rows readable in the database file.
///
/// Deleting a row does not erase it. FTS5 keeps a deleted word's tokens in
/// its index segments until they are next merged, and SQLite leaves a
/// deleted row's bytes in the page it sat on. Found on a device: after
/// *Delete all data* the file still held the word, four times over. So the
/// index is rebuilt from its content - now empty - which drops the old
/// segments, and VACUUM rewrites every page from what is live.
///
/// Outside any transaction: SQLite refuses VACUUM inside one.
Future<void> scrubFreedSpace(AppDatabase db) async {
  await db.customStatement(
    "INSERT INTO words_fts(words_fts) VALUES('rebuild')",
  );
  await db.customStatement('VACUUM');
}
