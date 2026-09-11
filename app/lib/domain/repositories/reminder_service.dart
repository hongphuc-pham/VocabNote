/// The daily reminder, as an interface (F-066).
///
/// An interface for the same reasons as `SpeechService`: nothing above `data/`
/// may name a notification plugin, and a test can record what would have been
/// asked of the OS without a device.
library;

import 'package:meta/meta.dart';
import 'package:vocabnote/core/result.dart';

/// The words of the reminder. Supplied by the caller, so they are localised.
@immutable
class ReminderCopy {
  /// Creates the copy.
  const new({
    required this.title,
    required this.body,
    required this.channelName,
    required this.channelDescription,
  });

  /// The notification's title.
  final String title;

  /// Its one line of text.
  final String body;

  /// The name Android shows for the notification channel in system settings.
  final String channelName;

  /// The channel's description there.
  final String channelDescription;
}

/// Shows one gentle reminder a day.
abstract interface class ReminderService {
  /// Asks the OS whether the app may notify, and resolves to its answer.
  ///
  /// Called only when the user switches the reminder on — never at start-up
  /// (F-066: "asks permission only when enabled"; `docs/RULES.md` §6: no
  /// forced notifications).
  AsyncResult<bool> requestPermission();

  /// Schedules the reminder every day at [minutesAfterMidnight], local time,
  /// replacing any earlier one.
  AsyncResult<void> scheduleDaily({
    required int minutesAfterMidnight,
    required ReminderCopy copy,
  });

  /// Cancels the reminder. Safe when none is scheduled.
  AsyncResult<void> cancel();
}

/// The next moment after [now] that reads [minutesAfterMidnight] on the clock:
/// later today, or tomorrow once that time has passed.
///
/// Built from calendar fields rather than by adding hours, so a day with a
/// daylight saving change still lands on the right wall-clock time.
DateTime nextReminderAt(DateTime now, int minutesAfterMidnight) {
  final hour = minutesAfterMidnight ~/ 60;
  final minute = minutesAfterMidnight % 60;
  final today = DateTime(now.year, now.month, now.day, hour, minute);
  return today.isAfter(now)
      ? today
      : DateTime(now.year, now.month, now.day + 1, hour, minute);
}
