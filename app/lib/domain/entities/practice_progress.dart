import 'package:meta/meta.dart';

/// Where today's practice stands, and the run of days behind it (F-065).
///
/// Built for encouragement, not pressure (`docs/RULES.md` §6): a day counts as
/// missed only once it is over, and nothing here has a notion of a streak being
/// *lost* — only of one being built.
@immutable
class PracticeProgress {
  /// Creates a progress snapshot.
  const new({
    required this.today,
    required this.wordsToday,
    required this.daysPractised,
  });

  /// How many days back practice is looked for. A longer streak reads as this
  /// long: more than a year of daily practice is not a number anyone needs to
  /// the day.
  static const int lookBackDays = 400;

  /// The local date this snapshot was taken on, at midnight.
  final DateTime today;

  /// How many different words were practised today, in any mode — a quick
  /// test is practice too. A word asked twice today is one word.
  final int wordsToday;

  /// Every local date, at midnight, with at least one answer.
  final Set<DateTime> daysPractised;

  /// Days practised in a row.
  ///
  /// Counted back from today when today has practice, and from yesterday when
  /// it does not yet. A day is not missed until it is over, so the streak never
  /// drops in the morning just because the app has not been opened.
  int get streak {
    var day = daysPractised.contains(today) ? today : _dayBefore(today);
    var count = 0;
    while (daysPractised.contains(day)) {
      count++;
      day = _dayBefore(day);
    }
    return count;
  }

  /// Whether today's words have reached [goal].
  bool goalReached(int goal) => goal > 0 && wordsToday >= goal;

  /// Today's share of [goal], from 0 to 1 — the ring never overfills.
  double fractionOf(int goal) =>
      goal <= 0 ? 0 : (wordsToday / goal).clamp(0, 1).toDouble();

  // By calendar fields, not by subtracting 24 hours: a day with a daylight
  // saving change is 23 or 25 hours long.
  static DateTime _dayBefore(DateTime day) =>
      DateTime(day.year, day.month, day.day - 1);
}
