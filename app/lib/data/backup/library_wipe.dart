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
