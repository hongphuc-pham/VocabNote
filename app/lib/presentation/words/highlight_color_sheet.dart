import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';
import 'package:vocabnote/presentation/words/highlight_legend.dart';

/// What the colour sheet came back with.
///
/// A deletion and a colour choice are different outcomes, and a nullable
/// colour would make them indistinguishable from "the user backed out".
@immutable
class HighlightChoice {
  /// The user picked [color], optionally with [label].
  ///
  /// Omitting [color] means a deletion — see [deletion]. A single constructor
  /// rather than a named one because `dart format` 3.13 cannot parse a named
  /// constructor that satisfies the analyzer (see `context.md`).
  const new({this.color, this.label});

  /// The user asked to delete the highlight instead of recolouring it.
  static const HighlightChoice deletion = HighlightChoice();

  /// The chosen colour, or null when this is a deletion.
  final IpaColorToken? color;

  /// The optional label, at most [IpaHighlight.maxLabelLength] characters.
  final String? label;

  /// Whether this is a deletion rather than a colour.
  bool get isDelete => color == null;
}

/// The five swatches and an optional label (`docs/UI-UX.md` §4.4).
///
/// Returns a [HighlightChoice], or null if the user dismissed it. Nothing here
/// writes anything: the editor holds the whole session in memory until *Done*.
class HighlightColorSheet extends StatefulWidget {
  /// Creates the sheet.
  const new({this.existing, super.key});

  /// The highlight being edited, when one is being recoloured rather than
  /// created. Its colour and label pre-fill the sheet, and *Delete highlight*
  /// only appears for one that already exists.
  final IpaHighlight? existing;

  /// Shows the sheet and returns what the user chose.
  static Future<HighlightChoice?> show(
    BuildContext context, {
    IpaHighlight? existing,
  }) => showModalBottomSheet<HighlightChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => HighlightColorSheet(existing: existing),
  );

  @override
  State<HighlightColorSheet> createState() => _HighlightColorSheetState();
}

class _HighlightColorSheetState extends State<HighlightColorSheet> {
  late final TextEditingController _label = TextEditingController(
    text: widget.existing?.label ?? '',
  );
  late IpaColorToken _selected = widget.existing?.color ?? IpaColorToken.amber;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _confirm() =>
      Navigator.of(context)
          .pop(HighlightChoice(color: _selected, label: _label.text));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return VnSheetBody(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(l10n.ipaEditorColorHeading, style: theme.textTheme.titleMedium),
        const VnGap(VnSpace.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (final token in IpaColorToken.values)
              _Swatch(
                token: token,
                isSelected: token == _selected,
                onTap: () => setState(() => _selected = token),
              ),
          ],
        ),
        const VnGap(VnSpace.lg),
        TextField(
          controller: _label,
          // The cap the entity documents, enforced where it is typed so the
          // user sees the limit rather than discovering it after saving.
          maxLength: IpaHighlight.maxLabelLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l10n.ipaEditorLabelHint,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _confirm(),
        ),
        const VnGap(VnSpace.sm),
        // Reflows to a column when the buttons cannot share a line: at 200%
        // on 320dp a Row of three overflowed (UI-UX §6). Delete stays apart
        // from Cancel and Save, as it was beside a Spacer.
        OverflowBar(
          alignment: widget.existing != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          overflowAlignment: OverflowBarAlignment.end,
          overflowSpacing: context.metrics.spaceSm,
          children: <Widget>[
            if (widget.existing != null)
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(HighlightChoice.deletion),
                child: Text(l10n.ipaEditorDeleteAction),
              ),
            OverflowBar(
              spacing: context.metrics.spaceSm,
              overflowAlignment: OverflowBarAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancelAction),
                ),
                FilledButton(onPressed: _confirm, child: Text(l10n.saveAction)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// One colour swatch.
class _Swatch extends StatelessWidget {
  const new({
    required this.token,
    required this.isSelected,
    required this.onTap,
  });

  final IpaColorToken token;
  final bool isSelected;
  final VoidCallback onTap;

  /// The minimum touch target (F-093).
  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final colors = context.ipaPalette.resolve(token);
    final name = HighlightLegend.colorName(l10n, token);

    return Semantics(
      button: true,
      selected: isSelected,
      // Named, so the choice is never colour-only (F-093).
      label: l10n.ipaEditorColorLabel(name),
      // The tap belongs on this node too: `ExcludeSemantics` below hides the
      // detector's own, and a button a screen reader can find but not press
      // is worse than none (found in M7).
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: colors.fill,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : colors.line,
                width: isSelected ? 4 : 2,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check, color: theme.colorScheme.onSurface)
                : null,
          ),
        ),
      ),
    );
  }
}
