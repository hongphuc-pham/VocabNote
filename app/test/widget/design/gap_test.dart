import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/presentation/design/gap.dart';

void main() {
  /// Wraps [child] in a theme whose metrics are [metrics], or the defaults.
  Widget host(Widget child, {AppMetrics? metrics}) {
    final theme = AppTheme.light();
    return MaterialApp(
      theme: metrics == null
          ? theme
          : theme.copyWith(extensions: <ThemeExtension<dynamic>>[metrics]),
      home: Scaffold(body: Column(children: <Widget>[child])),
    );
  }

  group('VnSpace', () {
    test('resolves every step against the metrics it is given', () {
      final metrics = AppMetrics.defaults();
      expect(VnSpace.xs.resolve(metrics), metrics.spaceXs);
      expect(VnSpace.sm.resolve(metrics), metrics.spaceSm);
      expect(VnSpace.md.resolve(metrics), metrics.spaceMd);
      expect(VnSpace.lg.resolve(metrics), metrics.spaceLg);
      expect(VnSpace.xl.resolve(metrics), metrics.spaceXl);
      expect(VnSpace.xxl.resolve(metrics), metrics.spaceXxl);
    });

    test('the six steps are distinct and ascending', () {
      final metrics = AppMetrics.defaults();
      final sizes = VnSpace.values.map((s) => s.resolve(metrics)).toList();
      expect(sizes, orderedEquals(<double>[4, 8, 12, 16, 24, 32]));
    });
  });

  group('VnGap', () {
    testWidgets('takes its size from the theme, not from a constant', (
      tester,
    ) async {
      await tester.pumpWidget(host(const VnGap(VnSpace.lg)));
      expect(
        tester.getSize(find.byType(VnGap)).height,
        AppMetrics.defaults().spaceLg,
      );
    });

    testWidgets('a second design re-scales it with no widget edit', (
      tester,
    ) async {
      // The point of the whole exercise: swap one object on the theme and the
      // gap changes, without VnGap or any caller being touched.
      final denser = AppMetrics.defaults().copyWith(spaceLg: 40);
      await tester.pumpWidget(host(const VnGap(VnSpace.lg), metrics: denser));
      expect(tester.getSize(find.byType(VnGap)).height, 40);
    });

    testWidgets('constrains only the axis it runs along', (tester) async {
      // A square gap would push the cross-axis extent too, which is a layout
      // change rather than a gap.
      await tester.pumpWidget(host(const VnGap(VnSpace.lg)));
      final box = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(VnGap),
          matching: find.byType(SizedBox),
        ),
      );
      expect(box.height, AppMetrics.defaults().spaceLg);
      expect(box.width, isNull);

      await tester.pumpWidget(
        host(const VnGap(VnSpace.lg, axis: Axis.horizontal)),
      );
      final across = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(VnGap),
          matching: find.byType(SizedBox),
        ),
      );
      expect(across.width, AppMetrics.defaults().spaceLg);
      expect(across.height, isNull);
    });

    testWidgets('is const, so RULES §23 still holds at the call site', (
      tester,
    ) async {
      // The assertion here is the `const` keyword itself, checked by the
      // compiler: if VnGap ever stops being const-constructible this file
      // stops compiling, which is a louder failure than any expect().
      //
      // Deliberately not `identical(gap, const VnGap(VnSpace.sm))`. Const
      // canonicalisation is not observable in the test VM — `const
      // SizedBox(height: 8)` is not identical to another either — so such an
      // assertion would fail for the stock widget this replaces, and would be
      // measuring the toolchain rather than the design.
      const gap = VnGap(VnSpace.sm);
      await tester.pumpWidget(host(gap));
      expect(find.byType(VnGap), findsOneWidget);
      expect(
        tester.getSize(find.byType(VnGap)).height,
        AppMetrics.defaults().spaceSm,
      );
    });
  });
}
