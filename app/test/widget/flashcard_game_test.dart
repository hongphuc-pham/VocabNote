import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';

/// The flashcard game (`docs/GAMES.md` §6, `docs/UI-UX.md` §4.7, F-063).
void main() {
  PracticeCardData card({
    String id = 'w1',
    String headword = 'cough',
    String? ipaUk = 'kɒf',
    String? definition = 'To expel air from the lungs',
    String? firstNote,
  }) => PracticeCardData(
    word: Word(
      id: id,
      headword: Headword(headword),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      ipaUk: ipaUk == null ? null : Ipa.fromStorage(ipaUk),
      definition: definition,
    ),
    card: StudyCard(wordId: id, dueAt: DateTime.utc(2026)),
    firstNote: firstNote,
  );

  GameConfig config({
    PromptSide promptSide = PromptSide.wordFirst,
    PracticeMode mode = PracticeMode.daily,
    int? seed,
  }) => GameConfig(
    gameId: FlashcardGame.gameId,
    mode: mode,
    selection: CardSelection.due,
    limit: 20,
    promptSide: promptSide,
    seed: seed,
  );

  FlashcardRound roundFor(
    PracticeCardData data, {
    PromptSide promptSide = PromptSide.wordFirst,
    bool isFirstRound = false,
  }) => FlashcardRound(
    index: 0,
    card: data,
    promptSide: promptSide,
    isFirstRound: isFirstRound,
  );

  Future<void> pumpRound(
    WidgetTester tester,
    FlashcardRound round, {
    required void Function(GameAnswer) onAnswer,
    String Function(ReviewOutcome)? intervalLabel,
    VoidCallback? onSpeak,
    bool reduceMotion = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Scaffold(
            body: Builder(
              builder: (context) => const FlashcardGame().buildRoundView(
                context,
                round,
                GameRoundCallbacks(
                  onAnswer: onAnswer,
                  onSpeak: onSpeak,
                  intervalLabel: intervalLabel,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('buildRounds', () {
    test('makes one round per card, in order', () {
      final rounds = const FlashcardGame().buildRounds(
        config(),
        <PracticeCardData>[card(id: 'a'), card(id: 'b'), card(id: 'c')],
      );

      expect(rounds.map((r) => r.index), <int>[0, 1, 2]);
      expect(rounds.map((r) => r.card.word.id), <String>['a', 'b', 'c']);
    });

    test('only the first round carries the reveal hint', () {
      // UI-UX §4.7: "Tap to reveal" on round 1 only. A hint on every card is
      // noise by card three.
      final rounds = const FlashcardGame().buildRounds(
        config(),
        <PracticeCardData>[card(id: 'a'), card(id: 'b')],
      );

      expect(rounds.first.isFirstRound, isTrue);
      expect(rounds.last.isFirstRound, isFalse);
    });

    test('without a seed the pool order is kept', () {
      // A daily review arrives already ordered by due date. Re-shuffling it
      // would throw that ordering away.
      final pool = <PracticeCardData>[
        for (final id in <String>['a', 'b', 'c', 'd', 'e']) card(id: id),
      ];
      final rounds = const FlashcardGame().buildRounds(config(), pool);

      expect(rounds.map((r) => r.card.word.id), pool.map((c) => c.word.id));
    });

    test('the same seed shuffles the same way twice', () {
      final pool = <PracticeCardData>[
        for (final id in <String>['a', 'b', 'c', 'd', 'e']) card(id: id),
      ];

      final first = const FlashcardGame().buildRounds(config(seed: 5), pool);
      final second = const FlashcardGame().buildRounds(config(seed: 5), pool);

      expect(
        first.map((r) => r.card.word.id),
        second.map((r) => r.card.word.id),
      );
    });
  });

  group('the prompt side', () {
    test('wordFirst shows the headword', () {
      expect(roundFor(card()).frontText, 'cough');
    });

    test('ipaFirst shows the transcription', () {
      final round = roundFor(card(), promptSide: PromptSide.ipaFirst);
      expect(round.frontText, 'kɒf');
      expect(round.frontIsIpa, isTrue);
    });

    test('meaningFirst shows the definition', () {
      final round = roundFor(card(), promptSide: PromptSide.meaningFirst);
      expect(round.frontText, 'To expel air from the lungs');
    });

    test('falls back to the headword when the chosen side is empty', () {
      // A word with no definition is exactly a word worth practising, so it
      // must not be shown as a blank card or skipped.
      final round = roundFor(
        card(definition: null),
        promptSide: PromptSide.meaningFirst,
      );
      expect(round.frontIsFallback, isTrue);
      expect(round.frontText, 'cough');
      expect(round.frontIsIpa, isFalse);
    });
  });

  group('revealing', () {
    testWidgets('the back is hidden until the card is tapped', (tester) async {
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      expect(find.text('To expel air from the lungs'), findsNothing);
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      expect(find.text('To expel air from the lungs'), findsOneWidget);
    });

    testWidgets('a swipe up reveals as well as a tap', (tester) async {
      // UI-UX §1: a gesture may be a shortcut, never the only way.
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      await tester.fling(find.byType(Card), const Offset(0, -200), 1000);
      await tester.pumpAndSettle();
      expect(find.text('To expel air from the lungs'), findsOneWidget);
    });

    testWidgets('grading does nothing before the card is revealed', (
      tester,
    ) async {
      // Recording an answer to a question the user never saw would be worse
      // than useless - it would move their schedule.
      final answers = <GameAnswer>[];
      await pumpRound(tester, roundFor(card()), onAnswer: answers.add);

      await tester.tap(find.byKey(const ValueKey<String>('grade-good')));
      await tester.pumpAndSettle();

      expect(answers, isEmpty);
    });

    testWidgets('the back shows word, IPA, definition and the first note', (
      tester,
    ) async {
      await pumpRound(
        tester,
        roundFor(card(firstNote: 'jaw lower')),
        onAnswer: (_) {},
      );
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.text('cough'), findsOneWidget);
      expect(find.textContaining('kɒf', findRichText: true), findsOneWidget);
      expect(find.text('To expel air from the lungs'), findsOneWidget);
      expect(find.text('jaw lower'), findsOneWidget);
    });
  });

  group('grading', () {
    testWidgets('each button reports its own outcome exactly once', (
      tester,
    ) async {
      for (final outcome in <ReviewOutcome>[
        ReviewOutcome.again,
        ReviewOutcome.good,
        ReviewOutcome.easy,
      ]) {
        final answers = <GameAnswer>[];
        await pumpRound(tester, roundFor(card()), onAnswer: answers.add);
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(ValueKey<String>('grade-${outcome.name}')));
        await tester.pumpAndSettle();

        expect(answers, hasLength(1), reason: outcome.name);
        expect(answers.single.result, outcome, reason: outcome.name);
      }
    });

    test('grade echoes the tap, because the game has no opinion', () {
      final round = roundFor(card());
      expect(
        const FlashcardGame().grade(
          round,
          const GameAnswer(result: ReviewOutcome.again, elapsed: Duration.zero),
        ),
        ReviewOutcome.again,
      );
    });

    testWidgets('shows the next interval on each button when given one', (
      tester,
    ) async {
      // UI-UX §4.7: each button shows its next interval, so the schedule is
      // never mysterious.
      await pumpRound(
        tester,
        roundFor(card()),
        onAnswer: (_) {},
        intervalLabel: (outcome) => switch (outcome) {
          ReviewOutcome.again => '10m',
          ReviewOutcome.good => '2d',
          ReviewOutcome.easy => '4d',
          ReviewOutcome.skipped => '',
        },
      );

      expect(find.text('10m'), findsOneWidget);
      expect(find.text('2d'), findsOneWidget);
      expect(find.text('4d'), findsOneWidget);
    });

    testWidgets('shows no interval when there is none to show', (tester) async {
      // A quick test does not move the schedule, so an interval on its buttons
      // would be a lie. The runner passes null and the buttons stay bare.
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      expect(find.text('10m'), findsNothing);
      expect(find.text('2d'), findsNothing);
    });
  });

  group('accessibility', () {
    testWidgets('the card announces which side is showing', (tester) async {
      // UI-UX §6: the flip card announces its state rather than silently
      // changing what it says.
      final handle = tester.ensureSemantics();
      await pumpRound(tester, roundFor(card()), onAnswer: (_) {});

      expect(
        find.bySemanticsLabel('Card front. Tap to reveal the answer.'),
        findsOneWidget,
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Card back. Choose how well you knew it.'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('reduce motion removes the flip animation', (tester) async {
      // F-093. A single `pump` would still find the old side mid-animation;
      // with animations disabled the switch is immediate.
      await pumpRound(
        tester,
        roundFor(card()),
        onAnswer: (_) {},
        reduceMotion: true,
      );

      await tester.tap(find.byType(Card));
      await tester.pump();

      expect(find.text('To expel air from the lungs'), findsOneWidget);
    });
  });
}
