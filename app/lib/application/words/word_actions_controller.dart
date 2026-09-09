// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/result.dart';

part 'word_actions_controller.g.dart';

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
@Riverpod(keepAlive: true)
class WordActions extends _$WordActions {
  @override
  void build() {}

  /// Toggles the star (F-044).
  Future<void> setFavourite(String id, {required bool isFavourite}) async {
    await ref
        .read(wordRepositoryProvider)
        .setFavourite(id, isFavourite: isFavourite);
  }

  /// Soft-deletes a word (F-008).
  ///
  /// Nothing is destroyed: `deleted_at` is set, every note, highlight and list
  /// membership survives, and the row is only really removed by [purgeExpired]
  /// 30 days later. That is what makes [restore] instant and complete.
  AsyncResult<void> delete(String id) =>
      ref.read(wordRepositoryProvider).softDelete(id);

  /// Restores a soft-deleted word - the Undo action.
  AsyncResult<void> restore(String id) =>
      ref.read(wordRepositoryProvider).restore(id);

  /// Permanently removes words soft-deleted more than 30 days ago.
  ///
  /// The only hard delete of user content in the app, and the retention window
  /// `docs/RULES.md` §10 allows. Run once at startup rather than on a timer:
  /// a purge is not urgent, and doing it while the user is mid-task would
  /// churn the database for no visible benefit.
  AsyncResult<int> purgeExpired() =>
      ref.read(wordRepositoryProvider).purgeExpired();
}
