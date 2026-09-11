import 'dart:math' as math;

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

import '../unit/application/fake_backup_files.dart';
import '../unit/application/fake_links.dart';
import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';
import '../unit/data/db_fixtures.dart';

/// Flutter's accessibility guidelines over every screen, light and dark
/// (`docs/UI-UX.md` §6, F-093, M7 A1).
///
/// At every stop down each screen: tap targets of at least 48×48dp, a label
/// on everything tappable, and rendered text contrast. The guidelines only see
/// semantics nodes that are built and on screen, so each screen is walked top
/// to bottom and checked at every stop - a check at the top alone would pass a
/// broken row that happens to sit below the fold. A node cut by the edge of the
/// viewport is skipped by the guideline itself, so the stops can land anywhere.
///
/// Text contrast here is the second net: `textContrastGuideline` guesses each
/// background from rendered pixels and is known to pass subtle failures
/// (flutter/flutter#103235). `theme_contrast_test.dart` is the gate.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() => EditableText.debugDeterministicCursor = true);
  tearDownAll(() => EditableText.debugDeterministicCursor = false);

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    // Something on every screen: IPA with a highlight, a note, a list.
    await seedWord(
      db,
      id: 'w1',
      headword: 'cough',
      ipaUk: 'kɒf',
      ipaUs: 'kɔːf',
      definition: 'a sudden, noisy push of air out of the lungs',
      example: 'a dry cough',
    );
    await seedWord(db, id: 'w2', headword: 'church', ipaUk: 'tʃɜːtʃ');
    await seedWord(db, id: 'w3', headword: 'thing', ipaUk: 'θɪŋ');
    await seedWord(db, id: 'w4', headword: 'though', isFavourite: true);
    await seedHighlight(db, id: 'h1', wordId: 'w1', start: 1, label: 'lips');
    await seedNote(db, id: 'n1', wordId: 'w1', body: 'rounder lips here');
    await seedList(db, id: 'l1', name: 'IELTS');
    await seedMembership(db, listId: 'l1', wordId: 'w1');
    await seedMembership(db, listId: 'l1', wordId: 'w2');
  });

  tearDown(() => db.close());

  /// A common phone: 360×780dp.
  void phoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// Frames plus real time: several screens show an indeterminate spinner
  /// while they load, which `pumpAndSettle` would wait on for ever.
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
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
          backupFiles: FakeBackupFiles(),
          linkOpener: FakeLinkOpener(),
          diagnostics: FakeDiagnostics(),
        ),
      ],
    );
    // Container before database, or teardown deadlocks.
    addTearDown(container.dispose);
  }

  Future<void> pumpApp(WidgetTester tester, Brightness brightness) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await settle(tester);
    // The theme comes from the saved setting; make sure it took, or a "dark"
    // run would quietly check the light theme twice.
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      brightness,
    );
  }

  /// The screen's own vertical scroll view: the tallest one on stage, so a
  /// multi-line text field inside it is not mistaken for the page.
  ScrollPosition? pageScroll(WidgetTester tester) {
    ScrollPosition? best;
    for (final element in find.byType(Scrollable).evaluate()) {
      final position = (element as StatefulElement).state as ScrollableState;
      final candidate = position.position;
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

  Future<void> meetsGuidelines(WidgetTester tester, String where) async {
    await expectLater(
      tester,
      meetsGuideline(androidTapTargetGuideline),
      reason: where,
    );
    await expectLater(
      tester,
      meetsGuideline(labeledTapTargetGuideline),
      reason: where,
    );
    await expectLater(
      tester,
      meetsGuideline(textContrastGuideline),
      reason: where,
    );
  }

  /// Checks the screen at the top, then a screen-height at a time to the end.
  Future<void> walk(WidgetTester tester, String screen) async {
    for (var stop = 0; stop < 40; stop++) {
      await meetsGuidelines(tester, '$screen, stop $stop');
      final position = pageScroll(tester);
      if (position == null || position.pixels >= position.maxScrollExtent) {
        return;
      }
      position.jumpTo(
        math.min(
          position.pixels + position.viewportDimension * 0.8,
          position.maxScrollExtent,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Every screen reached through the router, as a tap would reach it.
  final screens = <(String, String, Object?)>[
    ('words', Routes.words, null),
    ('word detail', Routes.wordDetailOf('w1'), null),
    ('word editor', Routes.wordEditOf('w1'), null),
    ('new word', Routes.wordAdd, null),
    ('IPA editor', Routes.wordIpaOf('w1'), null),
    ('lists', Routes.lists, null),
    ('list detail', Routes.listDetailOf('l1'), null),
    ('practice hub', Routes.practice, null),
    (
      'practice run',
      Routes.practiceRunOf(FlashcardGame.gameId),
      GameConfig(
        gameId: FlashcardGame.gameId,
        mode: PracticeMode.quickTest,
        selection: CardSelection.random,
        limit: 4,
        seed: 1,
      ),
    ),
    ('settings', Routes.settings, null),
    ('how to use', Routes.guide, null),
    ('help & feedback', Routes.help, null),
    ('backup & restore', Routes.backup, null),
    ('data sources & licences', Routes.licences, null),
    ('onboarding', Routes.onboarding, null),
  ];

  for (final (theme, brightness) in <(String, Brightness)>[
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    group('$theme theme', () {
      setUp(
        () => db.customStatement("UPDATE settings SET theme_mode = '$theme'"),
      );

      for (final (name, location, extra) in screens) {
        testWidgets(name, (tester) async {
          phoneSize(tester);
          final semantics = tester.ensureSemantics();
          try {
            openContainer();
            await pumpApp(tester, brightness);
            container.read(appRouterProvider).go(location, extra: extra);
            await settle(tester);

            await walk(tester, '$theme $name');
          } finally {
            semantics.dispose();
          }
        });
      }

      testWidgets('practice summary', (tester) async {
        phoneSize(tester);
        final semantics = tester.ensureSemantics();
        try {
          openContainer();
          // The runner is auto-disposed; hold it as the run screen would.
          final keepAlive = container.listen(
            practiceSessionRunnerProvider,
            (_, _) {},
          );
          addTearDown(keepAlive.close);
          // Played on real async and before the app is pumped - see
          // `practice_summary_test.dart` for the hang this avoids.
          await tester.runAsync(() async {
            final runner = container.read(
              practiceSessionRunnerProvider.notifier,
            );
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
              ReviewOutcome.good,
              ReviewOutcome.again,
              ReviewOutcome.easy,
              ReviewOutcome.good,
            ]) {
              await runner.answer(
                game,
                GameAnswer(result: result, elapsed: const Duration(seconds: 2)),
              );
            }
          });
          await pumpApp(tester, brightness);
          final summary = container.read(practiceSessionRunnerProvider)!;
          container
              .read(appRouterProvider)
              .go(Routes.practiceSummaryOf(summary.summary!.sessionId));
          await settle(tester);

          await walk(tester, '$theme practice summary');
        } finally {
          semantics.dispose();
        }
      });
    });
  }
}
