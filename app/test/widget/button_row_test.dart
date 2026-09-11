import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/presentation/design/button_row.dart';

/// Buttons side by side, or stacked when a label would not fit (UI-UX §6).
///
/// Found on the emulator at 200% text on a 320dp phone: three equal buttons
/// broke "Again" mid-word, and two broke a label onto three lines that spilled
/// out of the pill.
void main() {
  const grades = <String>['Again', 'Good', 'Easy'];

  Future<void> pumpRow(
    WidgetTester tester, {
    required double width,
    double textScale = 1,
    List<String> labels = grades,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: VnButtonRow(
              labels: labels,
              children: <Widget>[
                for (final label in labels)
                  FilledButton(onPressed: () {}, child: Text(label)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Rect rectOf(WidgetTester tester, String label) => tester.getRect(
    find.ancestor(of: find.text(label), matching: find.byType(FilledButton)),
  );

  testWidgets('side by side at equal width when every label fits', (
    tester,
  ) async {
    await pumpRow(tester, width: 400);

    final again = rectOf(tester, 'Again');
    final good = rectOf(tester, 'Good');
    final easy = rectOf(tester, 'Easy');
    expect(good.top, again.top);
    expect(easy.top, again.top);
    expect(good.width, closeTo(again.width, 0.5));
    expect(easy.left, greaterThan(good.right));
  });

  testWidgets('stacked at full width when a label would wrap', (tester) async {
    await pumpRow(tester, width: 320, textScale: 2);

    final again = rectOf(tester, 'Again');
    final good = rectOf(tester, 'Good');
    final easy = rectOf(tester, 'Easy');
    expect(good.top, greaterThan(again.bottom - 0.5));
    expect(easy.top, greaterThan(good.bottom - 0.5));
    expect(again.width, 320);
    expect(good.width, 320);
  });

  testWidgets('decided by the longest label, not the shortest', (tester) async {
    const hub = <String>['Daily review (12 due)', 'Quick test'];

    // The test font draws every glyph a full em wide, so labels measure far
    // wider here than in Inter - hence 800 for "room for both".
    await pumpRow(tester, width: 800, labels: hub);
    expect(
      rectOf(tester, 'Quick test').top,
      rectOf(tester, 'Daily review (12 due)').top,
      reason: 'room for both on one line',
    );

    await pumpRow(tester, width: 320, labels: hub);
    expect(
      rectOf(tester, 'Quick test').top,
      greaterThan(rectOf(tester, 'Daily review (12 due)').bottom - 0.5),
      reason: 'the longer label would wrap at half of 320',
    );
  });
}
