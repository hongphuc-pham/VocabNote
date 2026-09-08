import 'package:flutter/material.dart';
import 'package:vocabnote/core/extensions/grapheme.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';

/// Renders an IPA string with the user's highlights (F-022, F-024).
///
/// **The rendering rule** (`docs/UI-UX.md` §2): a highlight is a tinted
/// background plus a 2px underline in the token colour - **never** coloured
/// glyphs. The text keeps its normal on-surface colour, so contrast stays AA in
/// both themes and a colourblind user still sees the underline.
///
/// Slicing is grapheme-safe throughout (ADR-006): the string is split on
/// cluster boundaries, so a highlight can never cut a tie bar off its base
/// letter or orphan a combining diacritic.
///
/// M3 adds the large detail-screen variant and the tappable legend; this is the
/// shared renderer both use.
class IpaText extends StatelessWidget {
  /// Renders [ipa] with [highlights] applied.
  const new({
    required this.ipa,
    this.highlights = const <IpaHighlight>[],
    this.style,
    this.showSlashes = true,
    this.maxLines,
    this.semanticsLabel,
    super.key,
  });

  /// The transcription, stored without slashes.
  final String ipa;

  /// The highlights to paint. Ones that no longer fit are skipped rather than
  /// throwing - F-023 validates on read.
  final List<IpaHighlight> highlights;

  /// Base text style. Defaults to the theme's inline IPA role.
  final TextStyle? style;

  /// Whether to draw the enclosing slashes.
  ///
  /// They are fixed affixes the UI adds (`docs/UI-UX.md` §4.2), never part of
  /// the stored string and never part of a highlight offset.
  final bool showSlashes;

  /// Maximum lines before ellipsis.
  final int? maxLines;

  /// Overrides the screen-reader text.
  ///
  /// M7 replaces the default with spoken symbol names; until then the raw
  /// glyphs are announced, which at least reads as *something* rather than
  /// being silently skipped.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.ipaPalette;
    final baseStyle =
        style ??
        theme.textTheme.bodyLarge?.copyWith(fontFamily: 'Charis SIL') ??
        const TextStyle();

    if (ipa.isEmpty) return const SizedBox.shrink();

    final affixStyle = baseStyle.copyWith(color: theme.colorScheme.outline);

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          if (showSlashes) TextSpan(text: '/', style: affixStyle),
          ..._buildSpans(baseStyle, palette),
          if (showSlashes) TextSpan(text: '/', style: affixStyle),
        ],
      ),
      style: baseStyle,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      semanticsLabel: semanticsLabel ?? _defaultSemantics(),
    );
  }

  String _defaultSemantics() => showSlashes ? 'pronunciation $ipa' : ipa;

  /// Splits the string at every highlight boundary and styles each run.
  ///
  /// Overlaps are allowed (`docs/UI-UX.md` §4.4). Where two highlights cover
  /// the same symbol the newest wins visually, which is why the applicable
  /// highlights are sorted by creation time and the last one is used.
  List<InlineSpan> _buildSpans(TextStyle baseStyle, IpaPalette palette) {
    final length = ipa.graphemeLength;

    // Only highlights that still fit this exact string. A stale range is
    // skipped rather than clamped: showing a colour on the wrong symbols would
    // be worse than showing none.
    final applicable =
        highlights.where((highlight) => highlight.fits(length)).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (applicable.isEmpty) {
      return <InlineSpan>[TextSpan(text: ipa)];
    }

    // Every boundary any highlight starts or ends at, so each run is uniform.
    final boundaries = <int>{0, length};
    for (final highlight in applicable) {
      boundaries
        ..add(highlight.range.start)
        ..add(highlight.range.end);
    }
    final cuts = boundaries.toList()..sort();

    final spans = <InlineSpan>[];
    for (var i = 0; i < cuts.length - 1; i++) {
      final start = cuts[i];
      final end = cuts[i + 1];
      if (end <= start) continue;

      // Grapheme-safe: never a code-unit substring.
      final text = ipa.graphemeSubstring(start, end);

      // The newest highlight covering this run wins.
      IpaHighlight? winner;
      for (final highlight in applicable) {
        if (highlight.range.start <= start && highlight.range.end >= end) {
          winner = highlight;
        }
      }

      if (winner == null) {
        spans.add(TextSpan(text: text));
        continue;
      }

      final colors = palette.resolve(winner.color);
      spans.add(
        TextSpan(
          text: text,
          style: baseStyle.copyWith(
            // Background tint and underline only. The glyph colour is
            // deliberately left alone.
            backgroundColor: colors.fill,
            decoration: TextDecoration.underline,
            decorationColor: colors.line,
            decorationThickness: IpaPalette.underlineThickness,
          ),
        ),
      );
    }
    return spans;
  }
}
