/// An enum whose database representation is pinned independently of its Dart
/// name.
///
/// Every enum that reaches a column implements this. The point is that
/// renaming a Dart constant must never change what is already on disk:
/// `PracticeMode.quickTest` stores `quick_test` because that is what
/// `docs/DATABASE.md` §2 says the column contains, and it will keep storing
/// that even if the constant is renamed tomorrow.
///
/// Drift's `textEnum()` does the opposite - it writes `EnumValue.name` - which
/// is why this project does not use it.
abstract interface class StorageEnum {
  /// The exact string written to the database.
  String get storageValue;
}
