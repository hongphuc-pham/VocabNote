// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pronunciation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Speaks transcriptions on demand.
///
/// Auto-disposed on purpose: leaving the screen disposes this, which stops the
/// engine. An app that carries on pronouncing a word the user has navigated
/// away from is the kind of thing people turn sound off over.

@ProviderFor(Pronunciation)
final pronunciationProvider = PronunciationProvider._();

/// Speaks transcriptions on demand.
///
/// Auto-disposed on purpose: leaving the screen disposes this, which stops the
/// engine. An app that carries on pronouncing a word the user has navigated
/// away from is the kind of thing people turn sound off over.
final class PronunciationProvider
    extends $NotifierProvider<Pronunciation, PlaybackState> {
  /// Speaks transcriptions on demand.
  ///
  /// Auto-disposed on purpose: leaving the screen disposes this, which stops the
  /// engine. An app that carries on pronouncing a word the user has navigated
  /// away from is the kind of thing people turn sound off over.
  PronunciationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pronunciationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pronunciationHash();

  @$internal
  @override
  Pronunciation create() => Pronunciation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackState>(value),
    );
  }
}

String _$pronunciationHash() => r'1a42afbbdb682e983cb4e1806428f289c46b17ec';

/// Speaks transcriptions on demand.
///
/// Auto-disposed on purpose: leaving the screen disposes this, which stops the
/// engine. An app that carries on pronouncing a word the user has navigated
/// away from is the kind of thing people turn sound off over.

abstract class _$Pronunciation extends $Notifier<PlaybackState> {
  PlaybackState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlaybackState, PlaybackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaybackState, PlaybackState>,
              PlaybackState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
