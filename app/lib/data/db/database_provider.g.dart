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

/// Words, notes and highlights.

@ProviderFor(wordRepository)
final wordRepositoryProvider = WordRepositoryProvider._();

/// Words, notes and highlights.

final class WordRepositoryProvider
    extends $FunctionalProvider<WordRepository, WordRepository, WordRepository>
    with $Provider<WordRepository> {
  /// Words, notes and highlights.
  WordRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordRepositoryHash();

  @$internal
  @override
  $ProviderElement<WordRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WordRepository create(Ref ref) {
    return wordRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordRepository>(value),
    );
  }
}

String _$wordRepositoryHash() => r'febed84e6834e1b58c0665f4c3b744a834e82641';

/// Lists (decks) and membership.

@ProviderFor(listRepository)
final listRepositoryProvider = ListRepositoryProvider._();

/// Lists (decks) and membership.

final class ListRepositoryProvider
    extends $FunctionalProvider<ListRepository, ListRepository, ListRepository>
    with $Provider<ListRepository> {
  /// Lists (decks) and membership.
  ListRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListRepository create(Ref ref) {
    return listRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListRepository>(value),
    );
  }
}

String _$listRepositoryHash() => r'ea607e18b05920eccdbcbddf3c5767356ccfc56d';

/// Study cards, sessions and answers.

@ProviderFor(practiceRepository)
final practiceRepositoryProvider = PracticeRepositoryProvider._();

/// Study cards, sessions and answers.

final class PracticeRepositoryProvider
    extends
        $FunctionalProvider<
          PracticeRepository,
          PracticeRepository,
          PracticeRepository
        >
    with $Provider<PracticeRepository> {
  /// Study cards, sessions and answers.
  PracticeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'practiceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$practiceRepositoryHash();

  @$internal
  @override
  $ProviderElement<PracticeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PracticeRepository create(Ref ref) {
    return practiceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PracticeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PracticeRepository>(value),
    );
  }
}

String _$practiceRepositoryHash() =>
    r'268507f04c947b836154afc7c18c4b72aa12ea96';

/// The settings row and `app_meta`.

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// The settings row and `app_meta`.

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// The settings row and `app_meta`.
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'386b8272908126d473256fed76299cd9c9d1b218';
