// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_actions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Actions the words list and detail screens take on a word.
///
/// Exists so `presentation/` never reaches into a repository itself
/// (`docs/RULES.md` §20) - and so soft delete, Undo and the purge live
/// together, where the 30-day retention rule is visible in one place.
///
/// **Kept alive deliberately.** The Undo action on the delete snackbar holds a
/// reference to this notifier and fires up to five seconds later, by which time
/// an auto-disposed provider is already gone - and Undo fails silently, which
/// is the worst possible outcome for a destructive action. There is no state
/// here to leak, so keeping it costs nothing.

@ProviderFor(WordActions)
final wordActionsProvider = WordActionsProvider._();

/// Actions the words list and detail screens take on a word.
///
/// Exists so `presentation/` never reaches into a repository itself
/// (`docs/RULES.md` §20) - and so soft delete, Undo and the purge live
/// together, where the 30-day retention rule is visible in one place.
///
/// **Kept alive deliberately.** The Undo action on the delete snackbar holds a
/// reference to this notifier and fires up to five seconds later, by which time
/// an auto-disposed provider is already gone - and Undo fails silently, which
/// is the worst possible outcome for a destructive action. There is no state
/// here to leak, so keeping it costs nothing.
final class WordActionsProvider extends $NotifierProvider<WordActions, void> {
  /// Actions the words list and detail screens take on a word.
  ///
  /// Exists so `presentation/` never reaches into a repository itself
  /// (`docs/RULES.md` §20) - and so soft delete, Undo and the purge live
  /// together, where the 30-day retention rule is visible in one place.
  ///
  /// **Kept alive deliberately.** The Undo action on the delete snackbar holds a
  /// reference to this notifier and fires up to five seconds later, by which time
  /// an auto-disposed provider is already gone - and Undo fails silently, which
  /// is the worst possible outcome for a destructive action. There is no state
  /// here to leak, so keeping it costs nothing.
  WordActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordActionsHash();

  @$internal
  @override
  WordActions create() => WordActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$wordActionsHash() => r'ae174369431a7074de6f9cf0999d94353772b6bf';

/// Actions the words list and detail screens take on a word.
///
/// Exists so `presentation/` never reaches into a repository itself
/// (`docs/RULES.md` §20) - and so soft delete, Undo and the purge live
/// together, where the 30-day retention rule is visible in one place.
///
/// **Kept alive deliberately.** The Undo action on the delete snackbar holds a
/// reference to this notifier and fires up to five seconds later, by which time
/// an auto-disposed provider is already gone - and Undo fails silently, which
/// is the worst possible outcome for a destructive action. There is no state
/// here to leak, so keeping it costs nothing.

abstract class _$WordActions extends $Notifier<void> {
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
