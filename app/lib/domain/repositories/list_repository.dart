import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

/// Everything the app does with lists (decks) - F-042.
abstract interface class ListRepository {
  /// Watches every list with its word and due counts, in display order.
  ResultStream<List<WordListSummary>> watchLists();

  /// Watches one list.
  ResultStream<WordList?> watchList(String id);

  /// Creates a list, appended to the end of the current order.
  AsyncResult<WordList> createList({
    required String name,
    required IpaColorToken color,
  });

  /// Renames or recolours a list.
  AsyncResult<WordList> updateList(WordList list);

  /// Deletes a list.
  ///
  /// **Never deletes the words in it.** Only the membership rows go.
  AsyncResult<void> deleteList(String id);

  /// Writes a new display order, atomically.
  AsyncResult<void> reorder(List<String> orderedIds);

  /// Adds a word to a list. Doing it twice is not an error.
  AsyncResult<void> addWordToList({
    required String listId,
    required String wordId,
  });

  /// Removes a word from a list. The word itself is untouched.
  AsyncResult<void> removeWordFromList({
    required String listId,
    required String wordId,
  });

  /// Sets exactly which lists a word belongs to, atomically.
  AsyncResult<void> setListsForWord({
    required String wordId,
    required List<String> listIds,
  });

  /// Watches which lists a word is in - drives the selected chips.
  ResultStream<List<String>> watchListIdsForWord(String wordId);
}
