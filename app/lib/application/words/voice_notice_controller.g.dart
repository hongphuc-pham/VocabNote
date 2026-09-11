// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_notice_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the voice-fallback notice should be on screen right now.
///
/// True only when all three hold: the device really did fall back, the user has
/// not already been told, and this session has not just dismissed it.
///
/// Resolving the voice is a platform round trip, so this is a provider rather
/// than something the screen works out for itself on every build.

@ProviderFor(VoiceNotice)
final voiceNoticeProvider = VoiceNoticeProvider._();

/// Whether the voice-fallback notice should be on screen right now.
///
/// True only when all three hold: the device really did fall back, the user has
/// not already been told, and this session has not just dismissed it.
///
/// Resolving the voice is a platform round trip, so this is a provider rather
/// than something the screen works out for itself on every build.
final class VoiceNoticeProvider
    extends $AsyncNotifierProvider<VoiceNotice, bool> {
  /// Whether the voice-fallback notice should be on screen right now.
  ///
  /// True only when all three hold: the device really did fall back, the user has
  /// not already been told, and this session has not just dismissed it.
  ///
  /// Resolving the voice is a platform round trip, so this is a provider rather
  /// than something the screen works out for itself on every build.
  VoiceNoticeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voiceNoticeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voiceNoticeHash();

  @$internal
  @override
  VoiceNotice create() => VoiceNotice();
}

String _$voiceNoticeHash() => r'517e318d555e32f50b1105914b60f33bba5bd146';

/// Whether the voice-fallback notice should be on screen right now.
///
/// True only when all three hold: the device really did fall back, the user has
/// not already been told, and this session has not just dismissed it.
///
/// Resolving the voice is a platform round trip, so this is a provider rather
/// than something the screen works out for itself on every build.

abstract class _$VoiceNotice extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
