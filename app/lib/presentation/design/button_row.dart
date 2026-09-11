import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';

/// Buttons side by side at equal width, or stacked at full width when a label
/// would not fit on one line (`docs/UI-UX.md` §6: 200% text at 320dp).
///
/// Wrapping inside a pill-shaped button breaks it. On a 320dp phone at 200%
/// a label wrapped onto three lines and spilled out of its shape, and "Again"
/// broke mid-word — a WCAG 1.4.4 failure; 1.4.10 asks for exactly this reflow
/// instead. So the row measures rather than hopes: each label is laid out at
/// the current text scale, plus the padding a Material button uses at that
/// scale, against the width a button would get.
class VnButtonRow extends StatelessWidget {
  /// Creates the row. [labels] are the buttons' texts, in the same order.
  const new({required this.labels, required this.children, super.key})
    : assert(labels.length == children.length, 'one label per button');

  /// What each button says — what is measured.
  final List<String> labels;

  /// The buttons.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.metrics.spaceSm;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gaps = spacing * (children.length - 1);
        final perButton = (constraints.maxWidth - gaps) / children.length;

        if (_widestButton(context) <= perButton) {
          return Row(
            spacing: spacing,
            children: <Widget>[
              for (final child in children) Expanded(child: child),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing,
          children: children,
        );
      },
    );
  }

  /// The width the widest label needs as a button: its text plus padding.
  double _widestButton(BuildContext context) {
    final metrics = context.metrics;
    final style = Theme.of(context).textTheme.labelLarge;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);

    // Material shrinks a button's side padding as text grows, so a fixed
    // guess would stack the row too early at normal size. This is the same
    // interpolation Material 3 buttons use, on this app's spacing scale.
    final fontSize = style?.fontSize ?? metrics.spaceLg;
    final padding = ButtonStyleButton.scaledPadding(
      EdgeInsets.symmetric(horizontal: metrics.spaceXl),
      EdgeInsets.symmetric(horizontal: metrics.spaceMd),
      EdgeInsets.symmetric(horizontal: metrics.spaceXs),
      scaler.scale(fontSize) / fontSize,
    ).resolve(direction).horizontal;

    var widest = 0.0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      widest = max(widest, painter.width);
      painter.dispose();
    }
    return widest + padding;
  }
}
