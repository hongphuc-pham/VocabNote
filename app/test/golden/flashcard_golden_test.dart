import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/practice_session.dart'
    show PromptSide;
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_round_view.dart';

/// The flashcard, both faces, both themes (M7 A6, F-063).
///
/// The two faces are private to `flashcard_round_view.dart` (`_Front`,
/// `_Back`), so there is no way to construct a revealed card from outside.
/// The back is captured by flipping it first in `pumpBeforeTest`, which is
/// what a learner does - and it means the picture is of the real widget in a
/// real state rather than of a test-only imitation.
void main() {
  final now = DateTime.utc(2026, 9, 13);

  final data = PracticeCardData(
    word: Word(
      id: 'w1',
      headword: Headword('intonation'),
      createdAt: now,
      updatedAt: now,
      partOfSpeech: 'noun',
      ipaUk: Ipa.fromStorage('ˌɪntəˈneɪʃn'),
      definition: 'the rise and fall of the voice in speaking',
    ),
    card: StudyCard(wordId: 'w1', dueAt: now),
    firstNote: 'the stress lands on the fourth syllable',
  );

  Widget framed(ThemeData theme) => SizedBox(
    width: 360,
    height: 560,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: FlashcardRoundView(
            round: FlashcardRound(
              index: 0,
              card: data,
              promptSide: PromptSide.wordFirst,
            ),
            callbacks: GameRoundCallbacks(onAnswer: (_) {}),
          ),
        ),
      ),
    ),
  );

  GoldenTestGroup bothThemes() => GoldenTestGroup(
    columns: 2,
    children: <Widget>[
      GoldenTestScenario(name: 'light', child: framed(AppTheme.light())),
      GoldenTestScenario(name: 'dark', child: framed(AppTheme.dark())),
    ],
  );

  unawaited(
    goldenTest(
      'the flashcard front keeps its shape in both themes',
      fileName: 'flashcard_front',
      builder: bothThemes,
    ),
  );

  unawaited(
    goldenTest(
      'the flashcard back shows the answer and the grades',
      fileName: 'flashcard_back',
      builder: bothThemes,
      // Flip both cards before the picture is taken. Tapping the view itself
      // rather than an inner `Card`: the inner tree is private, and a finder
      // aimed at it would break silently the day it is restructured.
      pumpBeforeTest: (tester) async {
        await tester.pumpAndSettle();
        final cards = find.byType(FlashcardRoundView);
        for (var i = 0; i < cards.evaluate().length; i++) {
          await tester.tap(find.byType(FlashcardRoundView).at(i));
          await tester.pumpAndSettle();
        }
      },
    ),
  );
}
