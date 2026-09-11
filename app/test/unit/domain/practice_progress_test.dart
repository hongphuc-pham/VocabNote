import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/domain/entities/practice_progress.dart';

/// The streak and the daily goal (F-065), with no guilt built in (RULES §6).
void main() {
  final today = DateTime(2026, 9, 11);
  DateTime daysAgo(int n) => DateTime(today.year, today.month, today.day - n);

  PracticeProgress progress({
    int words = 0,
    Iterable<int> practised = const <int>[],
  }) => PracticeProgress(
    today: today,
    wordsToday: words,
    daysPractised: <DateTime>{for (final n in practised) daysAgo(n)},
  );

  group('streak', () {
    test('no practice is no streak', () {
      expect(progress().streak, 0);
    });

    test('today alone is one day', () {
      expect(progress(practised: <int>[0]).streak, 1);
    });

    test('consecutive days count back from today', () {
      expect(progress(practised: <int>[0, 1, 2]).streak, 3);
    });

    test('today not practised yet does not break it', () {
      // A day is not missed until it is over: in the morning, before the user
      // has practised, yesterday's run still stands.
      expect(progress(practised: <int>[1, 2]).streak, 2);
    });

    test('a gap ends the run', () {
      expect(progress(practised: <int>[0, 1, 3, 4, 5]).streak, 2);
    });

    test('two days without practice is no streak', () {
      expect(progress(practised: <int>[2, 3]).streak, 0);
    });

    test('runs across a month boundary', () {
      final first = DateTime(2026, 10);
      final run = PracticeProgress(
        today: first,
        wordsToday: 1,
        daysPractised: <DateTime>{
          first,
          DateTime(2026, 9, 30),
          DateTime(2026, 9, 29),
        },
      );
      expect(run.streak, 3);
    });

    test('runs across a daylight saving change', () {
      // 25 October 2026 is 25 hours long in Europe. Stepping back by calendar
      // day rather than by 24 hours keeps every date whole, wherever this runs.
      final day = DateTime(2026, 10, 26);
      final run = PracticeProgress(
        today: day,
        wordsToday: 1,
        daysPractised: <DateTime>{
          day,
          DateTime(2026, 10, 25),
          DateTime(2026, 10, 24),
        },
      );
      expect(run.streak, 3);
    });
  });

  group('goal', () {
    test('reached at the goal, not before', () {
      expect(progress(words: 19).goalReached(20), isFalse);
      expect(progress(words: 20).goalReached(20), isTrue);
    });

    test('the ring never overfills', () {
      expect(progress(words: 35).fractionOf(20), 1);
    });

    test('a zero goal is never reached and never divides by zero', () {
      expect(progress(words: 3).goalReached(0), isFalse);
      expect(progress(words: 3).fractionOf(0), 0);
    });
  });
}
