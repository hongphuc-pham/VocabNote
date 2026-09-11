import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/presentation/common/ipa_speech.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// The IPA symbol row docked above the keyboard (`docs/UI-UX.md` §4.2, F-002).
///
/// Manual IPA entry is a first-class path (`docs/RULES.md` §3), and no phone
/// keyboard has these symbols. Without this row, "type it yourself" would mean
/// hunting through a character picker, which nobody does twice.
///
/// The slashes are **not** here: they are fixed affixes the UI draws around the
/// field, never typed and never part of a stored value or a highlight offset.
class IpaKeyboardRow extends StatelessWidget {
  /// Creates the symbol row for [controller].
  const new({required this.controller, super.key});

  /// The field the symbols are inserted into.
  final TextEditingController controller;

  /// The symbols offered, in the order `docs/UI-UX.md` §4.2 lists them.
  ///
  /// Note `tʃ` and `dʒ` are single buttons that insert two characters each -
  /// they are one sound, and a user thinking "the ch sound" should not have to
  /// know it is written with two symbols.
  ///
  /// `F-002` lists a shorter set without `i` and `u`; §4.2 and the milestone
  /// brief both include them, so they are here.
  static const List<String> symbols = <String>[
    'ˈ', 'ˌ', 'ː', // stress and length
    'ə', 'ɜ', 'æ', 'ɑ', 'ɒ', 'ʌ', 'ʊ', 'ɪ', 'i', 'u', // vowels
    'ʃ', 'ʒ', 'tʃ', 'dʒ', 'θ', 'ð', 'ŋ', 'ɹ', // consonants
  ];

  /// Inserts [symbol] at the cursor, replacing any selection.
  ///
  /// Static and pure so the insertion logic can be tested without a widget.
  /// Returns the value the field should take.
  static TextEditingValue insert(TextEditingValue value, String symbol) {
    final selection = value.selection;

    // A field that has never been focused reports an invalid selection;
    // appending is the only sensible reading of "insert" in that case.
    if (!selection.isValid) {
      return TextEditingValue(
        text: value.text + symbol,
        selection: TextSelection.collapsed(
          offset: value.text.length + symbol.length,
        ),
      );
    }

    final text = value.text.replaceRange(
      selection.start,
      selection.end,
      symbol,
    );
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: selection.start + symbol.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Semantics(
      container: true,
      label: l10n.ipaKeyboardLabel,
      child: SizedBox(
        // Tall enough for a 48dp target plus breathing room.
        height: context.metrics.minTouchTarget + context.metrics.spaceMd,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: context.metrics.spaceMd,
            vertical: context.metrics.spaceSm,
          ),
          itemCount: symbols.length,
          separatorBuilder: (_, _) =>
              const VnGap(VnSpace.xs, axis: Axis.horizontal),
          itemBuilder: (context, index) {
            final symbol = symbols[index];
            return _SymbolButton(
              symbol: symbol,
              // "Insert ch", not "Insert t, esh": the sound, by its name.
              label: l10n.ipaSymbolLabel(spokenSymbol(l10n, symbol)),
              style: context.type.ipaInline,
              background: theme.colorScheme.surfaceContainer,
              onPressed: () {
                controller.value = insert(controller.value, symbol);
                unawaited(HapticFeedback.selectionClick());
              },
            );
          },
        ),
      ),
    );
  }
}

class _SymbolButton extends StatelessWidget {
  const new({
    required this.symbol,
    required this.label,
    required this.style,
    required this.background,
    required this.onPressed,
  });

  final String symbol;
  final String label;
  final TextStyle style;
  final Color background;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      // The label is on the text below; announced as a tooltip as well, it
      // would be read twice.
      excludeFromSemantics: true,
      child: Material(
        color: background,
        borderRadius: context.metrics.chipBorder,
        child: InkWell(
          onTap: onPressed,
          borderRadius: context.metrics.chipBorder,
          // The button must never take focus. The transcription field has it,
          // and this row is only shown *because* it does - so stealing focus
          // dismisses the row mid-word and sends the next keystroke nowhere.
          // The user taps ɒ expecting to carry on typing, not to lose the
          // field they were in.
          canRequestFocus: false,
          child: ConstrainedBox(
            // >= 48dp, including for the narrow marks like the stress bar
            // (docs/UI-UX.md §6).
            constraints: BoxConstraints(
              minWidth: context.metrics.minTouchTarget,
              minHeight: context.metrics.minTouchTarget,
            ),
            child: Center(
              // Until M7 the key's label was the glyph itself - a screen
              // reader said the symbol's shape ("turned script a") and only
              // then the tooltip. The sound's name is the label now.
              child: Text(
                symbol,
                semanticsLabel: label,
                style: style.copyWith(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
