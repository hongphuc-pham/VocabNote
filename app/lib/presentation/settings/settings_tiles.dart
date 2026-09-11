import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';

/// The heading above a group of settings.
///
/// Announced as a heading, so a screen-reader user can jump between the
/// sections of a long list instead of swiping through every row.
class SettingsHeader extends StatelessWidget {
  /// Creates the heading.
  const new(this.text, {super.key});

  /// What the section is called.
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.spaceLg,
        metrics.spaceLg,
        metrics.spaceLg,
        metrics.spaceSm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// A setting chosen from a short list: its name, and the current choice
/// beneath it. Tapping opens the list.
///
/// A row and a dialog rather than a segmented control, because three long
/// labels side by side do not survive 200% text on a 320dp phone
/// (`docs/UI-UX.md` §6), and because a list has room to say what each choice
/// means.
class SettingsChoiceTile<T> extends StatelessWidget {
  /// Creates the tile.
  const new({
    required this.title,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    this.hintOf,
    super.key,
  });

  /// What the setting is.
  final String title;

  /// The current choice. May be outside [options] - a table of the user's
  /// own is no preset - in which case nothing in the list is selected.
  final T value;

  /// What can be chosen.
  final List<T> options;

  /// How a choice is named.
  final String Function(T option) labelOf;

  /// An optional line explaining a choice.
  final String? Function(T option)? hintOf;

  /// Called with a new choice. Not called when the list is dismissed or the
  /// current choice is picked again.
  final ValueChanged<T> onChanged;

  Future<void> _choose(BuildContext context) async {
    final picked = await showDialog<_Picked<T>>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: <Widget>[
          RadioGroup<T>(
            groupValue: value,
            onChanged: (option) =>
                Navigator.of(context).pop(_Picked<T>(option as T)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final option in options)
                  RadioListTile<T>(
                    value: option,
                    title: Text(labelOf(option)),
                    subtitle: switch (hintOf?.call(option)) {
                      final String hint => Text(hint),
                      null => null,
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    // Wrapped, so a legitimately null choice is not mistaken for a dismissal.
    if (picked != null && picked.option != value) onChanged(picked.option);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(labelOf(value)),
      onTap: () => unawaited(_choose(context)),
    );
  }
}

/// A choice made in a [SettingsChoiceTile]'s dialog.
final class _Picked<T> {
  const new(this.option);

  final T option;
}

/// A setting on a continuous scale, shown as a multiple of normal.
///
/// Saves once, when the thumb is released - not on every step of a drag,
/// which would be a burst of writes for one decision.
class SettingsSliderTile extends StatefulWidget {
  /// Creates the tile.
  const new({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.normal,
    required this.onChangeEnd,
    super.key,
  });

  /// What the setting is.
  final String title;

  /// The stored value.
  final double value;

  /// The lowest value the slider offers.
  final double min;

  /// The highest value the slider offers.
  final double max;

  /// How many steps between [min] and [max].
  final int divisions;

  /// The value that counts as "normal", shown as `1.0×`.
  final double normal;

  /// Called with the chosen value when the user lets go.
  final ValueChanged<double> onChangeEnd;

  @override
  State<SettingsSliderTile> createState() => _SettingsSliderTileState();
}

class _SettingsSliderTileState extends State<SettingsSliderTile> {
  /// The value under the thumb while it is held, and until the stored value
  /// catches up - otherwise the thumb would jump back for a frame after
  /// release, before the write comes round again.
  double? _held;

  @override
  void didUpdateWidget(SettingsSliderTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _held = null;
  }

  String _format(BuildContext context, double value) {
    final multiple = NumberFormat(
      '0.0',
      Localizations.localeOf(context).toString(),
    ).format(value / widget.normal);
    return '$multiple×';
  }

  @override
  Widget build(BuildContext context) {
    final shown = _held ?? widget.value.clamp(widget.min, widget.max);
    final text = _format(context, shown);

    return ListTile(
      title: Row(
        children: <Widget>[
          Expanded(child: Text(widget.title)),
          Text(text),
        ],
      ),
      subtitle: Slider(
        value: shown,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        label: text,
        semanticFormatterCallback: (value) => _format(context, value),
        onChanged: (value) => setState(() => _held = value),
        onChangeEnd: widget.onChangeEnd,
      ),
    );
  }
}
