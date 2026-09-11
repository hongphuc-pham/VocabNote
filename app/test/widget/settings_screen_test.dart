import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';

import '../unit/application/fake_reminder_service.dart';

/// Settings → Practice → Daily reminder (F-066, `docs/UI-UX.md` §4.9).
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late FakeReminderService reminders;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    reminders = FakeReminderService();
  });

  tearDown(() => db.close());

  Future<void> launch(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db, reminderService: reminders),
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
  }

  Future<void> openSettings(WidgetTester tester) async {
    await launch(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  /// The switch fires its write and does not await it; `pumpAndSettle` alone
  /// would return before the settings row changed.
  Future<void> settleAsync(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  bool switchValue(WidgetTester tester) =>
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value;

  testWidgets('launching the app asks nothing of the OS', (tester) async {
    // F-066: "asks permission only when enabled". RULES §6: no forced
    // notifications. Opening the app - even opening Settings - is not asking.
    await openSettings(tester);

    expect(reminders.permissionRequests, 0);
    expect(reminders.scheduled, isEmpty);
  });

  testWidgets('the reminder is off until switched on', (tester) async {
    await openSettings(tester);

    expect(find.text('Daily reminder'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
    expect(switchValue(tester), isFalse);
  });

  testWidgets('switching it on asks, then says when it will come', (
    tester,
  ) async {
    await openSettings(tester);

    await tester.tap(find.byType(SwitchListTile));
    await settleAsync(tester);

    expect(reminders.permissionRequests, 1);
    expect(switchValue(tester), isTrue);
    expect(find.text('Every day at 7:00 PM'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget, reason: 'the time can change');
  });

  testWidgets('a refusal says how to allow it, and stays off', (tester) async {
    reminders.grant = false;
    await openSettings(tester);

    await tester.tap(find.byType(SwitchListTile));
    await settleAsync(tester);

    expect(switchValue(tester), isFalse);
    expect(
      find.text(
        'Notifications are off for VocabNote. You can allow them in your '
        "phone's settings.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('switching it off cancels it', (tester) async {
    await openSettings(tester);
    await tester.tap(find.byType(SwitchListTile));
    await settleAsync(tester);

    await tester.tap(find.byType(SwitchListTile));
    await settleAsync(tester);

    expect(reminders.cancels, 1);
    expect(switchValue(tester), isFalse);
  });

  testWidgets('a reminder that is on is scheduled again at launch', (
    tester,
  ) async {
    // The schedule repeats on UTC; setting it again from local time at each
    // launch is what keeps a daylight saving change from lasting.
    await db.customStatement(
      'UPDATE settings SET reminder_enabled = 1, reminder_time_minutes = 480',
    );
    await launch(tester);
    await settleAsync(tester);

    expect(reminders.scheduled, <int>[480]);
    expect(reminders.permissionRequests, 0, reason: 'resync never asks');
  });
}
