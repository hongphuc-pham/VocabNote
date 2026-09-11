import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';

/// [ReminderService] on `flutter_local_notifications` (F-066).
///
/// Two choices worth knowing about:
///
/// - **Inexact** (`inexactAllowWhileIdle`). A reminder a few minutes late is
///   fine; an exact alarm needs `SCHEDULE_EXACT_ALARM`, which Android 13+ does
///   not pre-grant and Google Play restricts.
/// - **Repeating on UTC.** Repeating on the local time of day needs the
///   device's IANA zone name, and reading that needs a plugin `docs/RULES.md`
///   has not approved (`flutter_timezone`). UTC needs no timezone database at
///   all. The cost is that across a daylight saving change the reminder drifts
///   by an hour — until the app next opens, when the shell schedules it again
///   from the current local time.
class LocalNotificationsReminderService implements ReminderService {
  /// Creates the service. Inert until first used, so building the composition
  /// root in a widget test never reaches a platform channel.
  new({FlutterLocalNotificationsPlugin? plugin, DateTime Function()? now})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
      _now = now ?? DateTime.now;

  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _now;
  Future<void>? _initialised;

  /// One reminder, so one id: scheduling again replaces it.
  static const int _reminderId = 1;
  static const String _channelId = 'daily_reminder';

  Future<void> _ensureInitialised() => _initialised ??= _plugin
      .initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Never on initialise: permission is asked only when the user
          // switches the reminder on.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        ),
      )
      .then((_) {});

  @override
  AsyncResult<bool> requestPermission() => Results.guard(
    () async {
      await _ensureInitialised();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, sound: true) ?? false;
      }
      return false;
    },
    onError: (error, stackTrace) => PermissionFailure(
      permission: 'notifications',
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  @override
  AsyncResult<void> scheduleDaily({
    required int minutesAfterMidnight,
    required ReminderCopy copy,
  }) => Results.guard(
    () async {
      await _ensureInitialised();
      final next = nextReminderAt(_now(), minutesAfterMidnight);
      await _plugin.zonedSchedule(
        id: _reminderId,
        scheduledDate: tz.TZDateTime.from(next.toUtc(), tz.UTC),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            copy.channelName,
            channelDescription: copy.channelDescription,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: copy.title,
        body: copy.body,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    },
    onError: (error, stackTrace) => UnavailableFailure(
      capability: 'notifications',
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  @override
  AsyncResult<void> cancel() => Results.guard(
    () async {
      await _ensureInitialised();
      await _plugin.cancel(id: _reminderId);
    },
    onError: (error, stackTrace) => UnavailableFailure(
      capability: 'notifications',
      cause: error,
      stackTrace: stackTrace,
    ),
  );
}
