import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';

/// When the next daily reminder is due (F-066).
void main() {
  const seven = 19 * 60;

  test('later today while the time is still ahead', () {
    expect(
      nextReminderAt(DateTime(2026, 9, 11, 8), seven),
      DateTime(2026, 9, 11, 19),
    );
  });

  test('tomorrow once the time has passed', () {
    expect(
      nextReminderAt(DateTime(2026, 9, 11, 20), seven),
      DateTime(2026, 9, 12, 19),
    );
  });

  test('exactly on the time counts as passed, never as now', () {
    expect(
      nextReminderAt(DateTime(2026, 9, 11, 19), seven),
      DateTime(2026, 9, 12, 19),
    );
  });

  test('rolls over the end of a month', () {
    expect(
      nextReminderAt(DateTime(2026, 9, 30, 21), seven),
      DateTime(2026, 10, 1, 19),
    );
  });

  test('keeps the minutes', () {
    expect(
      nextReminderAt(DateTime(2026, 9, 11, 6), 7 * 60 + 45),
      DateTime(2026, 9, 11, 7, 45),
    );
  });
}
