import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncResult;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/reminder_controller.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';

import 'fake_reminder_service.dart';

/// The daily reminder's write side (F-066), against a real settings row.
///
/// The rule this file exists for: **off by default, and permission asked only
/// when the user switches it on** - never at start-up, never twice.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late FakeReminderService reminders;

  const copy = ReminderCopy(
    title: 'title',
    body: 'body',
    channelName: 'channel',
    channelDescription: 'description',
  );

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    reminders = FakeReminderService();
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db, reminderService: reminders),
      ],
    );
  });

  tearDown(() async {
    // Container first, or teardown deadlocks.
    container.dispose();
    await db.close();
  });

  ReminderActions actions() => container.read(reminderActionsProvider.notifier);

  Future<AppSettings> stored() async =>
      (await container.read(settingsRepositoryProvider).getSettings())
          .valueOrNull!;

  test('off by default, with nothing asked of the OS', () async {
    expect((await stored()).reminderEnabled, isFalse);
    expect(reminders.permissionRequests, 0);
    expect(reminders.scheduled, isEmpty);
  });

  test('switching on asks, then schedules at 19:00 and records it', () async {
    final outcome = await actions().enable(copy);

    expect(outcome, ReminderOutcome.on);
    expect(reminders.permissionRequests, 1);
    expect(reminders.scheduled, <int>[19 * 60]);
    final settings = await stored();
    expect(settings.reminderEnabled, isTrue);
    expect(settings.reminderTimeMinutes, 19 * 60);
  });

  test('a time chosen earlier is the one scheduled', () async {
    await actions().setTime(7 * 60 + 30, copy);
    await actions().enable(copy);

    expect(reminders.scheduled, <int>[7 * 60 + 30]);
  });

  test('a refusal leaves it off and schedules nothing', () async {
    reminders.grant = false;

    expect(await actions().enable(copy), ReminderOutcome.denied);
    expect(reminders.scheduled, isEmpty);
    expect((await stored()).reminderEnabled, isFalse);
  });

  test('a failed schedule leaves it off - the switch never lies', () async {
    reminders.failSchedule = true;

    expect(await actions().enable(copy), ReminderOutcome.failed);
    expect((await stored()).reminderEnabled, isFalse);
  });

  test('switching off cancels it and records it', () async {
    await actions().enable(copy);
    await actions().disable();

    expect(reminders.cancels, 1);
    expect((await stored()).reminderEnabled, isFalse);
  });

  test('a new time reschedules when the reminder is on', () async {
    await actions().enable(copy);
    await actions().setTime(8 * 60, copy);

    expect(reminders.scheduled, <int>[19 * 60, 8 * 60]);
    expect((await stored()).reminderTimeMinutes, 8 * 60);
  });

  test('a new time while off is only remembered', () async {
    await actions().setTime(8 * 60, copy);

    expect(reminders.scheduled, isEmpty);
    expect(reminders.permissionRequests, 0);
    expect((await stored()).reminderTimeMinutes, 8 * 60);
  });

  test('resync schedules again only when it is on, and never asks', () async {
    await actions().resync(copy);
    expect(reminders.scheduled, isEmpty, reason: 'off: nothing to resync');

    await actions().enable(copy);
    await actions().resync(copy);
    expect(reminders.scheduled, <int>[19 * 60, 19 * 60]);
    expect(reminders.permissionRequests, 1, reason: 'only the switch asks');
  });
}
