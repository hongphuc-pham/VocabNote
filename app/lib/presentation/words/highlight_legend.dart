import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

/// The labels under the transcription (`docs/UI-UX.md` §4.3, F-024).
///
/// `── amber: I say /f/ too softly ───`. Tapping a line points back at the run
/// it marks, which is the only way to tell two highlights of different colours
/// apart when the labels alone are ambiguous.
///
/// **The colour name is written out.** Colour is never the only thing carrying
/// meaning (F-093): a user who cannot distinguish teal from blue reads which is
/// which, and a screen reader announces it.
///
/// Only labelled highlights appear. An unlabelled one is a colour the user put
/// on a sound without saying why, and a legend line reading just "violet" would
/// be noise.
class HighlightLegend extends StatelessWidget {
  /// Creates the legend for [highlights].
  const new({
    required this.highlights,
    required this.onJumpTo,
    this.emphasised,
    super.key,
  });

  /// Every highlight on the word, both transcriptions. Filtered here.
  final List<IpaHighlight> highlights;

  /// Called with the highlight whose run should be pointed at.
  final void Function(IpaHighlight highlight) onJumpTo;

  /// The highlight currently being pointed at, if any.
  final IpaHighlight? emphasised;

  /// The name of a colour token, as text.
  static String colorName(AppL10n l10n, IpaColorToken token) => switch (token) {
    IpaColorToken.amber => l10n.ipaColorAmber,
    IpaColorToken.coral => l10n.ipaColorCoral,
    IpaColorToken.violet => l10n.ipaColorViolet,
    IpaColorToken.teal => l10n.ipaColorTeal,
    IpaColorToken.blue => l10n.ipaColorBlue,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    final labelled =
        highlights
            .where((highlight) => (highlight.label ?? '').trim().isNotEmpty)
            .toList()
          // Left to right, matching the order the colours appear in the
          // transcription, so reading the legend tracks reading the IPA.
          ..sort((a, b) => a.range.compareTo(b.range));

    if (labelled.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.detailLegendHeading, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        for (final highlight in labelled)
          _LegendLine(
            highlight: highlight,
            isEmphasised: highlight.id == emphasised?.id,
            onTap: () => onJumpTo(highlight),
          ),
      ],
    );
  }
}

/// One legend line: a swatch, the colour name and the user's label.
class _LegendLine extends StatelessWidget {
  const new({
    required this.highlight,
    required this.isEmphasised,
    required this.onTap,
  });

  final IpaHighlight highlight;
  final bool isEmphasised;
  final VoidCallback onTap;

  /// The minimum touch target (F-093).
  static const double _minHeight = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final colors = context.ipaPalette.resolve(highlight.color);
    final label = highlight.label!.trim();
    final name = HighlightLegend.colorName(l10n, highlight.color);

    return Semantics(
      button: true,
      label: l10n.detailLegendJumpLabel(label),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: _minHeight),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: <Widget>[
                // The swatch repeats what the name says, rather than replacing
                // it. Both cues, never one.
                Container(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  decoration: BoxDecoration(
                    color: colors.fill,
                    border: Border.all(color: colors.line, width: 2),
                    borderRadius: BorderRadius.circular(AppRadii.chip / 3),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.detailLegendEntry(name, label),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isEmphasised ? FontWeight.w700 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
