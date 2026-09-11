// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guide_targets.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The guide's targets, kept current.
///
/// Watched rather than read once, so a word added from one card's *Try it*
/// is the word the next card opens. Twenty recent words is plenty to find a
/// transcribed one; a library with none in its last twenty is sent to add
/// IPA to its newest word, which is the right advice anyway.

@ProviderFor(guideTargets)
final guideTargetsProvider = GuideTargetsProvider._();

/// The guide's targets, kept current.
///
/// Watched rather than read once, so a word added from one card's *Try it*
/// is the word the next card opens. Twenty recent words is plenty to find a
/// transcribed one; a library with none in its last twenty is sent to add
/// IPA to its newest word, which is the right advice anyway.

final class GuideTargetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<GuideTargets>,
          GuideTargets,
          Stream<GuideTargets>
        >
    with $FutureModifier<GuideTargets>, $StreamProvider<GuideTargets> {
  /// The guide's targets, kept current.
  ///
  /// Watched rather than read once, so a word added from one card's *Try it*
  /// is the word the next card opens. Twenty recent words is plenty to find a
  /// transcribed one; a library with none in its last twenty is sent to add
  /// IPA to its newest word, which is the right advice anyway.
  GuideTargetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideTargetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideTargetsHash();

  @$internal
  @override
  $StreamProviderElement<GuideTargets> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<GuideTargets> create(Ref ref) {
    return guideTargets(ref);
  }
}

String _$guideTargetsHash() => r'875faf957a60696ae2f61e53cce62f51df5c82f0';
