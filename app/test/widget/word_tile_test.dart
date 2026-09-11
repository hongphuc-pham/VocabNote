import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/presentation/words/word_tile.dart';

/// The word card in the shapes that break layouts (`docs/UI-UX.md` §4.1, §6).
void main() {
  WordListEntry entryFor({
    required String headword,
    String? partOfSpeech,
    String? ipaUk,
    int noteCount = 0,
  }) {
    final now = DateTime.utc(2026, 9, 10);
    return WordListEntry(
      word: Word(
        id: 'w1',
        headword: Headword(headword),
        createdAt: now,
        updatedAt: now,
        partOfSpeech: partOfSpeech,
        ipaUk: ipaUk == null ? null : Ipa.fromStorage(ipaUk),
      ),
      noteCount: noteCount,
      highlights: const <IpaHighlight>[],
    );
  }

  Future<void> pumpCard(
    WidgetTester tester,
    WordListEntry entry, {
    double textScale = 1,
    Size size = const Size(320, 640),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: ListView(
              children: <Widget>[WordTile(entry: entry, onTap: () {})],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('survives a long headword and a long part of speech at 200%', (
    tester,
  ) async {
    // The headword is Flexible; the badge beside it is not, so a long pair is
    // exactly the shape that overflows. 320dp is the narrowest width UI-UX §6
    // requires, and 200% the largest text.
    await pumpCard(
      tester,
      entryFor(
        headword: 'antidisestablishmentarianism',
        partOfSpeech: 'transitive verb',
        ipaUk: 'ˌæntidɪsɪˌstæblɪʃmənˈteəriənɪzəm',
      ),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the part of speech when there is one', (tester) async {
    await pumpCard(tester, entryFor(headword: 'cough', partOfSpeech: 'verb'));
    expect(find.text('verb'), findsOneWidget);
  });

  testWidgets('draws no badge when the part of speech is blank', (
    tester,
  ) async {
    // Free text, so "" is as likely as null.
    await pumpCard(tester, entryFor(headword: 'cough', partOfSpeech: ''));
    expect(find.byType(DecoratedBox), findsNothing);
  });
}
