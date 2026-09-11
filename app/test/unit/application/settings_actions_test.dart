import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/settings_actions.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';

import 'fake_reminder_service.dart';
import 'fake_speech_service.dart';

/// The settings screen's write side (F-070, `docs/UI-UX.md` §4.9).
///
/// Against a real in-memory database, because what matters is what lands in
/// the settings row - and whether two changes made together both land.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.memory();
    container = ProviderContainer(
      overrides: <Override>[
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
        ),
      ],
    );
  });

  tearDown(() async {
    // Container before database, or teardown deadlocks.
    container.dispose();
    await db.close();
  });

  SettingsActions actions() => container.read(settingsActionsProvider.notifier);

  Future<AppSettings> stored() async =>
      (await container.read(settingsRepositoryProvider).getSettings())
          .valueOrNull!;

  test('every choice is written to the settings row', () async {
    await actions().setTheme(ThemePreference.dark);
    await actions().setVoice(TtsLocale.enUs);
    await actions().setRate(0.35);
    await actions().setPitch(1.2);
    await actions().setAutoplay(enabled: true);
    await actions().setDailyGoal(30);
    await actions().setPromptSide(PromptSide.ipaFirst);
    await actions().setAgainRepeats(2);
    await actions().setLookupEnabled(enabled: false);

    final settings = await stored();
    expect(settings.themeMode, ThemePreference.dark);
    expect(settings.ttsLocale, TtsLocale.enUs);
    expect(settings.ttsRate, 0.35);
    expect(settings.ttsPitch, 1.2);
    expect(settings.autoplayOnOpen, isTrue);
    expect(settings.dailyGoal, 30);
    expect(settings.promptSide, PromptSide.ipaFirst);
    expect(settings.againRepeats, 2);
    expect(settings.lookupEnabled, isFalse);
  });

  test('changes made at the same moment all land', () async {
    // A slider released while a switch is flipped: each is a read-modify-write
    // of one row, and without a transaction the later write would restore the
    // earlier one's stale copy of everything else.
    await Future.wait(<Future<void>>[
      actions().setRate(0.3),
      actions().setPitch(1.5),
      actions().setTheme(ThemePreference.light),
      actions().setDailyGoal(10),
    ]);

    final settings = await stored();
    expect(settings.ttsRate, 0.3);
    expect(settings.ttsPitch, 1.5);
    expect(settings.themeMode, ThemePreference.light);
    expect(settings.dailyGoal, 10);
  });

  test('a change leaves the reminder exactly as it was', () async {
    // The reminder has its own write side (ReminderActions); nothing here may
    // switch it off or forget its time.
    await db.customStatement(
      'UPDATE settings SET reminder_enabled = 1, reminder_time_minutes = 480',
    );

    await actions().setTheme(ThemePreference.dark);

    final settings = await stored();
    expect(settings.reminderEnabled, isTrue);
    expect(settings.reminderTimeMinutes, 480);
  });

  group('the repetition schedule (GAMES.md §5)', () {
    Future<ReviewSchedule> storedSchedule() async =>
        ReviewSchedule.fromStoredJson((await stored()).reviewScheduleJson);

    test('a new install is on the standard pace', () async {
      expect((await storedSchedule()).pace, IntervalPace.standard);
    });

    test('picking a pace writes the table that pace produces', () async {
      await actions().setPace(IntervalPace.gentle);

      final schedule = await storedSchedule();
      expect(schedule, ReviewSchedule.forPace(IntervalPace.gentle));
      expect(schedule.pace, IntervalPace.gentle);
    });

    test('a valid table of the user own is saved', () async {
      const own = ReviewSchedule(<int>[0, 1, 3, 5, 8, 20, 40]);

      final issue = await actions().setSchedule(own);

      expect(issue, isNull);
      expect(await storedSchedule(), own);
      expect(own.pace, isNull, reason: 'an edited table is no preset');
    });

    test('a table that would stop words coming back is refused', () async {
      const broken = ReviewSchedule(<int>[0, 1, 0, 4, 7, 15, 30]);

      final issue = await actions().setSchedule(broken);

      expect(issue, isA<BoxTooShort>().having((i) => i.box, 'box', 2));
      expect(
        await storedSchedule(),
        ReviewSchedule.standard,
        reason: 'nothing is written when the table is refused',
      );
    });
  });
}
