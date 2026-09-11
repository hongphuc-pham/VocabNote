import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/application/settings/app_info.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/presentation/common/typed_confirm_dialog.dart';
import 'package:vocabnote/presentation/lists/list_editor_sheet.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';
import 'package:vocabnote/presentation/practice/quick_test_sheet.dart';
import 'package:vocabnote/presentation/settings/error_log_sheet.dart';
import 'package:vocabnote/presentation/settings/import_preview_sheet.dart';
import 'package:vocabnote/presentation/settings/import_report_dialog.dart';
import 'package:vocabnote/presentation/settings/interval_editor_sheet.dart';
import 'package:vocabnote/presentation/settings/privacy_note.dart';
import 'package:vocabnote/presentation/words/highlight_color_sheet.dart';

import '../unit/application/fake_backup_files.dart';
import '../unit/application/fake_links.dart';
import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';
import '../unit/data/db_fixtures.dart';
import 'accessibility_support.dart';

/// Flutter's accessibility guidelines over the sheets and dialogs, light and
/// dark (`docs/UI-UX.md` §6, F-093, M7 A1) - the half of the app that
/// `accessibility_guidelines_test.dart` cannot reach by route.
///
/// Each is opened inside the real app, so it wears the real theme and reads
/// the real providers: directly through its `show` where it has one, by the
/// taps a user makes where it does not. Then it is walked top to bottom and
/// checked at every stop, as the screens are.
///
/// Not opened here, each for a stated reason: the word editor's and IPA
/// editor's discard dialogs and the word editor's delete dialog (plain
/// `AlertDialog`s of the shape checked below, behind multi-step edit flows),
/// and the summary's add-to-list sheet (it needs a whole session played first;
/// its list rows are the `ListTile`s checked in list actions).
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() => EditableText.debugDeterministicCursor = true);
  tearDownAll(() => EditableText.debugDeterministicCursor = false);

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    await seedWord(db, id: 'w1', headword: 'cough', ipaUk: 'kɒf');
    await seedWord(db, id: 'w2', headword: 'church', ipaUk: 'tʃɜːtʃ');
    await seedNote(db, id: 'n1', wordId: 'w1', body: 'rounder lips here');
    await seedList(db, id: 'l1', name: 'IELTS');
    await seedMembership(db, listId: 'l1', wordId: 'w1');
  });

  tearDown(() => db.close());

  void phoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpApp(
    WidgetTester tester,
    Brightness brightness, {
    String? feedback,
  }) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        feedbackAddressProvider.overrideWithValue(feedback),
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
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await settle(tester);
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      brightness,
    );
  }

  Future<void> go(WidgetTester tester, String location, {Object? extra}) async {
    container.read(appRouterProvider).go(location, extra: extra);
    await settle(tester);
  }

  /// The tallest vertical scroll view on stage, optionally only inside
  /// [within] - a sheet leaves the page beneath it on stage.
  ScrollPosition? tallestScroll(WidgetTester tester, {Finder? within}) {
    final scrollables = within == null
        ? find.byType(Scrollable)
        : find.descendant(of: within, matching: find.byType(Scrollable));
    ScrollPosition? best;
    for (final element in scrollables.evaluate()) {
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

  /// Scrolls the page until [target] is built, then taps it.
  Future<void> tapInPage(
    WidgetTester tester,
    Finder target, {
    bool long = false,
  }) async {
    for (var i = 0; i < 30 && target.evaluate().isEmpty; i++) {
      final position = tallestScroll(tester);
      if (position == null || position.pixels >= position.maxScrollExtent) {
        break;
      }
      position.jumpTo(
        math.min(position.pixels + 300, position.maxScrollExtent),
      );
      await tester.pump();
    }
    await tester.ensureVisible(target);
    await tester.pump();
    if (long) {
      await tester.longPress(target);
    } else {
      await tester.tap(target);
    }
    await settle(tester);
  }

  /// The sheet or dialog now on top.
  Finder topmost() => find
      .byWidgetPredicate(
        (widget) =>
            widget is BottomSheet || widget is Dialog || widget is AlertDialog,
      )
      .last;

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
    await expectLater(
      tester,
      meetsGuideline(pressableButtonsGuideline),
      reason: where,
    );
  }

  Future<void> walkSheet(WidgetTester tester, String sheet) async {
    expect(topmost(), findsOneWidget, reason: '$sheet did not open');
    for (var stop = 0; stop < 40; stop++) {
      await meetsGuidelines(tester, '$sheet, stop $stop');
      final position = tallestScroll(tester, within: topmost());
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

  /// Sheets and dialogs with a `show` of their own.
  final direct = <(String, Future<Object?> Function(BuildContext))>[
    ('list editor', ListEditorSheet.show),
    (
      'quick-test config',
      (context) => QuickTestSheet.show(context, gameId: FlashcardGame.gameId),
    ),
    ('error log', ErrorLogSheet.show),
    ('highlight colour', HighlightColorSheet.show),
    (
      'typed confirmation',
      (context) => showTypedConfirmation(
        context,
        title: 'Delete all data?',
        body: 'Everything on this phone goes.',
        word: 'delete',
        action: 'Delete everything',
      ),
    ),
    (
      'import report',
      (context) => showImportReport(
        context,
        const ImportReport(
          wordsAdded: 3,
          wordsUpdated: 1,
          notesAdded: 2,
          rejected: 1,
        ),
        ImportMode.replace,
      ),
    ),
    (
      'import preview',
      (context) => ImportPreviewSheet.show(
        context,
        BackupManifest(
          appVersion: '1.0.0',
          schemaVersion: 2,
          formatVersion: 1,
          exportedAt: DateTime.utc(2026, 9, 11),
          counts: const <String, int>{'words': 240, 'word_lists': 3},
        ),
      ),
    ),
    ('privacy', PrivacyNote.show),
    (
      'interval editor',
      (context) => IntervalEditorSheet.show(context, ReviewSchedule.standard),
    ),
  ];

  /// Sheets and dialogs reached only by the taps a user makes.
  final byTaps = <(String, Future<void> Function(WidgetTester))>[
    (
      'list actions',
      (tester) async {
        await go(tester, Routes.lists);
        await tapInPage(tester, find.byTooltip('Actions for IELTS'));
      },
    ),
    (
      'delete a list',
      (tester) async {
        await go(tester, Routes.lists);
        await tapInPage(tester, find.byTooltip('Actions for IELTS'));
        await tester.tap(
          find.descendant(of: topmost(), matching: find.text('Delete list')),
        );
        await settle(tester);
      },
    ),
    (
      'note editor',
      (tester) async {
        await go(tester, Routes.wordDetailOf('w1'));
        await tapInPage(tester, find.widgetWithText(TextButton, 'Add'));
      },
    ),
    (
      'a settings choice',
      (tester) async {
        await go(tester, Routes.settings);
        await tapInPage(tester, find.text('Theme'));
      },
    ),
    (
      'delete all data, first step',
      (tester) async {
        await go(tester, Routes.settings);
        await tapInPage(tester, find.text('Delete all data'));
      },
    ),
    (
      'word actions',
      (tester) async {
        await go(tester, Routes.words);
        await tapInPage(tester, find.text('cough'), long: true);
      },
    ),
    (
      'leave a daily review',
      (tester) async {
        await go(
          tester,
          Routes.practiceRunOf(FlashcardGame.gameId),
          extra: GameConfig(
            gameId: FlashcardGame.gameId,
            mode: PracticeMode.daily,
            selection: CardSelection.due,
            limit: 20,
          ),
        );
        await tester.tap(find.byTooltip('Close practice'));
        await settle(tester);
      },
    ),
    (
      'a font licence',
      (tester) async {
        await go(tester, Routes.licences);
        await tapInPage(
          tester,
          find.descendant(
            of: find.widgetWithText(OverflowBar, 'Inter'),
            matching: find.text('View licence'),
          ),
        );
      },
    ),
  ];

  for (final (theme, brightness) in <(String, Brightness)>[
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    group('$theme theme', () {
      setUp(
        () => db.customStatement("UPDATE settings SET theme_mode = '$theme'"),
      );

      for (final (name, show) in direct) {
        testWidgets(name, (tester) async {
          phoneSize(tester);
          final semantics = tester.ensureSemantics();
          try {
            await pumpApp(tester, brightness);
            unawaited(show(tester.element(find.byType(Scaffold).first)));
            await settle(tester);

            await walkSheet(tester, '$theme $name');
          } finally {
            semantics.dispose();
          }
        });
      }

      for (final (name, open) in byTaps) {
        testWidgets(name, (tester) async {
          phoneSize(tester);
          final semantics = tester.ensureSemantics();
          try {
            await pumpApp(tester, brightness);
            await open(tester);

            await walkSheet(tester, '$theme $name');
          } finally {
            semantics.dispose();
          }
        });
      }

      testWidgets('feedback preview', (tester) async {
        phoneSize(tester);
        final semantics = tester.ensureSemantics();
        try {
          await pumpApp(tester, brightness, feedback: 'feedback@example.com');
          await go(tester, Routes.help);
          await tapInPage(tester, find.text('Send feedback'));

          await walkSheet(tester, '$theme feedback preview');
        } finally {
          semantics.dispose();
        }
      });
    });
  }
}
