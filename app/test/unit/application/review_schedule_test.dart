import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/practice/scheduler/leitner_scheduler.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/domain/entities/study_card.dart';

/// The user's own repetition schedule (F-061).
///
/// `docs/GAMES.md` §5 fixed the interval table; it is now a default. The rule
/// that matters most here is that **the default must not have moved** — a user
/// who never opens Settings has to get exactly the documented behaviour.
void main() {
  group('the default is still the documented table', () {
    test('standard is the GAMES.md §5 table, unchanged', () {
      expect(ReviewSchedule.standard.intervalDays, <int>[
        0,
        1,
        2,
        4,
        7,
        15,
        30,
      ]);
    });

    test('a scheduler built with no schedule uses standard', () {
      expect(const LeitnerScheduler().schedule, ReviewSchedule.standard);
    });

    test('the standard pace is the standard table, not a rounded copy', () {
      expect(
        ReviewSchedule.forPace(IntervalPace.standard),
        ReviewSchedule.standard,
      );
    });
  });

  group('pace presets', () {
    test('gentle waits longer than standard everywhere past box 0', () {
      final gentle = ReviewSchedule.forPace(IntervalPace.gentle);
      for (var box = 1; box < ReviewSchedule.boxCount; box++) {
        expect(
          gentle.daysForBox(box),
          greaterThanOrEqualTo(ReviewSchedule.standard.daysForBox(box)),
          reason: 'box $box',
        );
      }
    });

    test('intensive waits less than standard everywhere past box 0', () {
      final intensive = ReviewSchedule.forPace(IntervalPace.intensive);
      for (var box = 1; box < ReviewSchedule.boxCount; box++) {
        expect(
          intensive.daysForBox(box),
          lessThanOrEqualTo(ReviewSchedule.standard.daysForBox(box)),
          reason: 'box $box',
        );
      }
    });

    test('box 0 stays same-day at every pace', () {
      // Box 0 means "you just failed this; see it again in ten minutes".
      // Scaling that into tomorrow would defeat the point of a lapse.
      for (final pace in IntervalPace.values) {
        expect(
          ReviewSchedule.forPace(pace).daysForBox(0),
          0,
          reason: pace.name,
        );
      }
    });

    test('no preset can round a box down to never resurfacing', () {
      // intensive × 1 day rounds to 1, not 0. A 0 in box 1+ means the card is
      // due immediately for ever and never progresses.
      for (final pace in IntervalPace.values) {
        final schedule = ReviewSchedule.forPace(pace);
        expect(
          schedule.isValid,
          isTrue,
          reason: '${pace.name}: ${schedule.problem}',
        );
        for (var box = 1; box < ReviewSchedule.boxCount; box++) {
          expect(schedule.daysForBox(box), greaterThanOrEqualTo(1));
        }
      }
    });
  });

  group('validating a hand-edited table', () {
    test('accepts the presets and the default', () {
      expect(ReviewSchedule.standard.problem, isNull);
      for (final pace in IntervalPace.values) {
        expect(ReviewSchedule.forPace(pace).problem, isNull);
      }
    });

    test('rejects a table that never brings a word back', () {
      // The hazard the user's own choice can create, and the reason validation
      // exists at all.
      const schedule = ReviewSchedule(<int>[0, 1, 2, 0, 7, 15, 30]);
      expect(schedule.isValid, isFalse);
      expect(schedule.problem, contains('never come back'));
    });

    test('rejects a table that goes backwards', () {
      const schedule = ReviewSchedule(<int>[0, 1, 2, 4, 3, 15, 30]);
      expect(schedule.problem, contains('shorter than box'));
    });

    test('rejects the wrong number of boxes', () {
      const schedule = ReviewSchedule(<int>[0, 1, 2]);
      expect(schedule.problem, contains('exactly 7'));
    });

    test('rejects a non-zero box 0', () {
      const schedule = ReviewSchedule(<int>[3, 4, 5, 6, 7, 15, 30]);
      expect(schedule.problem, contains('relearning box'));
    });

    test('says what is wrong, not merely that something is', () {
      // A user editing seven numbers by hand will get it wrong, and "invalid"
      // is not a helpful thing to be told.
      const schedule = ReviewSchedule(<int>[0, 1, 2, 0, 7, 15, 30]);
      expect(schedule.problem, contains('Box 3'));
    });
  });

  group('the reason, typed for Settings to put into words', () {
    // Settings shows the reason in the user's language (RULES §22), so it
    // needs to know *which* rule broke and where - not an English sentence.
    test('a sound table has no issue', () {
      expect(ReviewSchedule.standard.issue, isNull);
    });

    test('a box of zero days names that box', () {
      const schedule = ReviewSchedule(<int>[0, 1, 2, 0, 7, 15, 30]);
      expect(schedule.issue, isA<BoxTooShort>().having((i) => i.box, 'box', 3));
    });

    test('a box shorter than the one before names both', () {
      const schedule = ReviewSchedule(<int>[0, 1, 2, 4, 3, 15, 30]);
      expect(
        schedule.issue,
        isA<BoxShorterThanPrevious>().having((i) => i.box, 'box', 4),
      );
    });

    test('the wrong number of boxes says how many there were', () {
      const schedule = ReviewSchedule(<int>[0, 1, 2]);
      expect(
        schedule.issue,
        isA<WrongBoxCount>().having((i) => i.count, 'count', 3),
      );
    });

    test('a non-zero box 0 is its own issue', () {
      const schedule = ReviewSchedule(<int>[3, 4, 5, 6, 7, 15, 30]);
      expect(schedule.issue, isA<RelearningBoxNotZero>());
    });
  });

  group('which pace a table is', () {
    test('each preset is recognised as itself', () {
      for (final pace in IntervalPace.values) {
        expect(ReviewSchedule.forPace(pace).pace, pace);
      }
    });

    test('a table nudged by one box is no preset', () {
      // Settings then shows "Your own" rather than claiming a pace the user
      // has since moved away from.
      const nudged = ReviewSchedule(<int>[0, 1, 2, 5, 7, 15, 30]);
      expect(nudged.pace, isNull);
    });
  });

  group('storage', () {
    test('round-trips a custom table', () {
      const custom = ReviewSchedule(<int>[0, 2, 5, 9, 14, 21, 60]);
      expect(ReviewSchedule.fromJson(custom.toJson()), custom);
    });

    test('an unusable stored table falls back to the default', () {
      // Practice must never be stopped by a bad stored setting.
      expect(
        ReviewSchedule.fromJson(const <int>[0, 0, 0]),
        ReviewSchedule.standard,
      );
      expect(ReviewSchedule.fromJson('nonsense'), ReviewSchedule.standard);
      expect(ReviewSchedule.fromJson(null), ReviewSchedule.standard);
    });
  });

  group('the scheduler honours the chosen table', () {
    final now = DateTime.utc(2026, 9, 10, 12);

    test('a custom interval is the one actually applied', () {
      const custom = ReviewSchedule(<int>[0, 3, 6, 12, 20, 40, 90]);
      final card = StudyCard(wordId: 'w1', dueAt: now, box: 2);

      // box 2 + good -> box 3, which this table says is 12 days.
      final after = const LeitnerScheduler(schedule: custom)
          .apply(card, ReviewOutcome.good, now);

      expect(after.box, 3);
      expect(after.intervalDays, 12);
    });

    test('changing the pace changes when a card returns', () {
      final card = StudyCard(wordId: 'w1', dueAt: now, box: 4);

      final gentle = LeitnerScheduler(
        schedule: ReviewSchedule.forPace(IntervalPace.gentle),
      ).apply(card, ReviewOutcome.good, now);
      final intensive = LeitnerScheduler(
        schedule: ReviewSchedule.forPace(IntervalPace.intensive),
      ).apply(card, ReviewOutcome.good, now);

      expect(gentle.intervalDays, greaterThan(intensive.intervalDays));
    });

    test('a lapse is ten minutes whatever the schedule says', () {
      // Box 0 is the relearning box; the ten minutes is the mechanism, not a
      // table entry the user can lengthen into uselessness.
      const custom = ReviewSchedule(<int>[0, 30, 60, 90, 120, 150, 365]);
      final after = const LeitnerScheduler(schedule: custom).apply(
        StudyCard(wordId: 'w1', dueAt: now, box: 5),
        ReviewOutcome.again,
        now,
      );

      expect(after.box, 0);
      expect(
        after.dueAt.difference(now).inMinutes,
        closeTo(LeitnerScheduler.relearnInterval.inMinutes, 2),
      );
    });
  });
}
