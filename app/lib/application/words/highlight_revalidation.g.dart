// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight_revalidation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Checks and prunes highlights around a transcription edit.

@ProviderFor(HighlightRevalidator)
final highlightRevalidatorProvider = HighlightRevalidatorProvider._();

/// Checks and prunes highlights around a transcription edit.
final class HighlightRevalidatorProvider
    extends $NotifierProvider<HighlightRevalidator, void> {
  /// Checks and prunes highlights around a transcription edit.
  HighlightRevalidatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'highlightRevalidatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$highlightRevalidatorHash();

  @$internal
  @override
  HighlightRevalidator create() => HighlightRevalidator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$highlightRevalidatorHash() =>
    r'a12cba297eaeae096069ab79bd4cc23132d2a750';

/// Checks and prunes highlights around a transcription edit.

abstract class _$HighlightRevalidator extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
