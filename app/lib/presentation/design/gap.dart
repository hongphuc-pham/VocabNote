import 'package:flutter/material.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';

/// A step on the spacing scale, named rather than measured.
///
/// A widget that says [VnSpace.sm] is asking for "the small step of whatever
/// scale this design uses". A widget that says `8` has picked a number that no
/// second design can change.
enum VnSpace {
  /// Hairline gaps, icon padding.
  xs,

  /// Between related controls.
  sm,

  /// Inside chips.
  md,

  /// The default screen gutter.
  lg,

  /// Between sections.
  xl,

  /// Around a screen's single primary action.
  xxl;

  /// What this step measures under [metrics].
  double resolve(AppMetrics metrics) => switch (this) {
    VnSpace.xs => metrics.spaceXs,
    VnSpace.sm => metrics.spaceSm,
    VnSpace.md => metrics.spaceMd,
    VnSpace.lg => metrics.spaceLg,
    VnSpace.xl => metrics.spaceXl,
    VnSpace.xxl => metrics.spaceXxl,
  };
}

/// Blank space between two widgets, measured by the theme.
///
/// This exists to settle a real conflict. `docs/RULES.md` §23 wants widgets to
/// be `const`; the whole point of [AppMetrics] is that spacing comes from the
/// theme, and a theme lookup is not a compile-time constant. Writing
/// `SizedBox(height: metrics.spaceSm)` at 56 call sites would have
/// given up the first rule to get the second.
///
/// It does not have to be a trade. `const VnGap(VnSpace.sm)` **is** a constant
/// — the token is what the caller names, and the measurement is resolved inside
/// this widget's own `build`, where the theme is in scope. Both rules hold.
class VnGap extends StatelessWidget {
  /// Creates a gap of [space].
  ///
  /// A single constructor with an optional [axis] rather than named
  /// constructors: `dart format` 3.13 and `flutter analyze` disagree about how
  /// to spell one, and there is no spelling that satisfies both.
  const new(this.space, {this.axis = Axis.vertical, super.key});

  /// How big a gap, on the scale.
  final VnSpace space;

  /// Which way the gap runs. Vertical suits a [Column], the common case.
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final size = space.resolve(context.metrics);
    // Only the one dimension is constrained. A square would also push the
    // cross-axis extent, which in a stretched Column or a Row is a layout
    // change rather than a gap.
    return axis == Axis.vertical
        ? SizedBox(height: size)
        : SizedBox(width: size);
  }
}
