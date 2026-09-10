/// Creating, renaming, recolouring, reordering and deleting lists (F-042).
library;

// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

part 'list_actions_controller.g.dart';

/// The write side of lists.
///
/// `listSummariesProvider` in `list_controller.dart` is the read side; this is
/// deliberately separate, so a screen that only displays lists does not depend
/// on a notifier that can delete them.
///
/// Kept alive like `WordActions` and `WordNotes`: nothing here holds state, and
/// an action fired from a snackbar must still find its notifier alive after the
/// screen that started it has gone.
@Riverpod(keepAlive: true)
class ListActions extends _$ListActions {
  @override
  void build() {}

  /// Creates a list, appended to the end of the current order.
  AsyncResult<WordList> create({
    required String name,
    required IpaColorToken color,
  }) => ref.read(listRepositoryProvider).createList(name: name, color: color);

  /// Renames a list, leaving everything else as it was.
  AsyncResult<WordList> rename(WordList list, String name) =>
      ref.read(listRepositoryProvider).updateList(list.copyWith(name: name));

  /// Recolours a list.
  AsyncResult<WordList> recolour(WordList list, IpaColorToken color) =>
      ref.read(listRepositoryProvider).updateList(list.copyWith(color: color));

  /// Deletes a list.
  ///
  /// **The words survive.** Only the membership rows go — see the cascade in
  /// `DATABASE.md` §2 and the test that holds it. This is the one operation
  /// here that could destroy the user's work if it were wrong, which is why it
  /// is spelled out at every layer that touches it.
  AsyncResult<void> delete(String id) =>
      ref.read(listRepositoryProvider).deleteList(id);

  /// Writes a new display order, atomically.
  ///
  /// Takes the whole order rather than a moved pair: a partial write would
  /// leave two lists claiming the same position, and the grid would then order
  /// them arbitrarily.
  AsyncResult<void> reorder(List<String> orderedIds) =>
      ref.read(listRepositoryProvider).reorder(orderedIds);

  /// Adds one word to one list. Doing it twice is not an error.
  ///
  /// Additive, unlike [setListsForWord]: the summary screen's "add these to a
  /// list" must not remove the missed words from lists they are already in.
  AsyncResult<void> addWordToList({
    required String listId,
    required String wordId,
  }) => ref
      .read(listRepositoryProvider)
      .addWordToList(listId: listId, wordId: wordId);

  /// Sets exactly which lists a word belongs to.
  AsyncResult<void> setListsForWord({
    required String wordId,
    required List<String> listIds,
  }) => ref
      .read(listRepositoryProvider)
      .setListsForWord(wordId: wordId, listIds: listIds);
}
