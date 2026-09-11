import 'package:flutter/material.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';

/// The transcription as individually hit-testable chips (`UI-UX.md` §4.4).
///
/// One chip per **grapheme cluster** — never per code unit — which is what
/// makes it impossible to select half of `t͡ʃ` or orphan a length mark
/// (ADR-006, RULES §21). The chips arrive pre-split; this widget only lays
/// them out and reports indices back.
///
/// Three ways to select, all driving the same two callbacks:
///
/// * tap a chip — selects it;
/// * tap a second chip — extends the run to cover both;
/// * drag across — the fast path, same [onExtendTo] the second tap uses.
///
/// The drag is a convenience, never the only route: `docs/UI-UX.md` §1 forbids
/// hiding an action behind a gesture, and a screen-reader user cannot pan.
class IpaChipRow extends StatefulWidget {
  /// Creates the chip row.
  const new({
    required this.chips,
    required this.highlights,
    required this.selection,
    required this.onSelectAt,
    required this.onExtendTo,
    super.key,
  });

  /// One grapheme cluster per entry.
  final List<String> chips;

  /// The highlights currently on this transcription.
  final List<IpaHighlight> highlights;

  /// The selected run, or null.
  final GraphemeRange? selection;

  /// Starts a selection at one chip.
  final void Function(int index) onSelectAt;

  /// Extends the selection to one chip.
  final void Function(int index) onExtendTo;

  /// The minimum touch target (F-093, `UI-UX.md` §4.4: "generous spacing so a
  /// fingertip can land on one symbol").
  static const double chipSize = 48;

  @override
  State<IpaChipRow> createState() => _IpaChipRowState();
}

class _IpaChipRowState extends State<IpaChipRow> {
  /// One key per chip, so a drag can ask where each one actually is.
  final List<GlobalKey> _keys = <GlobalKey>[];

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  @override
  void didUpdateWidget(IpaChipRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chips.length != widget.chips.length) _syncKeys();
  }

  void _syncKeys() {
    _keys
      ..clear()
      ..addAll(
        List<GlobalKey>.generate(widget.chips.length, (_) => GlobalKey()),
      );
  }

  /// Which chip sits under [globalPosition], or null between them.
  int? _chipAt(Offset globalPosition) {
    for (var i = 0; i < _keys.length; i++) {
      final box = _keys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final local = box.globalToLocal(globalPosition);
      if (local.dx >= 0 &&
          local.dy >= 0 &&
          local.dx <= box.size.width &&
          local.dy <= box.size.height) {
        return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // The drag lives on the parent rather than on each chip: a pan that
      // started on one chip has to keep reporting once the finger is over the
      // next one, which a per-chip recogniser cannot see.
      onPanStart: (details) {
        final index = _chipAt(details.globalPosition);
        if (index != null) widget.onSelectAt(index);
      },
      onPanUpdate: (details) {
        final index = _chipAt(details.globalPosition);
        if (index != null) widget.onExtendTo(index);
      },
      child: Wrap(
        spacing: context.metrics.spaceXs,
        runSpacing: context.metrics.spaceXs,
        children: <Widget>[
          for (var i = 0; i < widget.chips.length; i++)
            _Chip(
              key: _keys[i],
              symbol: widget.chips[i],
              index: i,
              isSelected: widget.selection?.contains(i) ?? false,
              highlight: _winnerAt(i),
              onTap: () => widget.selection == null
                  ? widget.onSelectAt(i)
                  // A second tap extends, which is how the whole flow stays
                  // reachable without a drag.
                  : widget.onExtendTo(i),
            ),
        ],
      ),
    );
  }

  /// The highlight painted on chip [index] — the newest one covering it, which
  /// is what `IpaText` shows too (`UI-UX.md` §4.4: the newest wins visually).
  IpaHighlight? _winnerAt(int index) {
    IpaHighlight? winner;
    for (final highlight in widget.highlights) {
      if (highlight.range.contains(index)) {
        if (winner == null || highlight.createdAt.isAfter(winner.createdAt)) {
          winner = highlight;
        }
      }
    }
    return winner;
  }
}

/// One symbol, big enough to hit.
class _Chip extends StatelessWidget {
  const new({
    required this.symbol,
    required this.index,
    required this.isSelected,
    required this.highlight,
    required this.onTap,
    super.key,
  });

  final String symbol;
  final int index;
  final bool isSelected;
  final IpaHighlight? highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.ipaPalette;
    final colors = highlight == null ? null : palette.resolve(highlight!.color);

    return Semantics(
      button: true,
      selected: isSelected,
      // The raw symbol. M7 replaces this with spoken symbol names; until then
      // announcing the glyph beats announcing nothing.
      label: symbol,
      child: ExcludeSemantics(
        child: GestureDetector(
          // Opaque so the whole 48dp lands, not just the glyph inside it.
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: IpaChipRow.chipSize,
            height: IpaChipRow.chipSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors?.fill,
              borderRadius: BorderRadius.circular(context.metrics.radiusChip),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : colors?.line ?? theme.colorScheme.outlineVariant,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Text(symbol, style: context.type.ipaLarge),
          ),
        ),
      ),
    );
  }
}
