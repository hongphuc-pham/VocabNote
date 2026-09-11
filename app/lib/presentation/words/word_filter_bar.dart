import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/words/word_list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';
import 'package:vocabnote/presentation/design/gap.dart';

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
    // Null while it loads, which is the point: a chip that briefly reads "0"
    // would say something false about the user's library.
    final total = ref.watch(totalWordCountProvider).value;

    bool isSelected(WordFilter filter, {String? listId}) =>
        query.filter == filter &&
        (filter != WordFilter.inList || query.listId == listId);

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.metrics.spaceLg),
        children: <Widget>[
          for (final (filter, label, count) in <(WordFilter, String, int?)>[
            // Only the chips whose count is already a stream get one. Counting
            // favourites, due-today or no-IPA means three new queries, which is
            // feature work rather than restyling - see the plan's anti-goals.
            (WordFilter.all, l10n.filterAll, total),
            (WordFilter.favourites, l10n.filterFavourites, null),
            (WordFilter.dueToday, l10n.filterDueToday, null),
            (WordFilter.noIpa, l10n.filterNoIpa, null),
          ])
            Padding(
              padding: EdgeInsets.only(right: context.metrics.spaceSm),
              child: _FilterPill(
                label: label,
                count: count,
                selected: isSelected(filter),
                onSelected: () => controller.setFilter(filter),
              ),
            ),
          for (final summary in lists)
            Padding(
              padding: EdgeInsets.only(right: context.metrics.spaceSm),
              child: _FilterPill(
                label: summary.list.name,
                count: summary.wordCount,
                selected: isSelected(
                  WordFilter.inList,
                  listId: summary.list.id,
                ),
                onSelected: () => controller.setFilter(
                  WordFilter.inList,
                  listId: summary.list.id,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One filter pill, with an optional count badge.
///
/// The count sits inside the chip's label so the pill sizes to both.
///
/// Announcing it takes care. "All" and "142" as two adjacent strings is not a
/// sentence, so the visible label carries a `semanticsLabel` that reads "All,
/// 142 words" and the badge itself is excluded to avoid saying the number
/// twice. What must **not** happen is wrapping the whole chip in
/// `ExcludeSemantics` to achieve that - it strips the chip's button role and
/// its tap action, which `docs/UI-UX.md` §6 makes a blocking failure.
class _FilterPill extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.count,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final tint = selected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return FilterChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      // Filters are pills, per the shape scale.
      shape: const StadiumBorder(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            semanticsLabel: count == null
                ? null
                : l10n.filterCountLabel(label, count!),
          ),
          if (count case final int value) ...<Widget>[
            const VnGap(VnSpace.sm, axis: Axis.horizontal),
            ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // A tint of the label colour, so the badge belongs to the
                  // pill in both the selected and unselected states.
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(metrics.radiusPill),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: metrics.spaceSm),
                  child: Text(
                    '$value',
                    style: theme.textTheme.labelSmall?.copyWith(color: tint),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
