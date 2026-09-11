import 'dart:math';

import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/domain/entities/study_card.dart';

/// Decides when a card comes back (`docs/GAMES.md` §1).
///
/// An interface rather than a function so `Sm2Scheduler` can replace it in
/// phase 2 as a single provider override. `StudyCard.easeFactor` already
/// exists in the schema for exactly that, so the swap needs no migration
/// (ADR-005).
abstract interface class ReviewScheduler {
  /// Returns [current] advanced by [result], as of [now].
  ///
  /// Pure: no I/O, no clock of its own. The runner owns persistence.
  StudyCard apply(StudyCard current, ReviewOutcome result, DateTime now);
}

/// The v1 scheduler: plain Leitner boxes (`docs/GAMES.md` §5).
///
/// The interval table is [schedule] rather than a constant, so the user can
/// choose their own pace (F-061). It defaults to [ReviewSchedule.standard],
/// which **is** the §5 table — so a user who never opens Settings gets exactly
/// the documented behaviour.
class LeitnerScheduler implements ReviewScheduler {
  /// Creates a scheduler.
  const new({this.schedule = ReviewSchedule.standard, this.random});

  /// How long each box waits. The user's choice, or the documented default.
  final ReviewSchedule schedule;

  /// The source of the ±10% jitter.
  ///
  /// Injectable only so a test can pin the draw and assert an interval to the
  /// second; production leaves it null and gets a fresh [Random] per call.
  final Random? random;

  /// The highest box. Reaching it means a 30-day interval and no further gain.
  static const int maxBox = 6;

  /// A lapse, and a brand-new card, come back almost immediately.
  static const Duration relearnInterval = Duration(minutes: 10);

  @override
  StudyCard apply(StudyCard current, ReviewOutcome result, DateTime now) {
    // A skip is recorded but never schedules (`GAMES.md` §5, and the doc
    // comment on ReviewOutcome.skipped). Box, due date, lapses and repetitions
    // are all left exactly as they were: a card the user scrolled past has not
    // been reviewed, and treating it as one would quietly inflate the schedule.
    if (result == ReviewOutcome.skipped) {
      return current.copyWith(
        lastResult: ReviewOutcome.skipped,
        lastReviewedAt: now,
      );
    }

    final box = boxAfter(current.box, result);
    final days = schedule.daysForBox(box);

    return current.copyWith(
      box: box,
      intervalDays: days,
      dueAt: now.add(_jittered(days)),
      repetitions: current.repetitions + 1,
      lapses: result == ReviewOutcome.again
          ? current.lapses + 1
          : current.lapses,
      lastResult: result,
      lastReviewedAt: now,
    );
  }

  /// Which box [box] becomes after [result].
  ///
  /// Public so the runner can label a grading button with where the card would
  /// land, without applying the scheduler and reading a jittered date back out
  /// of it (`UI-UX.md` §4.7).
  int boxAfter(int box, ReviewOutcome result) => switch (result) {
    // A lapse goes all the way back, not one step. The point of box 0 is that
    // a word you have just failed is not a word you should see in four days.
    ReviewOutcome.again => 0,
    ReviewOutcome.good => min(box + 1, maxBox),
    ReviewOutcome.easy => min(box + 2, maxBox),
    ReviewOutcome.skipped => box,
  };

  /// The interval for [days], spread by ±10%.
  ///
  /// Without jitter every card added on the same evening comes back on the
  /// same evening, for ever, and the deck clumps into unusable spikes
  /// (`GAMES.md` §5).
  Duration _jittered(int days) {
    final base = days == 0 ? relearnInterval : Duration(days: days);
    final source = random ?? Random();
    // -0.1 .. +0.1
    final factor = (source.nextDouble() * 0.2) - 0.1;
    final offset = (base.inSeconds * factor).round();
    return Duration(seconds: base.inSeconds + offset);
  }
}
