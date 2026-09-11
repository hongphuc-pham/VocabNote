/// Switching the daily reminder on and off, and choosing its time (F-066).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';

part 'reminder_controller.g.dart';

/// What switching the reminder on came to.
enum ReminderOutcome {
  /// On, and scheduled.
  on,

  /// The OS, or the user, said no. The reminder stays off.
  denied,

  /// Permission was given but scheduling failed. It stays off.
  failed,
}

/// The reminder's write side.
///
/// Every change goes to the OS first and the settings row second, so the
/// switch never says "on" for a reminder that was never scheduled.
@Riverpod(keepAlive: true)
class ReminderActions extends _$ReminderActions {
  @override
  void build() {}

  /// When the user has not chosen a time: early evening, after most days' work.
  static const int defaultMinutes = 19 * 60;

  Future<AppSettings> _settings() async =>
      (await ref.read(settingsRepositoryProvider).getSettings()).valueOrNull ??
      AppSettings.defaults;

  Future<void> _save(AppSettings settings) async {
    await ref.read(settingsRepositoryProvider).save(settings);
  }

  /// Switches the reminder on: asks permission, schedules, then records it.
  Future<ReminderOutcome> enable(ReminderCopy copy) async {
    final service = ref.read(reminderServiceProvider);
    final allowed = await service.requestPermission();
    if (!(allowed.valueOrNull ?? false)) return ReminderOutcome.denied;

    final settings = await _settings();
    final minutes = settings.reminderTimeMinutes ?? defaultMinutes;
    final scheduled = await service.scheduleDaily(
      minutesAfterMidnight: minutes,
      copy: copy,
    );
    if (scheduled.isErr) return ReminderOutcome.failed;

    await _save(
      settings.copyWith(reminderEnabled: true, reminderTimeMinutes: minutes),
    );
    return ReminderOutcome.on;
  }

  /// Switches the reminder off.
  ///
  /// Cancelled first, whatever happens to the save: an unwanted notification
  /// is worse than a switch out of step.
  Future<void> disable() async {
    await ref.read(reminderServiceProvider).cancel();
    await _save((await _settings()).copyWith(reminderEnabled: false));
  }

  /// Sets the time, and reschedules when the reminder is on.
  Future<void> setTime(int minutesAfterMidnight, ReminderCopy copy) async {
    final settings = await _settings();
    await _save(settings.copyWith(reminderTimeMinutes: minutesAfterMidnight));
    if (!settings.reminderEnabled) return;
    await ref
        .read(reminderServiceProvider)
        .scheduleDaily(minutesAfterMidnight: minutesAfterMidnight, copy: copy);
  }

  /// Schedules again from the current local time, when the reminder is on.
  ///
  /// Run once per launch. The schedule repeats on UTC, so a daylight saving
  /// change moves it by an hour until the next time this runs. It never asks
  /// for permission and never switches anything on.
  Future<void> resync(ReminderCopy copy) async {
    final settings = await _settings();
    final minutes = settings.reminderTimeMinutes;
    if (!settings.reminderEnabled || minutes == null) return;
    await ref
        .read(reminderServiceProvider)
        .scheduleDaily(minutesAfterMidnight: minutes, copy: copy);
  }
}
