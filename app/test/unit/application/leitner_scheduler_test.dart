import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/practice/scheduler/leitner_scheduler.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/domain/entities/study_card.dart';

/// `LeitnerScheduler` against the table in `docs/GAMES.md` §5.
///
/// The table is the spec, so it is transcribed here rather than paraphrased:
/// if the two disagree, one of them is a bug and this file says which.
void main() {
  final now = DateTime.utc(2026, 9, 10, 12);

  /// A scheduler with the jitter pinned, so intervals are exact.
  ///
  /// `nextDouble() == 0.5` maps to a factor of zero — the midpoint of ±10% —
  /// which is the only value that lets an interval be asserted to the second.
  LeitnerScheduler exact() => LeitnerScheduler(random: _FixedRandom(0.5));

  StudyCard cardIn(int box, {int lapses = 0, int repetitions = 0}) => StudyCard(
    wordId: 'w1',
    dueAt: now.subtract(const Duration(days: 1)),
    box: box,
    lapses: lapses,
    repetitions: repetitions,
  );

  group('the interval table (GAMES.md §5)', () {
    // Box -> days, exactly as the doc tables it.
    const expected = <int, int>{0: 0, 1: 1, 2: 2, 3: 4, 4: 7, 5: 15, 6: 30};

    test('every box has the documented interval', () {
      expect(ReviewSchedule.standard.intervalDays.length, expected.length);
      for (final entry in expected.entries) {
        expect(
          ReviewSchedule.standard.daysForBox(entry.key),
          entry.value,
          reason: 'box ${entry.key}',
        );
      }
    });

    test("good from each box lands on the next box's interval", () {
      for (var box = 0; box < LeitnerScheduler.maxBox; box++) {
        final after = exact().apply(cardIn(box), ReviewOutcome.good, now);
        expect(after.box, box + 1, reason: 'from box $box');
        expect(
          after.intervalDays,
          expected[box + 1],
          reason: 'interval from box $box',
        );
        expect(after.dueAt, now.add(Duration(days: expected[box + 1]!)));
      }
    });
  });

  group('grading', () {
    test('good advances one box', () {
      expect(exact().apply(cardIn(2), ReviewOutcome.good, now).box, 3);
    });

    test('easy advances two boxes', () {
      expect(exact().apply(cardIn(2), ReviewOutcome.easy, now).box, 4);
    });

    test('neither good nor easy can pass the last box', () {
      expect(exact().apply(cardIn(6), ReviewOutcome.good, now).box, 6);
      expect(exact().apply(cardIn(5), ReviewOutcome.easy, now).box, 6);
      expect(exact().apply(cardIn(6), ReviewOutcome.easy, now).box, 6);
    });

    test('again drops all the way to box 0, not one step back', () {
      // The point of box 0: a word just failed is not a word to see in a week.
      final after = exact().apply(cardIn(5), ReviewOutcome.again, now);
      expect(after.box, 0);
      expect(after.intervalDays, 0);
    });

    test('again comes back in ten minutes', () {
      final after = exact().apply(cardIn(3), ReviewOutcome.again, now);
      expect(after.dueAt, now.add(LeitnerScheduler.relearnInterval));
    });

    test('only again counts a lapse', () {
      expect(
        exact().apply(cardIn(2, lapses: 4), ReviewOutcome.again, now).lapses,
        5,
      );
      expect(
        exact().apply(cardIn(2, lapses: 4), ReviewOutcome.good, now).lapses,
        4,
      );
      expect(
        exact().apply(cardIn(2, lapses: 4), ReviewOutcome.easy, now).lapses,
        4,
      );
    });

    test('every grade records the review', () {
      for (final result in <ReviewOutcome>[
        ReviewOutcome.again,
        ReviewOutcome.good,
        ReviewOutcome.easy,
      ]) {
        final after = exact().apply(cardIn(1, repetitions: 7), result, now);
        expect(after.repetitions, 8, reason: result.name);
        expect(after.lastResult, result, reason: result.name);
        expect(after.lastReviewedAt, now, reason: result.name);
      }
    });
  });

  group('skipped', () {
    test('is recorded but changes nothing about the schedule', () {
      // A card the user scrolled past has not been reviewed. Treating a skip
      // as a review would quietly inflate the schedule and push real work into
      // the future.
      final before = cardIn(3, lapses: 2, repetitions: 9);
      final after = exact().apply(before, ReviewOutcome.skipped, now);

      expect(after.box, before.box);
      expect(after.dueAt, before.dueAt);
      expect(after.intervalDays, before.intervalDays);
      expect(after.lapses, before.lapses);
      expect(after.repetitions, before.repetitions);

      expect(after.lastResult, ReviewOutcome.skipped);
      expect(after.lastReviewedAt, now);
    });
  });

  group('jitter', () {
    test('stays within ±10% of the interval', () {
      // Both extremes, since a bug here shows up as a deck that clumps rather
      // than as anything that fails loudly.
      for (final draw in <double>[0, 1]) {
        final after = LeitnerScheduler(random: _FixedRandom(draw))
            .apply(cardIn(3), ReviewOutcome.good, now);

        // box 3 + good lands in box 4, whose interval is 7 days.
        const base = Duration(days: 7);
        final delta = after.dueAt.difference(now) - base;
        expect(delta.inSeconds.abs(), lessThanOrEqualTo(base.inSeconds ~/ 10));
      }
    });

    test('actually spreads cards rather than returning one value', () {
      // The whole purpose: two cards graded in the same second must not come
      // back in the same second.
      final scheduler = LeitnerScheduler(random: Random(7));
      final dues = <DateTime>{
        for (var i = 0; i < 20; i++)
          scheduler.apply(cardIn(4), ReviewOutcome.good, now).dueAt,
      };
      expect(dues.length, greaterThan(1));
    });

    test('does not jitter a lapse into the past', () {
      for (final draw in <double>[0, 0.5, 1]) {
        final after = LeitnerScheduler(random: _FixedRandom(draw))
            .apply(cardIn(2), ReviewOutcome.again, now);
        expect(after.dueAt.isAfter(now), isTrue, reason: 'draw $draw');
      }
    });
  });
}

/// A `Random` that always returns the same draw, so jitter is exact.
class _FixedRandom implements Random {
  new(this.value);

  final double value;

  @override
  double nextDouble() => value;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  int nextInt(int max) => throw UnimplementedError();
}
