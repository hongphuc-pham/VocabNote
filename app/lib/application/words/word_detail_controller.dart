/// What the word detail screen shows (`docs/UI-UX.md` §4.3).
library;

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/utils/combine_latest.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_note.dart';

part 'word_detail_controller.g.dart';

/// A word with everything the detail screen renders around it.
///
/// One object rather than three separately-watched providers so the screen
/// cannot paint a word beside another word's highlights for a frame.
@immutable
class WordDetail {
  /// Creates a snapshot.
  const new({
    required this.word,
    required this.highlights,
    required this.notes,
  });

  /// The word itself.
  final Word word;

  /// Every highlight on it, both transcriptions.
  final List<IpaHighlight> highlights;

  /// Its notes, pinned first.
  final List<WordNote> notes;

  /// The highlights that apply to one transcription.
  ///
  /// Filtered here rather than in the widget so the two IPA rows cannot
  /// disagree about which colours belong to which accent.
  List<IpaHighlight> highlightsFor(HighlightTarget target) =>
      highlights.where((highlight) => highlight.target == target).toList();
}

/// Watches one word and everything hanging off it.
///
/// Emits null once the word is gone — soft-deleted from the list screen while
/// this one is open, or purged — so the screen can say so rather than showing
/// a stale copy of something the user just deleted.
///
/// The three streams are joined with [combineLatest3] at this layer. Riverpod 3
/// removed `StreamProvider.stream`, so combining by reaching into other
/// providers is no longer possible even where it was once tempting; this is
/// also exactly how `WordRepositoryImpl.watchWords` composes the list screen.
@riverpod
Stream<WordDetail?> wordDetail(Ref ref, String wordId) {
  final repository = ref.watch(wordRepositoryProvider);

  return combineLatest3(
    repository.watchWord(wordId),
    repository.watchHighlights(wordId),
    repository.watchNotes(wordId),
    (wordResult, highlightResult, noteResult) {
      // Any of the three failing is failure for the whole screen: a word shown
      // without its highlights would silently misrepresent the user's work.
      final word = wordResult.fold(
        (value) => value,
        (failure) => throw failure,
      );
      // `watchById` deliberately still returns a soft-deleted row, because
      // Undo has to be able to find it (`words_dao.dart`). The detail screen
      // is not Undo: showing a word the user just deleted, editable and
      // speakable, would be a lie about what is in their list.
      if (word == null || word.isDeleted) return null;

      return WordDetail(
        word: word,
        highlights: highlightResult.fold(
          (value) => value,
          (failure) => throw failure,
        ),
        notes: noteResult.fold((value) => value, (failure) => throw failure),
      );
    },
  );
}
