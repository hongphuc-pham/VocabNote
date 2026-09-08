import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/app_meta.dart';

part 'meta_dao.g.dart';

/// Reads and writes `app_meta` - loose key/value state.
///
/// Everything here is a string. Callers parse, and every read has a default,
/// because a missing key is a normal state on a fresh install rather than an
/// error.
@DriftAccessor(tables: <Type>[AppMeta])
class MetaDao extends DatabaseAccessor<AppDatabase> with _$MetaDaoMixin {
  /// Creates the DAO.
  new(super.attachedDatabase);

  /// Reads a raw value, or null when the key is not set.
  Future<String?> get(String key) async {
    final row = await (select(
      appMeta,
    )..where((m) => m.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Watches a raw value.
  Stream<String?> watch(String key) =>
      (select(appMeta)..where((m) => m.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  /// Writes a value, replacing any existing one.
  Future<void> set(String key, String? value) => into(appMeta)
      .insertOnConflictUpdate(
        AppMetaCompanion.insert(key: key, value: Value(value)),
      );

  /// Reads a boolean, defaulting to [orElse] when unset or unparseable.
  Future<bool> getBool(String key, {bool orElse = false}) async {
    final value = await get(key);
    return switch (value) {
      'true' => true,
      'false' => false,
      _ => orElse,
    };
  }

  /// Writes a boolean.
  Future<void> setBool(String key, {required bool value}) =>
      set(key, value ? 'true' : 'false');

  /// Reads an epoch-millisecond timestamp, or null when unset or unparseable.
  Future<DateTime?> getTimestamp(String key) async {
    final value = await get(key);
    if (value == null) return null;
    final millis = int.tryParse(value);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  /// Writes an epoch-millisecond timestamp.
  Future<void> setTimestamp(String key, DateTime value) =>
      set(key, '${value.toUtc().millisecondsSinceEpoch}');

  /// Every key/value pair - what backup export writes out.
  Future<List<AppMetaRow>> getAll() => select(appMeta).get();
}
