import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';
import 'package:vocabnote/presentation/lists/list_editor_sheet.dart';
import 'package:vocabnote/presentation/words/highlight_color_sheet.dart';

/// Sheets with a text field, at 200% text on a 320dp phone with the keyboard
/// up (`docs/UI-UX.md` §6).
///
/// Found on the emulator: the new-list sheet overflowed by 66px and its Save
/// button went out of reach. Its content could not scroll, and every sheet
/// with a text field was built the same way.
void main() {
  setUpAll(() => EditableText.debugDeterministicCursor = true);
  tearDownAll(() => EditableText.debugDeterministicCursor = false);

  /// Opens a sheet at 320dp and 200%, then brings the keyboard up - after the
  /// sheet, as it arrives on a device.
  Future<void> openSheet(
    WidgetTester tester,
    Future<Object?> Function(BuildContext context) show,
  ) async {
    tester.view.physicalSize = const Size(960, 2142);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => show(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // 400dp: a keyboard at large text is tall, and on the device the sheet
    // also sat above the navigation bar. 300dp was not enough to fail.
    tester.view.viewInsets = const FakeViewPadding(bottom: 1200);
    await tester.pumpAndSettle();
  }

  Future<void> expectReachable(WidgetTester tester, Finder button) async {
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    expect(button.hitTestable(), findsOneWidget);
  }

  testWidgets('the list sheet scrolls rather than overflowing', (tester) async {
    await openSheet(tester, ListEditorSheet.show);

    expect(tester.takeException(), isNull, reason: 'no overflow');
    await expectReachable(tester, find.widgetWithText(FilledButton, 'Save'));
  });

  testWidgets('the highlight sheet keeps all three buttons reachable', (
    tester,
  ) async {
    // Editing an existing highlight adds Delete, making three buttons that a
    // single Row could not hold at this size.
    final existing = IpaHighlight(
      id: 'h1',
      wordId: 'w1',
      target: HighlightTarget.ipaUk,
      range: GraphemeRange(0, 1),
      color: IpaColorToken.amber,
      createdAt: DateTime.utc(2026),
    );
    await openSheet(
      tester,
      (context) => HighlightColorSheet.show(context, existing: existing),
    );

    expect(tester.takeException(), isNull, reason: 'no overflow');
    for (final label in <String>['Delete highlight', 'Cancel', 'Save']) {
      await expectReachable(
        tester,
        find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
    }
  });
}
