import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// One card in the words list (`docs/UI-UX.md` §4.1, F-040).
///
/// A tonal card, whole card tappable: the headword with its part of speech, the
/// transcription labelled with the accent it actually is, rendered with the
/// user's highlight colours, and a note count.
///
/// It was a flat 72dp row until the Phonetic Naturalist restyle. A card gives
/// the transcription room to breathe, which matters more here than in a
/// general-purpose list: the IPA is the content, not a subtitle.
///
/// Deliberately **no play button**, though the design draws one and
/// `SpeechService` could serve it. Playback from the list is not in
/// `FEATURES.md`, and a restyle is not where a feature gets added.
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

    final metrics = context.metrics;
    // The accent is named rather than guessed: `preferredIpa` falls back to US,
    // so an unlabelled transcription here could silently be either.
    final accent = word.ipaUk != null
        ? l10n.detailAccentUk
        : l10n.detailAccentUs;

    return Padding(
      padding: EdgeInsets.only(bottom: metrics.spaceMd),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: metrics.cardBorder,
        child: InkWell(
          onTap: onTap,
          onLongPress: onDelete == null
              ? null
              : () => _showActions(context, l10n),
          borderRadius: metrics.cardBorder,
          child: Padding(
            padding: EdgeInsets.all(metrics.spaceLg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _Headword(
                        headword: word.headword.value,
                        partOfSpeech: word.partOfSpeech,
                      ),
                      if (ipa != null) ...<Widget>[
                        const VnGap(VnSpace.sm),
                        _Transcription(
                          accent: accent,
                          ipa: ipa.value,
                          highlights: entry.highlights,
                        ),
                      ],
                      if (entry.noteCount > 0) ...<Widget>[
                        const VnGap(VnSpace.sm),
                        _NoteCount(count: entry.noteCount),
                      ],
                    ],
                  ),
                ),
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
      ),
    );
  }
}

/// The headword, with its part of speech as a quiet badge beside it.
class _Headword extends StatelessWidget {
  const new({required this.headword, this.partOfSpeech});

  final String headword;
  final String? partOfSpeech;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Flexible(
          child: Text(
            headword,
            style: theme.textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // The badge is Flexible too, not just the headword. With only the
        // headword flexible, a long word beside a long part of speech
        // overflowed by 74px at 200% text on a 320dp screen - both of which
        // `docs/UI-UX.md` §6 requires to work. Two loose Flexibles means each
        // takes its intrinsic width when it fits and ellipsises when it does
        // not, so neither can push the other off the card.
        if (partOfSpeech case final String pos when pos.isNotEmpty) ...<Widget>[
          const VnGap(VnSpace.sm, axis: Axis.horizontal),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.spaceSm,
                vertical: metrics.spaceXs / 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(metrics.radiusChip / 3),
              ),
              child: Text(
                pos,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The transcription, labelled with the accent it is.
class _Transcription extends StatelessWidget {
  const new({
    required this.accent,
    required this.ipa,
    required this.highlights,
  });

  final String accent;
  final String ipa;
  final List<IpaHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          accent,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            letterSpacing: 1,
          ),
        ),
        const VnGap(VnSpace.sm, axis: Axis.horizontal),
        Flexible(
          child: IpaText(
            ipa: ipa,
            highlights: highlights,
            style: context.type.ipaInline,
            maxLines: 1,
          ),
        ),
      ],
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
              size: context.metrics.spaceLg,
              color: theme.colorScheme.outline,
            ),
            const VnGap(VnSpace.xs, axis: Axis.horizontal),
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
