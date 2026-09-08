import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';

/// One row of the words list (`docs/UI-UX.md` §4.1, F-040).
///
/// 72dp tall, whole row tappable: headword, the inline IPA with the user's
/// highlight colours rendered, and a note count on the right.
class WordTile extends StatelessWidget {
  /// Creates a row for [entry].
  const new({
    required this.entry,
    required this.onTap,
    this.onToggleFavourite,
    this.onDelete,
    super.key,
  });

  /// The word, its note count and its highlights.
  final WordListEntry entry;

  /// Opens the word.
  final VoidCallback onTap;

  /// Toggles the star (F-044). Null hides the button.
  final VoidCallback? onToggleFavourite;

  /// Soft-deletes the word (F-008). Null hides the option.
  ///
  /// Reached by long-press. `docs/UI-UX.md` §1 forbids hiding anything behind
  /// a gesture alone, so the same action also lives in the word detail menu -
  /// this is the shortcut, not the only way.
  final VoidCallback? onDelete;

  /// The row height from the spec.
  static const double height = 72;

  Future<void> _showActions(BuildContext context, AppL10n l10n) async {
    final chosen = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.deleteWordAction),
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
    if (chosen ?? false) onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final word = entry.word;
    final ipa = word.preferredIpa;

    return InkWell(
      onTap: onTap,
      onLongPress: onDelete == null ? null : () => _showActions(context, l10n),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      word.headword.value,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ipa != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      IpaText(
                        ipa: ipa.value,
                        highlights: entry.highlights,
                        style: context.type.ipaInline,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.noteCount > 0) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                _NoteCount(count: entry.noteCount),
              ],
              if (onToggleFavourite != null)
                IconButton(
                  icon: Icon(
                    word.isFavourite ? Icons.star : Icons.star_border,
                    color: word.isFavourite
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.outline,
                  ),
                  tooltip: word.isFavourite
                      ? l10n.wordUnfavouriteLabel(word.headword.value)
                      : l10n.wordFavouriteLabel(word.headword.value),
                  onPressed: onToggleFavourite,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The note-count badge on the right of a row.
class _NoteCount extends StatelessWidget {
  const new({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Semantics(
      label: l10n.wordNoteCountLabel(count),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.sticky_note_2_outlined,
              size: AppSpacing.lg,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$count',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
