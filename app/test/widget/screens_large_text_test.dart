import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/application/practice/practice_session_controller.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';

import '../unit/application/fake_speech_service.dart';
import '../unit/data/db_fixtures.dart';

/// 200% text on a 320dp phone, for the screens M6's pass did not reach
/// (`docs/UI-UX.md` §6, M7 A5).
///
/// `m6_large_text_test.dart` covers everything M6 built, and word detail, the
/// lists screen, the practice hub, the flashcard and the design pieces have
/// their own large-text tests. These five had none: the words list, the word
/// editor, the IPA highlight editor, a list's detail, and the practice
/// summary.
///
/// Each screen is walked top to bottom; a layout that overflows reports an
/// exception, which fails the test.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() => EditableText.debugDeterministicCursor = true);
  tearDownAll(() => EditableText.debugDeterministicCursor = false);

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    await seedWord(
      db,
      id: 'w1',
      headword: 'cough',
      ipaUk: 'kɒf',
      ipaUs: 'kɔːf',
      definition: 'a sudden, noisy push of air out of the lungs',
      example: 'a dry cough that would not go away',
    );
    await seedWord(db, id: 'w2', headword: 'church', ipaUk: 'tʃɜːtʃ');
    await seedWord(db, id: 'w3', headword: 'thing', ipaUk: 'θɪŋ');
    await seedWord(db, id: 'w4', headword: 'through', ipaUk: 'θruː');
    await seedHighlight(db, id: 'h1', wordId: 'w1', start: 1, label: 'lips');
    await seedNote(db, id: 'n1', wordId: 'w1', body: 'rounder lips here');
    await seedList(db, id: 'l1', name: 'IELTS speaking practice');
    await seedMembership(db, listId: 'l1', wordId: 'w1');
    await seedMembership(db, listId: 'l1', wordId: 'w2');
  });

  tearDown(() => db.close());

  /// 960×2142 at 3× is a 320×714dp phone; text at twice its size.
  void stressSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(960, 2142);
    tester.view.devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  /// Frames plus real time: several screens load before they settle, and an
  /// indeterminate spinner never lets `pumpAndSettle` finish.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  void openContainer() {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db, speechService: FakeSpeechService()),
      ],
    );
    // Container before database, or teardown deadlocks.
    addTearDown(container.dispose);
  }

  Future<void> launch(WidgetTester tester) async {
    stressSize(tester);
    openContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await settle(tester);
  }

  /// The screen's own vertical scroll view: the tallest on stage, so a
  /// multi-line field inside it is not mistaken for the page.
  ScrollPosition? pageScroll(WidgetTester tester) {
    ScrollPosition? best;
    for (final element in find.byType(Scrollable).evaluate()) {
      final candidate =
          ((element as StatefulElement).state as ScrollableState).position;
      if (candidate.axis != Axis.vertical || !candidate.hasViewportDimension) {
        continue;
      }
      if (best == null ||
          candidate.viewportDimension > best.viewportDimension) {
        best = candidate;
      }
    }
    return best;
  }

  /// Top to bottom, checking nothing has overflowed at each stop.
  Future<void> walk(WidgetTester tester, String screen) async {
    expect(tester.takeException(), isNull, reason: '$screen, at the top');
    for (var stop = 0; stop < 40; stop++) {
      final position = pageScroll(tester);
      if (position == null || position.pixels >= position.maxScrollExtent) {
        return;
      }
      position.jumpTo(
        (position.pixels + position.viewportDimension * 0.8).clamp(
          0.0,
          position.maxScrollExtent,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: '$screen, stop $stop');
    }
  }

  Future<void> go(WidgetTester tester, String location) async {
    container.read(appRouterProvider).go(location);
    await settle(tester);
  }

  for (final (name, location) in <(String, String)>[
    ('the words list', Routes.words),
    ('the word editor', Routes.wordEditOf('w1')),
    ('the IPA highlight editor', Routes.wordIpaOf('w1')),
    ("a list's words", Routes.listDetailOf('l1')),
  ]) {
    testWidgets(name, (tester) async {
      await launch(tester);
      await go(tester, location);

      await walk(tester, name);
    });
  }

  testWidgets('the practice summary', (tester) async {
    stressSize(tester);
    openContainer();
    // The runner is auto-disposed; hold it as the run screen would.
    final keepAlive = container.listen(
      practiceSessionRunnerProvider,
      (_, _) {},
    );
    addTearDown(keepAlive.close);
    // Played on real async and before the app is pumped - a write to a watched
    // table while screens are mounted never returns under the fake clock.
    await tester.runAsync(() async {
      final runner = container.read(practiceSessionRunnerProvider.notifier);
      const game = FlashcardGame();
      await runner.start(
        config: GameConfig(
          gameId: FlashcardGame.gameId,
          mode: PracticeMode.quickTest,
          selection: CardSelection.random,
          limit: 4,
          seed: 1,
        ),
        game: game,
        againRepeats: 0,
      );
      for (final result in <ReviewOutcome>[
        ReviewOutcome.again,
        ReviewOutcome.good,
        ReviewOutcome.easy,
        ReviewOutcome.good,
      ]) {
        await runner.answer(
          game,
          GameAnswer(result: result, elapsed: const Duration(seconds: 2)),
        );
      }
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await settle(tester);
    final summary = container.read(practiceSessionRunnerProvider)!.summary!;
    await go(tester, Routes.practiceSummaryOf(summary.sessionId));

    await walk(tester, 'the practice summary');
  });
}
