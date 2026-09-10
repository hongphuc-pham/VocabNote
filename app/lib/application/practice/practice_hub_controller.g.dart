// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_hub_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How many cards are due right now — the "Daily review (7 due)" count.

@ProviderFor(dueCardCount)
final dueCardCountProvider = DueCardCountProvider._();

/// How many cards are due right now — the "Daily review (7 due)" count.

final class DueCardCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// How many cards are due right now — the "Daily review (7 due)" count.
  DueCardCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dueCardCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dueCardCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return dueCardCount(ref);
  }
}

String _$dueCardCountHash() => r'c55d217627d3592d12fcd52900d9f3d10f6b012a';
