/// The guide's illustrations (F-071, `docs/UI-UX.md` §4.10).
///
/// Small static mock-ups of the real controls, built from the app's own
/// widgets and theme rather than images: they follow light and dark, grow
/// with the text size, and need no asset or package. They are decorative -
/// the card's sentence says what they show - so the card wraps each in
/// `ExcludeSemantics`.
library;

import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';

/// Card 1: a word being typed, and the add button.
class AddWordIllustration extends StatelessWidget {
  /// Creates the illustration.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;
    final scheme = theme.colorScheme;

    return Row(
      spacing: metrics.spaceSm,
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: metrics.spaceMd,
              vertical: metrics.spaceSm,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outline),
              borderRadius: metrics.chipBorder,
            ),
            child: Text(
              AppL10n.of(context).guideSampleWord,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        DecoratedBox(
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: scheme.primaryContainer,
          ),
          child: Padding(
            padding: EdgeInsets.all(metrics.spaceSm),
            child: Icon(Icons.add, color: scheme.onPrimaryContainer),
          ),
        ),
      ],
    );
  }
}

/// Card 2: the dictionary's suggestion chips.
class LookupIllustration extends StatelessWidget {
  /// Creates the illustration.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;

    return Wrap(
      spacing: metrics.spaceSm,
      runSpacing: metrics.spaceSm,
      children: <Widget>[
        Chip(label: IpaText(ipa: l10n.guideSampleIpa)),
        Chip(label: Text(l10n.guideSamplePartOfSpeech)),
        Chip(
          label: Text(
            l10n.guideSampleDefinition,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Card 3: keys from the IPA symbol row above the keyboard.
class IpaKeysIllustration extends StatelessWidget {
  /// Creates the illustration.
  const new({super.key});

  /// A few of the row's 21 symbols - the ones no phone keyboard has.
  static const List<String> _symbols = <String>['ə', 'ʃ', 'θ', 'ŋ', 'ː'];

  @override
  Widget build(BuildContext context) {
    final metrics = context.metrics;
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: metrics.spaceXs,
      runSpacing: metrics.spaceXs,
      children: <Widget>[
        for (final symbol in _symbols)
          Container(
            constraints: BoxConstraints(
              minWidth: metrics.spaceXxl,
              minHeight: metrics.spaceXxl,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: metrics.chipBorder,
            ),
            child: IpaText(ipa: symbol, showSlashes: false),
          ),
      ],
    );
  }
}

/// Card 4: a transcription with one sound highlighted and labelled.
class HighlightIllustration extends StatelessWidget {
  /// Creates the illustration.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.metrics.spaceXs,
      children: <Widget>[
        IpaText(
          ipa: l10n.guideSampleIpa,
          // The vowel: the sound learners of "cough" most often miss.
          highlights: <IpaHighlight>[
            IpaHighlight(
              id: 'guide',
              wordId: 'guide',
              target: HighlightTarget.ipaUk,
              range: GraphemeRange(1, 2),
              color: IpaColorToken.coral,
              createdAt: DateTime.utc(2026),
            ),
          ],
        ),
        Text(l10n.guideSampleHighlightLabel, style: theme.textTheme.labelLarge),
      ],
    );
  }
}

/// Card 5: a note of the user's own.
class NoteIllustration extends StatelessWidget {
  /// Creates the illustration.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;

    return Container(
      padding: EdgeInsets.all(metrics.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: metrics.cardBorder,
      ),
      child: Text(
        AppL10n.of(context).guideSampleNote,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

/// Card 6: the daily goal ring, part-way round.
class PractiseIllustration extends StatelessWidget {
  /// Creates the illustration.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;

    return Row(
      spacing: metrics.spaceMd,
      children: <Widget>[
        SizedBox.square(
          dimension: metrics.minTouchTarget,
          // Determinate, so it is still: nothing for reduce-motion to stop.
          child: CircularProgressIndicator(
            value: 0.6,
            strokeWidth: metrics.spaceXs,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        Flexible(
          child: Text(
            AppL10n.of(context).guideSampleGoal,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
