import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/presentation/words/ipa_keyboard_row.dart';

/// The IPA symbol row (F-002, `docs/UI-UX.md` §4.2).
///
/// Manual entry is a first-class path (RULES §3) and no phone keyboard carries
/// these symbols, so this row is the only practical way to type one. Its
/// insertion logic has unit tests; what is asserted here is the thing those
/// could not catch - that tapping a symbol leaves the field you were typing in
/// still focused.
void main() {
  late TextEditingController controller;
  late FocusNode focus;

  /// The field plus the row, wired the way the editor screen wires them.
  Future<void> pumpRow(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(
          body: TextField(controller: controller, focusNode: focus),
          bottomNavigationBar: IpaKeyboardRow(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    controller = TextEditingController();
    focus = FocusNode();
  });

  tearDown(() {
    controller.dispose();
    focus.dispose();
  });

  testWidgets('inserts the tapped symbol at the cursor', (tester) async {
    await pumpRow(tester);

    await tester.tap(find.text('ɒ'));
    await tester.pumpAndSettle();

    expect(controller.text, 'ɒ');
  });

  testWidgets('leaves the field focused, so typing can carry on', (
    tester,
  ) async {
    await pumpRow(tester);

    focus.requestFocus();
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue, reason: 'precondition');

    await tester.tap(find.text('ɒ'));
    await tester.pumpAndSettle();

    // The editor shows this row *because* a transcription field has focus. A
    // button that steals it dismisses the row mid-word and sends the next
    // keystroke nowhere.
    expect(focus.hasFocus, isTrue);
  });

  testWidgets('inserts a two-character affricate as one symbol', (
    tester,
  ) async {
    await pumpRow(tester);

    // The affricates are off-screen at the end of a long horizontal row.
    await tester.scrollUntilVisible(
      find.text('tʃ'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('tʃ'));
    await tester.pumpAndSettle();

    expect(controller.text, 'tʃ');
  });
}
