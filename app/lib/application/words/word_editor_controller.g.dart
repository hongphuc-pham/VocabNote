// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The add/edit form (`docs/UI-UX.md` §4.2, F-001, F-003, F-007).
///
/// Owns the draft, the duplicate check and saving. The screen owns text
/// controllers and focus; everything that could be got wrong lives here where
/// it can be tested without pumping a widget.

@ProviderFor(WordEditor)
final wordEditorProvider = WordEditorFamily._();

/// The add/edit form (`docs/UI-UX.md` §4.2, F-001, F-003, F-007).
///
/// Owns the draft, the duplicate check and saving. The screen owns text
/// controllers and focus; everything that could be got wrong lives here where
/// it can be tested without pumping a widget.
final class WordEditorProvider
    extends $AsyncNotifierProvider<WordEditor, WordDraft> {
  /// The add/edit form (`docs/UI-UX.md` §4.2, F-001, F-003, F-007).
  ///
  /// Owns the draft, the duplicate check and saving. The screen owns text
  /// controllers and focus; everything that could be got wrong lives here where
  /// it can be tested without pumping a widget.
  WordEditorProvider._({
    required WordEditorFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'wordEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordEditorHash();

  @override
  String toString() {
    return r'wordEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WordEditor create() => WordEditor();

  @override
  bool operator ==(Object other) {
    return other is WordEditorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordEditorHash() => r'2c78d69fc138e92f7c8ac8f6c632a1aeea931e59';

/// The add/edit form (`docs/UI-UX.md` §4.2, F-001, F-003, F-007).
///
/// Owns the draft, the duplicate check and saving. The screen owns text
/// controllers and focus; everything that could be got wrong lives here where
/// it can be tested without pumping a widget.

final class WordEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          WordEditor,
          AsyncValue<WordDraft>,
          WordDraft,
          FutureOr<WordDraft>,
          String?
        > {
  WordEditorFamily._()
    : super(
        retry: null,
        name: r'wordEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The add/edit form (`docs/UI-UX.md` §4.2, F-001, F-003, F-007).
  ///
  /// Owns the draft, the duplicate check and saving. The screen owns text
  /// controllers and focus; everything that could be got wrong lives here where
  /// it can be tested without pumping a widget.

  WordEditorProvider call(String? wordId) =>
      WordEditorProvider._(argument: wordId, from: this);

  @override
  String toString() => r'wordEditorProvider';
}

/// The add/edit form (`docs/UI-UX.md` §4.2, F-001, F-003, F-007).
///
/// Owns the draft, the duplicate check and saving. The screen owns text
/// controllers and focus; everything that could be got wrong lives here where
/// it can be tested without pumping a widget.

abstract class _$WordEditor extends $AsyncNotifier<WordDraft> {
  late final _$args = ref.$arg as String?;
  String? get wordId => _$args;

  FutureOr<WordDraft> build(String? wordId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WordDraft>, WordDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WordDraft>, WordDraft>,
              AsyncValue<WordDraft>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
