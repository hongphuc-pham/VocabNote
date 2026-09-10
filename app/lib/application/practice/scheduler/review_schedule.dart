/// The user's chosen repetition schedule (F-061, extends `docs/GAMES.md` §5).
library;

import 'package:flutter/foundation.dart';

/// How quickly intervals grow, as a one-tap choice.
///
/// A preset is not a separate mechanism from an edited table — it *produces* a
/// table. That way there is one source of truth for "when does this come
/// back?", and picking a preset then nudging one box is an ordinary thing to
/// do rather than a mode switch.
enum IntervalPace {
  /// Longer gaps: for a light load, or a language you already read well.
  gentle(1.5),

  /// Exactly the `docs/GAMES.md` §5 table. The default, and unchanged.
  standard(1),

  /// Shorter gaps: more reviews, faster. For an exam in three weeks.
  intensive(0.6);

  new(this.factor);

  /// What [ReviewSchedule.standard]'s intervals are multiplied by.
  final double factor;
}

/// The interval for each Leitner box, in days.
///
/// `GAMES.md` §5 fixed this table. It is now the user's, because how often a
/// word comes back is the single thing about a study app that people most
/// reasonably disagree on — the spec's numbers are a good default, not a fact.
/// `standard` **is** the §5 table, so the default behaviour is unchanged.
@immutable
class ReviewSchedule {
  /// Creates a schedule from [intervalDays], one entry per box.
  const new(this.intervalDays);

  /// Rebuilds a schedule, falling back to [standard] if it is unusable.
  ///
  /// A stored schedule that cannot be parsed must not stop practice; the
  /// default is always a safe answer.
  factory fromJson(Object? json) {
    if (json is! List) return standard;
    final days = <int>[
      for (final value in json)
        if (value is num) value.toInt(),
    ];
    final schedule = ReviewSchedule(days);
    return schedule.isValid ? schedule : standard;
  }

  /// [standard] scaled by [pace], rounded, with every box still resurfacing.
  ///
  /// Box 0 stays 0 whatever the pace: it means "same day, in ten minutes", and
  /// scaling a lapse into tomorrow would defeat the point of a lapse.
  factory forPace(IntervalPace pace) {
    if (pace == IntervalPace.standard) return standard;
    return ReviewSchedule(<int>[
      0,
      for (final days in standard.intervalDays.skip(1))
        // At least 1: a rounded-down interval of 0 would put a mature card
        // back in the relearning box for ever.
        if ((days * pace.factor).round() < 1)
          1
        else
          (days * pace.factor).round(),
    ]);
  }

  /// The `docs/GAMES.md` §5 table, and the default.
  static const ReviewSchedule standard = ReviewSchedule(<int>[
    0,
    1,
    2,
    4,
    7,
    15,
    30,
  ]);

  /// How many boxes there are. Box 0 is the relearning box.
  static const int boxCount = 7;

  /// The interval per box, indexed by box. Box 0 is 0 — same day.
  final List<int> intervalDays;

  /// Why this schedule is unusable, or null when it is fine.
  ///
  /// Returned as a reason rather than a bool so Settings can say *what* is
  /// wrong. A user editing seven numbers by hand will get it wrong, and
  /// "invalid" is not a helpful thing to be told.
  String? get problem {
    if (intervalDays.length != boxCount) {
      return 'A schedule needs exactly $boxCount intervals, '
          'one per box (got ${intervalDays.length}).';
    }
    if (intervalDays.first != 0) {
      return 'Box 0 is the relearning box and must be 0 days.';
    }
    for (var box = 1; box < intervalDays.length; box++) {
      // The real hazard the user's own choice can create: a 0 here means a
      // word in that box is due immediately, for ever, and never progresses.
      if (intervalDays[box] < 1) {
        return 'Box $box must be at least 1 day, or its words never come back.';
      }
      if (intervalDays[box] < intervalDays[box - 1]) {
        return 'Box $box is shorter than box ${box - 1}. '
            'Later boxes must wait longer, not less.';
      }
    }
    return null;
  }

  /// Whether this schedule can be used.
  bool get isValid => problem == null;

  /// The interval for [box], clamped into range.
  ///
  /// Clamped rather than throwing: a stored box outside the table means data
  /// from another version, and refusing to schedule the card at all would be
  /// worse than scheduling it at the nearest interval.
  int daysForBox(int box) =>
      intervalDays[box.clamp(0, intervalDays.length - 1)];

  /// This schedule as it is stored.
  List<int> toJson() => intervalDays;

  @override
  bool operator ==(Object other) =>
      other is ReviewSchedule && listEquals(other.intervalDays, intervalDays);

  @override
  int get hashCode => Object.hashAll(intervalDays);

  @override
  String toString() => 'ReviewSchedule($intervalDays)';
}
