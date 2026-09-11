import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/tokens.dart';

/// The measurable half of the design system.
///
/// The point of `AppMetrics` is that a restyle is one object swap rather than
/// an edit to every widget, so what matters here is that the object really is
/// the single source: that its defaults are the documented scale, that a
/// swapped-in variant reaches widgets, and that a widget with no theme still
/// lays out.
void main() {
  group('defaults', () {
    test('are the scale docs/UI-UX.md section 2 defines', () {
      final metrics = AppMetrics.defaults();

      expect(
        <double>[
          metrics.spaceXs,
          metrics.spaceSm,
          metrics.spaceMd,
          metrics.spaceLg,
          metrics.spaceXl,
          metrics.spaceXxl,
        ],
        <double>[4, 8, 12, 16, 24, 32],
      );
    });

    test('do not drift from tokens.dart', () {
      // Two literal copies of one scale is how they diverge; the defaults are
      // read from tokens.dart, and this is what holds that true.
      final metrics = AppMetrics.defaults();

      expect(metrics.spaceLg, AppSpacing.lg);
      expect(metrics.radiusChip, AppRadii.chip);
      expect(metrics.radiusCard, AppRadii.card);
      expect(metrics.radiusSheet, AppRadii.sheet);
      expect(metrics.minTouchTarget, kMinTouchTarget);
      expect(metrics.enter, AppMotion.enter);
    });

    test('meet the blocking 48dp touch target (F-093)', () {
      expect(AppMetrics.defaults().minTouchTarget, greaterThanOrEqualTo(48));
    });
  });

  group('as a theme extension', () {
    testWidgets('a widget reads the metrics the theme supplies', (
      tester,
    ) async {
      late AppMetrics seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<dynamic>>[
              AppMetrics.defaults().copyWith(spaceLg: 99, minTouchTarget: 64),
            ],
          ),
          home: Builder(
            builder: (context) {
              seen = context.metrics;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // A restyle is one object, not an edit to every call site.
      expect(seen.spaceLg, 99);
      expect(seen.minTouchTarget, 64);
      expect(seen.spaceXs, 4, reason: 'untouched values survive copyWith');
    });

    testWidgets('falls back to the defaults when no theme supplies them', (
      tester,
    ) async {
      late AppMetrics seen;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              seen = context.metrics;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // A widget pumped bare in a test must still lay out, not throw.
      expect(seen.spaceLg, AppSpacing.lg);
    });
  });

  group('lerp', () {
    test('interpolates sizes half way', () {
      final from = AppMetrics.defaults();
      final to = from.copyWith(spaceLg: 32);

      expect(from.lerp(to, 0.5).spaceLg, 24);
    });

    test('switches durations rather than interpolating them', () {
      // Half of an animation length is not an animation length.
      final from = AppMetrics.defaults();
      final to = from.copyWith(enter: const Duration(seconds: 1));

      expect(from.lerp(to, 0.2).enter, from.enter);
      expect(from.lerp(to, 0.9).enter, const Duration(seconds: 1));
    });

    test('leaves itself alone when handed a different extension', () {
      final metrics = AppMetrics.defaults();

      expect(metrics.lerp(null, 0.5), same(metrics));
    });
  });
}
