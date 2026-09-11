import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_note.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';

/// A word plus the bits the list row needs, fetched together.
///
/// The words screen shows a note count and inline highlighted IPA on every
/// row; loading those per row would be one query per visible word.
class WordListEntry {
  /// Creates an entry.
  const new({
    required this.word,
    required this.noteCount,
    required this.highlights,
  });

  /// The word.
  final Word word;

  /// How many notes it has.
  final int noteCount;

  /// Its highlights, for rendering the inline IPA in colour.
  final List<IpaHighlight> highlights;
}

/// Everything the app does with words.
///
/// Exposes domain entities only - never Drift row classes
/// (`docs/RULES.md` §25) - and returns [Result] rather than throwing (§24).
abstract interface class WordRepository {
  /// Watches the word list for [query].
  ResultStream<List<WordListEntry>> watchWords(WordQuery query);

  /// Watches one word, or null once it is deleted.
  ResultStream<Word?> watchWord(String id);

  /// Reads one word.
  AsyncResult<Word?> getWord(String id);

  /// Finds a live word with the same normalised headword.
  ///
  /// Powers the non-blocking duplicate banner (F-001). Returns `Ok(null)` when
  /// there is no clash - not finding a duplicate is a success, not a failure.
  AsyncResult<Word?> findDuplicate(String headword);

  /// Creates a word and its study card in one transaction.
  ///
  /// The card is part of creating a word, not a later step: a word with no
  /// card would be invisible to practice until something noticed and fixed it.
  AsyncResult<Word> createWord({
    required Word word,
    List<String> listIds,
    String? firstNote,
  });

  /// Saves changes to an existing word.
  ///
  /// Does not touch highlights: an IPA edit re-validates them separately
  /// (F-023), because dropping a user's colours needs a confirmation first.
  AsyncResult<Word> updateWord(Word word);

  /// Toggles the star (F-044).
  AsyncResult<void> setFavourite(String id, {required bool isFavourite});

  /// Soft-deletes a word, leaving it recoverable by Undo (F-008).
  AsyncResult<void> softDelete(String id);

  /// Restores a soft-deleted word - the Undo action.
  AsyncResult<void> restore(String id);

  /// Permanently removes words deleted more than 30 days ago.
  ///
  /// Returns how many were purged. The only hard delete in the app.
  AsyncResult<int> purgeExpired({
    Duration retention = const Duration(days: 30),
  });

  /// Watches how many live words there are.
  ResultStream<int> watchWordCount();

  /// Watches the notes on one word, pinned first.
  ResultStream<List<WordNote>> watchNotes(String wordId);

  /// Adds a note.
  AsyncResult<WordNote> addNote({required String wordId, required String body});

  /// Edits a note's body or pinned state.
  AsyncResult<void> updateNote(WordNote note);

  /// Deletes a note. Notes are not soft-deleted.
  AsyncResult<void> deleteNote(String id);

  /// Watches every highlight on one word.
  ResultStream<List<IpaHighlight>> watchHighlights(String wordId);

  /// Reads every highlight on one word, once.
  ///
  /// For callers that need the current set to make a decision rather than to
  /// render — F-023's re-validation on an IPA edit, chiefly. Subscribing to a
  /// stream just to take its first event would wait on Drift's delivery timer
  /// for no reason.
  AsyncResult<List<IpaHighlight>> getHighlights(String wordId);

  /// Replaces the highlights for one transcription, atomically.
  ///
  /// What *Done* in the highlight editor commits. Scoped to one target, so
  /// saving UK highlights never disturbs US ones.
  AsyncResult<void> replaceHighlights({
    required String wordId,
    required HighlightTarget target,
    required List<IpaHighlight> highlights,
  });
}
