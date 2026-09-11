/// Writing the user's own notes on a word (F-003).
library;

// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/word_note.dart';

part 'word_notes_controller.g.dart';

/// Adds, edits and removes notes.
///
/// Separate from `WordActions` because notes have their own lifetime: they are
/// the user's writing, they are indexed for search (F-041), and unlike a word
/// they are **not** soft-deleted — there is no 30-day window and no Undo beyond
/// the snackbar, which the repository interface is explicit about.
///
/// Kept alive for the same reason `WordActions` is: nothing here holds state,
/// and an action fired from a snackbar must still find its notifier alive.
@Riverpod(keepAlive: true)
class WordNotes extends _$WordNotes {
  @override
  void build() {}

  /// Adds a note to a word.
  AsyncResult<WordNote> add({required String wordId, required String body}) =>
      ref.read(wordRepositoryProvider).addNote(wordId: wordId, body: body);

  /// Saves an edited note.
  AsyncResult<void> update(WordNote note) =>
      ref.read(wordRepositoryProvider).updateNote(note);

  /// Removes a note.
  AsyncResult<void> delete(String id) =>
      ref.read(wordRepositoryProvider).deleteNote(id);
}
