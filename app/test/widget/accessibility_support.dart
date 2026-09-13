import 'dart:async';
import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every enabled button can be pressed by a screen reader.
///
/// A button a screen reader can find but not press: `Semantics(button: true)`
/// over an `ExcludeSemantics` that hides the real tap, with no `onTap` of its
/// own. Flutter's guidelines only look at nodes that already have a tap
/// action, so they cannot see this at all. M7 found five of them this way -
/// the IPA symbol chips, the highlight colour swatches, the legend lines, the
/// play buttons and `VnTapTarget` - after all four stock guidelines had passed
/// over every screen.
const AccessibilityGuideline pressableButtonsGuideline = _PressableButtons();

class _PressableButtons extends AccessibilityGuideline {
  const new();

  @override
  String get description =>
      'Every enabled button can be pressed by a screen reader';

  @override
  FutureOr<Evaluation> evaluate(WidgetTester tester) {
    var result = const Evaluation.pass();
    for (final view in tester.binding.renderViews) {
      final root = view.owner?.semanticsOwner?.rootSemanticsNode;
      if (root != null) result += _traverse(root);
    }
    return result;
  }

  Evaluation _traverse(SemanticsNode node) {
    var result = const Evaluation.pass();
    node.visitChildren((child) {
      result += _traverse(child);
      return true;
    });
    if (node.isMergedIntoParent || node.isInvisible) return result;
    final data = node.getSemanticsData();
    final flags = data.flagsCollection;
    // A disabled button is meant not to press.
    if (!flags.isButton ||
        flags.isHidden ||
        flags.isEnabled == Tristate.isFalse) {
      return result;
    }
    if (!data.hasAction(SemanticsAction.tap)) {
      result += Evaluation.fail(
        '$node: a button with no tap action - a screen reader can reach it '
        'but not press it.',
      );
    }
    return result;
  }
}
