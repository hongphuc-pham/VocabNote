// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight_editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives one pass through the highlight editor.
///
/// Undo covers the whole session and is a stack of previous highlight lists —
/// small enough that keeping every step costs nothing, and simple enough that
/// it cannot get out of step with the thing it is undoing.

@ProviderFor(HighlightEditor)
final highlightEditorProvider = HighlightEditorFamily._();

/// Drives one pass through the highlight editor.
///
/// Undo covers the whole session and is a stack of previous highlight lists —
/// small enough that keeping every step costs nothing, and simple enough that
/// it cannot get out of step with the thing it is undoing.
final class HighlightEditorProvider
    extends $NotifierProvider<HighlightEditor, HighlightEditorState> {
  /// Drives one pass through the highlight editor.
  ///
  /// Undo covers the whole session and is a stack of previous highlight lists —
  /// small enough that keeping every step costs nothing, and simple enough that
  /// it cannot get out of step with the thing it is undoing.
  HighlightEditorProvider._({
    required HighlightEditorFamily super.from,
    required (String, HighlightTarget, String) super.argument,
  }) : super(
         retry: null,
         name: r'highlightEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$highlightEditorHash();

  @override
  String toString() {
    return r'highlightEditorProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  HighlightEditor create() => HighlightEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HighlightEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HighlightEditorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HighlightEditorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$highlightEditorHash() => r'c0fd87ad2088881e6d514459edef94b56c9e2883';

/// Drives one pass through the highlight editor.
///
/// Undo covers the whole session and is a stack of previous highlight lists —
/// small enough that keeping every step costs nothing, and simple enough that
/// it cannot get out of step with the thing it is undoing.

final class HighlightEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          HighlightEditor,
          HighlightEditorState,
          HighlightEditorState,
          HighlightEditorState,
          (String, HighlightTarget, String)
        > {
  HighlightEditorFamily._()
    : super(
        retry: null,
        name: r'highlightEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives one pass through the highlight editor.
  ///
  /// Undo covers the whole session and is a stack of previous highlight lists —
  /// small enough that keeping every step costs nothing, and simple enough that
  /// it cannot get out of step with the thing it is undoing.

  HighlightEditorProvider call(
    String wordId,
    HighlightTarget target,
    String ipa,
  ) => HighlightEditorProvider._(argument: (wordId, target, ipa), from: this);

  @override
  String toString() => r'highlightEditorProvider';
}

/// Drives one pass through the highlight editor.
///
/// Undo covers the whole session and is a stack of previous highlight lists —
/// small enough that keeping every step costs nothing, and simple enough that
/// it cannot get out of step with the thing it is undoing.

abstract class _$HighlightEditor extends $Notifier<HighlightEditorState> {
  late final _$args = ref.$arg as (String, HighlightTarget, String);
  String get wordId => _$args.$1;
  HighlightTarget get target => _$args.$2;
  String get ipa => _$args.$3;

  HighlightEditorState build(String wordId, HighlightTarget target, String ipa);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HighlightEditorState, HighlightEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HighlightEditorState, HighlightEditorState>,
              HighlightEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(_$args.$1, _$args.$2, _$args.$3),
    );
  }
}
