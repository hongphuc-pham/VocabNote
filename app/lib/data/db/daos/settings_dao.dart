import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/settings.dart';

part 'settings_dao.g.dart';

/// Reads and writes the single `settings` row (F-070).
@DriftAccessor(tables: <Type>[Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  /// Creates the DAO.
  new(super.attachedDatabase);

  /// The id of the one and only settings row.
  static const int rowId = 1;

  /// Watches the settings row.
  ///
  /// Emits on every change, which is what makes settings take effect
  /// immediately rather than on the next restart.
  Stream<SettingsRow> watchSettings() => _ensureThenSelect().watchSingle();

  /// Reads the settings row.
  Future<SettingsRow> getSettings() => _ensureThenSelect().getSingle();

  SingleSelectable<SettingsRow> _ensureThenSelect() =>
      select(settings)..where((s) => s.id.equals(rowId));

  /// Applies a partial update.
  ///
  /// `insertOnConflictUpdate` rather than a plain write: if the row were ever
  /// missing - a hand-edited database, a partial restore - settings would
  /// silently stop persisting, and the user would blame the app rather than
  /// the file.
  Future<void> updateSettings(SettingsCompanion patch) =>
      into(settings)
          .insertOnConflictUpdate(patch.copyWith(id: const Value(rowId)));

  /// Restores every setting to its documented default.
  ///
  /// Used by *Delete all data* (F-078). Deliberately a write of defaults
  /// rather than a delete, so the single-row invariant always holds.
  Future<void> resetToDefaults() async {
    await (delete(settings)..where((s) => s.id.equals(rowId))).go();
    await into(settings).insert(const SettingsCompanion(id: Value(rowId)));
  }
}
