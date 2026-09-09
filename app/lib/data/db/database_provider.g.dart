// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The open database.
///
/// Has no default: `bootstrap.dart` opens the database (taking a backup and
/// running migrations first) and overrides this provider with the result.
/// Reading it without that override is a programming error, and throwing says
/// so immediately rather than quietly opening a second, unmigrated database
/// somewhere unexpected.
///
/// Tests override it with `AppDatabase.memory()`.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The open database.
///
/// Has no default: `bootstrap.dart` opens the database (taking a backup and
/// running migrations first) and overrides this provider with the result.
/// Reading it without that override is a programming error, and throwing says
/// so immediately rather than quietly opening a second, unmigrated database
/// somewhere unexpected.
///
/// Tests override it with `AppDatabase.memory()`.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The open database.
  ///
  /// Has no default: `bootstrap.dart` opens the database (taking a backup and
  /// running migrations first) and overrides this provider with the result.
  /// Reading it without that override is a programming error, and throwing says
  /// so immediately rather than quietly opening a second, unmigrated database
  /// somewhere unexpected.
  ///
  /// Tests override it with `AppDatabase.memory()`.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'4addf897cf873e62f69d26c44cd74ad203482efd';
