import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';
import 'package:vocabnote/presentation/words/ipa_keyboard_row.dart';

/// What a screen reader hears for IPA on screen (`docs/UI-UX.md` §6, M7 A3):
/// the sounds, by the names a learner knows, never the glyphs.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    // Wide enough that every key of the IPA row is laid out and on screen.
    tester.view.physicalSize = const Size(2400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a transcription is announced as its sounds', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, const IpaText(ipa: 'kɒf'));

    expect(
      find.bySemanticsLabel('pronunciation: k, short o as in hot, f'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('ɒ')), findsNothing);
    semantics.dispose();
  });

  testWidgets('without its slashes it is just the sounds', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, const IpaText(ipa: 'θɪŋ', showSlashes: false));

    expect(
      find.bySemanticsLabel('th as in thin, short i as in sit, ng as in sing'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('each IPA key says the sound it inserts', (tester) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await pump(tester, IpaKeyboardRow(controller: controller));

    // `tʃ` is one key and one sound - "ch", not "t" and "esh".
    expect(find.bySemanticsLabel('Insert ch'), findsOneWidget);
    expect(find.bySemanticsLabel('Insert short o as in hot'), findsOneWidget);
    expect(find.bySemanticsLabel('Insert stress'), findsOneWidget);
    semantics.dispose();
  });
}
