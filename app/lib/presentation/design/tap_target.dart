import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';

/// An icon-sized control that is always at least [AppMetrics.minTouchTarget].
///
/// F-093 and `docs/UI-UX.md` §6 make ≥48dp targets blocking, and every one of
/// them also needs a semantics label. Both were being written by hand at each
/// call site — the play button, the IPA symbol keys, the colour swatches, the
/// grapheme chips — which is four chances to forget.
///
/// This makes both structural. The label is required, so it cannot be omitted;
/// the size comes from the theme, so an accessibility variant with larger
/// targets is a theme change rather than a sweep through the widgets.
class VnTapTarget extends StatelessWidget {
  /// Creates a tap target.
  const new({
    required this.label,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.longPressLabel,
    this.selected,
    this.shape = VnTapShape.circle,
    super.key,
  });

  /// What a screen reader announces. Required on purpose.
  final String label;

  /// The primary action.
  final VoidCallback onTap;

  /// An optional shortcut gesture.
  ///
  /// Always **also** exposed as a custom semantics action, because
  /// `docs/UI-UX.md` §1 forbids an action reachable only by a gesture and a
  /// screen-reader user cannot long-press.
  final VoidCallback? onLongPress;

  /// What the long-press does, in words. Required when [onLongPress] is set.
  final String? longPressLabel;

  /// Selected state, announced when non-null.
  final bool? selected;

  /// The ink shape.
  final VnTapShape shape;

  /// What is drawn inside.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(
      onLongPress == null || longPressLabel != null,
      'a long-press needs a label, or it is unreachable by screen reader',
    );

    final size = context.metrics.minTouchTarget;
    final longPress = onLongPress;
    final longPressName = longPressLabel;

    return Semantics(
      button: true,
      label: label,
      selected: selected,
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
        if (longPress != null && longPressName != null)
          CustomSemanticsAction(label: longPressName): longPress,
      },
      child: ExcludeSemantics(
        child: Tooltip(
          message: label,
          child: InkResponse(
            onTap: onTap,
            onLongPress: onLongPress,
            radius: size / 2,
            containedInkWell: shape == VnTapShape.rounded,
            highlightShape: shape == VnTapShape.circle
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius: shape == VnTapShape.rounded
                ? context.metrics.chipBorder
                : null,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// The ink shape of a [VnTapTarget].
enum VnTapShape {
  /// Round ripple — icon buttons.
  circle,

  /// Rounded rectangle — chips and keys.
  rounded,
}
