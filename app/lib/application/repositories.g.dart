// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$wordRepositoryHash() => r'e469268e63ae1d639c80a2a25cd34a1a165451be';

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

String _$listRepositoryHash() => r'4c1b1f11fd7e3aae14140425b0a2170d9aec382f';

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
    r'42eb5873017c5fdf19ecd2b91dd7383eb93d0fd8';

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
    r'fb266767dae061d3152a2cb58c226260e3b9e90c';

/// The device speech engine (ADR-003).
///
/// Declared here like a repository even though it is a device service rather
/// than a store, because it is the same kind of seam: ADR-003 promises that a
/// future `RemoteAudioService` can replace it without a screen changing, and
/// that only holds while nothing above `data/` names a speech plugin.

@ProviderFor(speechService)
final speechServiceProvider = SpeechServiceProvider._();

/// The device speech engine (ADR-003).
///
/// Declared here like a repository even though it is a device service rather
/// than a store, because it is the same kind of seam: ADR-003 promises that a
/// future `RemoteAudioService` can replace it without a screen changing, and
/// that only holds while nothing above `data/` names a speech plugin.

final class SpeechServiceProvider
    extends $FunctionalProvider<SpeechService, SpeechService, SpeechService>
    with $Provider<SpeechService> {
  /// The device speech engine (ADR-003).
  ///
  /// Declared here like a repository even though it is a device service rather
  /// than a store, because it is the same kind of seam: ADR-003 promises that a
  /// future `RemoteAudioService` can replace it without a screen changing, and
  /// that only holds while nothing above `data/` names a speech plugin.
  SpeechServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechServiceHash();

  @$internal
  @override
  $ProviderElement<SpeechService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpeechService create(Ref ref) {
    return speechService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechService>(value),
    );
  }
}

String _$speechServiceHash() => r'29b12740eff03a583766bc282efa2bfad9165b99';

/// Dictionary look-up: cache, then API, then the bundled offline asset.

@ProviderFor(dictionaryRepository)
final dictionaryRepositoryProvider = DictionaryRepositoryProvider._();

/// Dictionary look-up: cache, then API, then the bundled offline asset.

final class DictionaryRepositoryProvider
    extends
        $FunctionalProvider<
          DictionaryRepository,
          DictionaryRepository,
          DictionaryRepository
        >
    with $Provider<DictionaryRepository> {
  /// Dictionary look-up: cache, then API, then the bundled offline asset.
  DictionaryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictionaryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictionaryRepositoryHash();

  @$internal
  @override
  $ProviderElement<DictionaryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DictionaryRepository create(Ref ref) {
    return dictionaryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DictionaryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DictionaryRepository>(value),
    );
  }
}

String _$dictionaryRepositoryHash() =>
    r'dc7ce5d6d1f44aab7cd0895b7b324aa50dfa9ec1';
