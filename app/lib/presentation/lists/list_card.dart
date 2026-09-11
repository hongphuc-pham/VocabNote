import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// One card in the lists grid (`docs/UI-UX.md` §4.5, F-042).
///
/// Name, word count, and a due-today badge when there is anything due.
///
/// The colour is a wash, not a fill: `IpaPalette` gives a translucent tint and
/// an opaque line per token, and the card uses the tint as its background with
/// the line as a left edge. A solid fill would put the list name on five
/// different backgrounds and there is no on-colour that stays readable across
/// all of them in both themes.
class ListCard extends StatelessWidget {
  /// Creates a card for [summary].
  const new({
    required this.summary,
    required this.onTap,
    required this.onActions,
    super.key,
  });

  /// The list and its counts.
  final WordListSummary summary;

  /// Opens the list.
  final VoidCallback onTap;

  /// Opens rename / recolour / delete.
  ///
  /// Reached by long-press *and* by a visible button: `docs/UI-UX.md` §1
  /// forbids an action that only a gesture can reach.
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final colors = context.ipaPalette.resolve(summary.list.color);

    return Material(
      color: colors.fill,
      borderRadius: metrics.cardBorder,
      child: InkWell(
        onTap: onTap,
        onLongPress: onActions,
        borderRadius: metrics.cardBorder,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: metrics.cardBorder,
            border: Border(
              left: BorderSide(color: colors.line, width: metrics.spaceXs),
            ),
          ),
          padding: EdgeInsets.all(metrics.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      summary.list.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    tooltip: l10n.listActionsLabel(summary.list.name),
                    onPressed: onActions,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                l10n.listWordCount(summary.wordCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (summary.dueCount > 0) ...<Widget>[
                const VnGap(VnSpace.sm),
                _DueBadge(count: summary.dueCount, line: colors.line),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The due-today badge. Only drawn when something is actually due.
class _DueBadge extends StatelessWidget {
  const new({required this.count, required this.line});

  final int count;
  final Color line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(metrics.radiusPill),
        border: Border.all(color: line),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.spaceSm,
          vertical: metrics.spaceXs / 2,
        ),
        child: Text(
          l10n.listDueCount(count),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
