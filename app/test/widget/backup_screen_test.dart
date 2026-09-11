import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';

import '../unit/application/fake_backup_files.dart';
import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';

/// Backup & restore (F-073, `docs/UI-UX.md` §4.9).
void main() {
  late AppDatabase db;
  late Directory folder;
  late FakeBackupFiles files;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    folder = await Directory.systemTemp.createTemp('vnb_screen_');
    files = FakeBackupFiles();
  });

  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
  });

  Future<void> openBackup(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
          backupFiles: files,
          exportDirectory: () async => folder,
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

    final row = find.text('Backup & restore');
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    // scrollUntilVisible stops once the row is built, which can still be
    // below the 600px test surface; a tap there silently misses.
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
  }

  /// Pumps until [done], letting real time pass between frames.
  ///
  /// Exporting encodes on another isolate, lists a folder and writes a real
  /// file. Each of those completes in real time, and each completion then
  /// needs a frame in the test's fake time before the next step can start -
  /// so one long wait is not enough, and a fixed number of short ones is a
  /// guess. Capped, so a genuinely stuck export fails rather than hangs.
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

  testWidgets('says plainly when there has never been a backup', (
    tester,
  ) async {
    await openBackup(tester);

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Backup & restore'),
      ),
      findsOneWidget,
    );
    expect(find.text("You haven't made a backup yet."), findsOneWidget);
  });

  testWidgets('Export hands a .vnb to the share sheet and remembers it', (
    tester,
  ) async {
    await openBackup(tester);

    await tester.tap(find.text('Export backup'));
    await settleUntil(
      tester,
      () => showing(find.textContaining('Last backup:')),
    );

    expect(files.shared, hasLength(1));
    expect(files.shared.single.path, endsWith('.vnb'));
    expect(find.textContaining('Last backup:'), findsOneWidget);
    expect(find.text("You haven't made a backup yet."), findsNothing);
  });

  testWidgets('a share sheet that fails says so, and nothing is recorded', (
    tester,
  ) async {
    files.fail = true;
    await openBackup(tester);
    final failed = find.text(
      "Couldn't make the backup just now. Your words are safe - please "
      'try again.',
    );

    await tester.tap(find.text('Export backup'));
    await settleUntil(tester, () => showing(failed));

    expect(failed, findsOneWidget);
    expect(find.text("You haven't made a backup yet."), findsOneWidget);
  });
}
