// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_notes_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Adds, edits and removes notes.
///
/// Separate from `WordActions` because notes have their own lifetime: they are
/// the user's writing, they are indexed for search (F-041), and unlike a word
/// they are **not** soft-deleted — there is no 30-day window and no Undo beyond
/// the snackbar, which the repository interface is explicit about.
///
/// Kept alive for the same reason `WordActions` is: nothing here holds state,
/// and an action fired from a snackbar must still find its notifier alive.

@ProviderFor(WordNotes)
final wordNotesProvider = WordNotesProvider._();

/// Adds, edits and removes notes.
///
/// Separate from `WordActions` because notes have their own lifetime: they are
/// the user's writing, they are indexed for search (F-041), and unlike a word
/// they are **not** soft-deleted — there is no 30-day window and no Undo beyond
/// the snackbar, which the repository interface is explicit about.
///
/// Kept alive for the same reason `WordActions` is: nothing here holds state,
/// and an action fired from a snackbar must still find its notifier alive.
final class WordNotesProvider extends $NotifierProvider<WordNotes, void> {
  /// Adds, edits and removes notes.
  ///
  /// Separate from `WordActions` because notes have their own lifetime: they are
  /// the user's writing, they are indexed for search (F-041), and unlike a word
  /// they are **not** soft-deleted — there is no 30-day window and no Undo beyond
  /// the snackbar, which the repository interface is explicit about.
  ///
  /// Kept alive for the same reason `WordActions` is: nothing here holds state,
  /// and an action fired from a snackbar must still find its notifier alive.
  WordNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordNotesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordNotesHash();

  @$internal
  @override
  WordNotes create() => WordNotes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$wordNotesHash() => r'5b85aece837482c1fe79ec1d24d1462d185e1dc8';

/// Adds, edits and removes notes.
///
/// Separate from `WordActions` because notes have their own lifetime: they are
/// the user's writing, they are indexed for search (F-041), and unlike a word
/// they are **not** soft-deleted — there is no 30-day window and no Undo beyond
/// the snackbar, which the repository interface is explicit about.
///
/// Kept alive for the same reason `WordActions` is: nothing here holds state,
/// and an action fired from a snackbar must still find its notifier alive.

abstract class _$WordNotes extends $Notifier<void> {
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
