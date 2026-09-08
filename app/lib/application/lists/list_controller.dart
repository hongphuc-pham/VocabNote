import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/domain/entities/word_list.dart';

part 'list_controller.g.dart';

/// Every list with its word and due counts (F-042).
///
/// Used by the lists grid (M4) and, from M2, by the filter chips row - the
/// user's lists appear as chips after the four fixed ones.
///
/// Converts the repository's `Result` into Riverpod's `AsyncValue`, which is
/// the presentation layer's own success-or-failure type.
@riverpod
Stream<List<WordListSummary>> listSummaries(Ref ref) {
  return ref
      .watch(listRepositoryProvider)
      .watchLists()
      .map(
        (result) => result.fold((lists) => lists, (failure) => throw failure),
      );
}

/// Which lists a given word belongs to - drives the selected chips on the
/// add/edit form.
@riverpod
Stream<List<String>> listIdsForWord(Ref ref, String wordId) {
  return ref
      .watch(listRepositoryProvider)
      .watchListIdsForWord(wordId)
      .map((result) => result.fold((ids) => ids, (failure) => throw failure));
}
