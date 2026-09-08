// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:uuid/uuid.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/words/word_draft.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';

part 'word_editor_controller.g.dart';

/// The add/edit form (`docs/UI-UX.md` §4.2, F-001, F-003, F-007).
///
/// Owns the draft, the duplicate check and saving. The screen owns text
/// controllers and focus; everything that could be got wrong lives here where
/// it can be tested without pumping a widget.
@riverpod
class WordEditor extends _$WordEditor {
  @override
  Future<WordDraft> build(String? wordId) async {
    if (wordId == null) return const WordDraft();

    final result = await ref.read(wordRepositoryProvider).getWord(wordId);
    final word = result.valueOrNull;
    if (word == null) return const WordDraft();

    final lists = await ref
        .read(listRepositoryProvider)
        .watchListIdsForWord(wordId)
        .first;

    return WordDraft.fromWord(word)
        .copyWith(listIds: lists.valueOrNull ?? const <String>[]);
  }

  /// Replaces the draft wholesale - used by the form's field callbacks.
  ///
  /// Not named `update`: AsyncNotifier already defines one.
  void setDraft(WordDraft draft) => state = AsyncData(draft);

  /// Applies [change] to the current draft, if it has loaded.
  void edit(WordDraft Function(WordDraft draft) change) {
    final current = state.value;
    if (current != null) state = AsyncData(change(current));
  }

  /// Accepts one look-up suggestion into one field (F-004).
  ///
  /// The caller is responsible for confirming first when
  /// [WordDraft.wouldOverwrite] is true; this method does the write.
  void acceptSuggestion(FieldSuggestion suggestion, WordSuggestions results) {
    edit((draft) => draft.accept(suggestion, results));
  }

  /// Records that the user typed into [field] themselves.
  void markFieldManual(SuggestionField field) {
    edit((draft) => draft.markManual(field));
  }

  /// Looks for an existing word with the same normalised headword.
  ///
  /// Non-blocking by design (F-001): the caller shows "You already have X -
  /// open it?" as a banner and still lets the user save. Returns null when
  /// there is no clash, or when the clash is the word being edited.
  Future<Word?> findDuplicate(String headword) async {
    final result = await ref
        .read(wordRepositoryProvider)
        .findDuplicate(headword);
    final existing = result.valueOrNull;
    if (existing == null) return null;

    // Editing a word is not a clash with itself.
    if (existing.id == state.value?.id) return null;
    return existing;
  }

  /// Saves the draft.
  ///
  /// Creating also writes the `study_cards` row and any first note, in one
  /// transaction - a word without a card would be invisible to practice.
  AsyncResult<Word> save() async {
    final draft = state.value;
    if (draft == null || !draft.canSave) {
      return const Err<Word, AppFailure>(
        ValidationFailure(field: 'headword', reason: 'required'),
      );
    }

    final repository = ref.read(wordRepositoryProvider);
    final now = DateTime.now();
    final word = draft.toWord(id: const Uuid().v4(), now: now);

    if (draft.isEditing) {
      final result = await repository.updateWord(word);
      if (result.isOk) {
        await ref
            .read(listRepositoryProvider)
            .setListsForWord(wordId: word.id, listIds: draft.listIds);
      }
      return result;
    }

    return await repository.createWord(
      word: word,
      listIds: draft.listIds,
      firstNote: draft.firstNote,
    );
  }
}
