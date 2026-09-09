import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/words/word_list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';

/// The filter chips row (`docs/UI-UX.md` §4.1, F-043).
///
/// `All · Favourites · Due today · No IPA yet · <list names>`.
///
/// **All** is a chip, not a stored list - which is why `word_lists` has no
/// seeded "All words" row. The user's own lists follow the four fixed chips.
class WordFilterBar extends ConsumerWidget {
  /// Creates the filter bar.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final query = ref.watch(wordListQueryProvider);
    final controller = ref.read(wordListQueryProvider.notifier);
    final lists =
        ref.watch(listSummariesProvider).value ?? const <WordListSummary>[];

    bool isSelected(WordFilter filter, {String? listId}) =>
        query.filter == filter &&
        (filter != WordFilter.inList || query.listId == listId);

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: <Widget>[
          for (final (filter, label) in <(WordFilter, String)>[
            (WordFilter.all, l10n.filterAll),
            (WordFilter.favourites, l10n.filterFavourites),
            (WordFilter.dueToday, l10n.filterDueToday),
            (WordFilter.noIpa, l10n.filterNoIpa),
          ])
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(label),
                selected: isSelected(filter),
                onSelected: (_) => controller.setFilter(filter),
                // Filters are pills, per the shape scale.
                shape: const StadiumBorder(),
              ),
            ),
          for (final summary in lists)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: Text(summary.list.name),
                selected: isSelected(
                  WordFilter.inList,
                  listId: summary.list.id,
                ),
                onSelected: (_) => controller.setFilter(
                  WordFilter.inList,
                  listId: summary.list.id,
                ),
                shape: const StadiumBorder(),
              ),
            ),
        ],
      ),
    );
  }
}
