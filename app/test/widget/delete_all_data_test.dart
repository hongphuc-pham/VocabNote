import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vocabnote/app.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';

import '../unit/application/fake_backup_files.dart';
import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';
import '../unit/data/db_fixtures.dart';

/// Settings → Your data → *Delete all data* and *Storage used*
/// (`docs/UI-UX.md` §4.9, RULES §11).
void main() {
  late AppDatabase db;
  late Directory support;
  late Directory library;
  late FakeReminderService reminders;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    support = await Directory.systemTemp.createTemp('vnb_delete_');
    library = await Directory(p.join(support.path, 'vocabnote')).create();
    reminders = FakeReminderService();
  });

  tearDown(() async {
    await db.close();
    await support.delete(recursive: true);
  });

  Future<void> openSettings(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: reminders,
          backupFiles: FakeBackupFiles(),
          exportDirectory: () async => support,
          libraryDirectory: () async => library,
        ),
      ],
    );
    // Container before database, or teardown deadlocks.
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  /// Pumps until [done], letting real time pass between frames - the delete
  /// removes real files, and storage is measured on disk.
  Future<void> settleUntil(WidgetTester tester, bool Function() done) async {
    for (var i = 0; i < 50 && !done(); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  bool showing(Finder finder) => finder.evaluate().isNotEmpty;

  /// Scrolls the settings list to [finder] and taps it.
  Future<void> tapRow(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<List<Object?>> wordIds(WidgetTester tester) async {
    final rows = await tester.runAsync(
      () => db.customSelect('SELECT id FROM words').get(),
    );
    return <Object?>[for (final row in rows!) row.data['id']];
  }

  final deleteRow = find.text('Delete all data');
  final firstStep = find.text('Delete everything?');
  final emptyLibrary = find.text('Your first word goes here');

  testWidgets('Storage used says how much the library takes', (tester) async {
    File(p.join(library.path, 'vocabnote.sqlite'))
        .writeAsBytesSync(List<int>.filled(2048, 1));
    await openSettings(tester);

    final size = find.text('2 KB');
    await tester.scrollUntilVisible(
      find.text('Storage used'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await settleUntil(tester, () => showing(size));

    expect(size, findsOneWidget);
  });

  testWidgets('offers a backup first, which opens Backup & restore', (
    tester,
  ) async {
    await seedWord(db, id: 'w1', headword: 'cough');
    await openSettings(tester);

    await tapRow(tester, deleteRow);
    expect(firstStep, findsOneWidget);
    await tester.tap(find.text('Make a backup first'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Backup & restore'),
      ),
      findsOneWidget,
    );
    expect(await wordIds(tester), <Object?>['w1']);
  });

  testWidgets('needs the word typed, then leaves an empty library', (
    tester,
  ) async {
    await seedWord(db, id: 'w1', headword: 'cough');
    await openSettings(tester);

    await tapRow(tester, deleteRow);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Lower case, and the keyboard is not forced into capitals: a screen
    // reader may spell an all-caps word out letter by letter.
    expect(find.text('Type “delete” to confirm'), findsOneWidget);
    final field = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    expect(
      tester.widget<TextField>(field).textCapitalization,
      TextCapitalization.none,
    );
    final confirm = find.widgetWithText(FilledButton, 'Delete everything');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.enterText(field, 'Delete');
    await tester.pump();
    await tester.tap(confirm);
    await settleUntil(tester, () => showing(emptyLibrary));

    expect(emptyLibrary, findsOneWidget);
    expect(await wordIds(tester), isEmpty);
    expect(reminders.cancels, 1);
  });

  testWidgets('Cancel at either step changes nothing', (tester) async {
    await seedWord(db, id: 'w1', headword: 'cough');
    await openSettings(tester);

    await tapRow(tester, deleteRow);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(firstStep, findsNothing);

    await tapRow(tester, deleteRow);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await wordIds(tester), <Object?>['w1']);
    expect(reminders.cancels, 0);
  });
}
