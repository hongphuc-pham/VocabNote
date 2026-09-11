import 'package:flutter/material.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';

/// The body a bottom sheet with a text field shares: gutters, room for the
/// keyboard, and content that scrolls.
///
/// Scrolling is the point. At 200% text on a 320dp phone with the keyboard
/// up, a sheet whose content could not scroll overflowed and pushed its Save
/// button out of reach (found on the emulator). Every sheet with a text field
/// had the same shape, so the fix lives here once.
class VnSheetBody extends StatelessWidget {
  /// Creates the body.
  const new({
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    super.key,
  });

  /// The sheet's content, top to bottom.
  final List<Widget> children;

  /// How the content lines up across the sheet.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lifted above the keyboard rather than letting it cover the field the
      // user is typing into; what no longer fits then scrolls.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.metrics.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      ),
    );
  }
}
