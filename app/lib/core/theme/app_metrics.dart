/// Spacing, radii and motion as a **themed object** rather than global
/// constants.
///
/// `AppSpacing`, `AppRadii` and `AppMotion` in `tokens.dart` are static
/// holders: fine as values, but a widget that writes `AppSpacing.lg` is
/// compiled against one scale for ever. There is no way to ship a second
/// design, a denser layout, or a rebrand without editing every call site.
///
/// This is the same set of numbers reachable through the theme, which makes a
/// whole design system one swappable object — exactly as `IpaPalette` and
/// `AppTypography` already are. `tokens.dart` stays as the source of the
/// default values, so both spellings agree by construction and existing
/// widgets keep working while call sites migrate.
library;

import 'package:flutter/material.dart';
import 'package:vocabnote/core/theme/tokens.dart';

/// The measurable half of the design system.
@immutable
class AppMetrics extends ThemeExtension<AppMetrics> {
  /// Creates a metric set.
  const new({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.spaceXxl,
    required this.radiusChip,
    required this.radiusCard,
    required this.radiusSheet,
    required this.radiusPill,
    required this.minTouchTarget,
    required this.enter,
    required this.exit,
    required this.flip,
  });

  /// The scale `docs/UI-UX.md` §2 defines, as the default.
  ///
  /// Reads its values from `tokens.dart` rather than repeating them: two
  /// literal copies of the same scale would drift, and the one in `tokens.dart`
  /// is the one the docs describe.
  factory defaults() => const AppMetrics(
    spaceXs: AppSpacing.xs,
    spaceSm: AppSpacing.sm,
    spaceMd: AppSpacing.md,
    spaceLg: AppSpacing.lg,
    spaceXl: AppSpacing.xl,
    spaceXxl: AppSpacing.xxl,
    radiusChip: AppRadii.chip,
    radiusCard: AppRadii.card,
    radiusSheet: AppRadii.sheet,
    radiusPill: AppRadii.pill,
    minTouchTarget: kMinTouchTarget,
    enter: AppMotion.enter,
    exit: AppMotion.exit,
    flip: AppMotion.flip,
  );

  /// 4dp — hairline gaps, icon padding.
  final double spaceXs;

  /// 8dp — between related controls.
  final double spaceSm;

  /// 12dp — inside chips.
  final double spaceMd;

  /// 16dp — the default screen gutter.
  final double spaceLg;

  /// 24dp — between sections.
  final double spaceXl;

  /// 32dp — around a screen's single primary action.
  final double spaceXxl;

  /// Chip corner radius.
  final double radiusChip;

  /// Card corner radius.
  final double radiusCard;

  /// Bottom sheet and dialog corner radius.
  final double radiusSheet;

  /// Filter pill radius — effectively "fully rounded".
  final double radiusPill;

  /// Smallest interactive size (`docs/UI-UX.md` §6, F-093).
  ///
  /// Themed rather than constant so a larger-target accessibility variant is
  /// possible without touching a single widget.
  final double minTouchTarget;

  /// How long something takes to enter.
  final Duration enter;

  /// How long something takes to leave.
  final Duration exit;

  /// The flashcard flip.
  final Duration flip;

  /// [radiusChip] as a [BorderRadius].
  BorderRadius get chipBorder => BorderRadius.circular(radiusChip);

  /// [radiusCard] as a [BorderRadius].
  BorderRadius get cardBorder => BorderRadius.circular(radiusCard);

  /// [radiusSheet] as a [BorderRadius].
  BorderRadius get sheetBorder => BorderRadius.circular(radiusSheet);

  /// [radiusPill] as a [BorderRadius].
  BorderRadius get pillBorder => BorderRadius.circular(radiusPill);

  @override
  AppMetrics copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? spaceXxl,
    double? radiusChip,
    double? radiusCard,
    double? radiusSheet,
    double? radiusPill,
    double? minTouchTarget,
    Duration? enter,
    Duration? exit,
    Duration? flip,
  }) => AppMetrics(
    spaceXs: spaceXs ?? this.spaceXs,
    spaceSm: spaceSm ?? this.spaceSm,
    spaceMd: spaceMd ?? this.spaceMd,
    spaceLg: spaceLg ?? this.spaceLg,
    spaceXl: spaceXl ?? this.spaceXl,
    spaceXxl: spaceXxl ?? this.spaceXxl,
    radiusChip: radiusChip ?? this.radiusChip,
    radiusCard: radiusCard ?? this.radiusCard,
    radiusSheet: radiusSheet ?? this.radiusSheet,
    radiusPill: radiusPill ?? this.radiusPill,
    minTouchTarget: minTouchTarget ?? this.minTouchTarget,
    enter: enter ?? this.enter,
    exit: exit ?? this.exit,
    flip: flip ?? this.flip,
  );

  @override
  AppMetrics lerp(ThemeExtension<AppMetrics>? other, double t) {
    if (other is! AppMetrics) return this;
    return AppMetrics(
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t),
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t),
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t),
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t),
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t),
      spaceXxl: lerpDouble(spaceXxl, other.spaceXxl, t),
      radiusChip: lerpDouble(radiusChip, other.radiusChip, t),
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t),
      radiusSheet: lerpDouble(radiusSheet, other.radiusSheet, t),
      radiusPill: lerpDouble(radiusPill, other.radiusPill, t),
      minTouchTarget: lerpDouble(minTouchTarget, other.minTouchTarget, t),
      // Durations are not interpolated: a half-lerped animation length is
      // meaningless, and the target value is what any in-flight animation
      // should already be using.
      enter: t < 0.5 ? enter : other.enter,
      exit: t < 0.5 ? exit : other.exit,
      flip: t < 0.5 ? flip : other.flip,
    );
  }

  /// Linear interpolation that never returns null, unlike `ui.lerpDouble`.
  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Reaching the metrics from a widget.
extension AppMetricsContext on BuildContext {
  /// The current [AppMetrics].
  ///
  /// Falls back to [AppMetrics.defaults] rather than throwing, so a widget
  /// pumped in a bare `MaterialApp` in a test still lays out correctly.
  AppMetrics get metrics =>
      Theme.of(this).extension<AppMetrics>() ?? AppMetrics.defaults();

  /// [duration], or zero when the user has asked for reduced motion.
  ///
  /// The single place that check lives (`docs/UI-UX.md` §6). A widget cannot
  /// forget it if it never reads a raw duration.
  Duration motion(Duration duration) => AppMotion.durationFor(this, duration);
}
