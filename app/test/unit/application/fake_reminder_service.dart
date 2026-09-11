import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';

/// Records what would have been asked of the OS, instead of asking it.
///
/// A recording fake rather than a mock, as with speech: every assertion about
/// the reminder is about *what the app asked for* - whether it asked for
/// permission at all, and for which time.
class FakeReminderService implements ReminderService {
  /// What the permission prompt answers.
  bool grant = true;

  /// Makes scheduling fail, as a device refusing alarms would.
  bool failSchedule = false;

  /// How many times permission was asked for.
  int permissionRequests = 0;

  /// Every time scheduled, in minutes after midnight, in order.
  final List<int> scheduled = <int>[];

  /// How many times the reminder was cancelled.
  int cancels = 0;

  @override
  AsyncResult<bool> requestPermission() async {
    permissionRequests++;
    return Ok<bool, AppFailure>(grant);
  }

  @override
  AsyncResult<void> scheduleDaily({
    required int minutesAfterMidnight,
    required ReminderCopy copy,
  }) async {
    if (failSchedule) {
      return const Err<void, AppFailure>(
        UnavailableFailure(capability: 'notifications'),
      );
    }
    scheduled.add(minutesAfterMidnight);
    return const Ok<void, AppFailure>(null);
  }

  @override
  AsyncResult<void> cancel() async {
    cancels++;
    return const Ok<void, AppFailure>(null);
  }
}
