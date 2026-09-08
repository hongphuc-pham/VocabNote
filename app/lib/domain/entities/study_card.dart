import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vocabnote/domain/value_objects/storage_enum.dart';

part 'study_card.freezed.dart';

/// How a round was graded (`study_cards.last_result`,
/// `practice_answers.result`).
///
/// `skipped` exists in the game contract (`docs/GAMES.md` §2) but is not a
/// scheduling outcome: it is recorded as an answer and leaves the card alone.
enum ReviewOutcome implements StorageEnum {
  /// The user did not know it. Resets to box 0 and counts a lapse.
  again('again'),

  /// The user knew it. Advances one box.
  good('good'),

  /// The user knew it easily. Advances two boxes.
  easy('easy'),

  /// The round was skipped. Recorded, but never schedules.
  skipped('skipped');

  new(this.storageValue);

  /// The exact string written to the database.
  @override
  final String storageValue;

  /// Parses a stored value, or null if unrecognised.
  static ReviewOutcome? tryFromStorage(String value) {
    for (final outcome in ReviewOutcome.values) {
      if (outcome.storageValue == value) return outcome;
    }
    return null;
  }

  /// Whether this outcome moves the schedule at all.
  bool get affectsSchedule => this != ReviewOutcome.skipped;
}

/// The spaced-repetition state for one word - exactly one row per word.
///
/// SRS-ready from day one (`DATABASE.md` §2): [easeFactor] is unused by the
/// Leitner scheduler in v1 and exists so `Sm2Scheduler` can be swapped in at
/// phase 2 with **no migration** (ADR-005).
@freezed
abstract class StudyCard with _$StudyCard {
  /// Creates a study card.
  const factory({
    /// The word this card is for. Also the primary key.
    required String wordId,

    /// When the card next comes up for review.
    required DateTime dueAt,

    /// Leitner box, 0-6 (`docs/GAMES.md` §5).
    @Default(0) int box,

    /// The interval that produced [dueAt], in days. 0 means same-day.
    @Default(0) int intervalDays,

    /// SM-2 ease. Present but unused in v1; do not read it into any v1 logic.
    @Default(2.5) double easeFactor,

    /// How many times the card has been reviewed.
    @Default(0) int repetitions,

    /// How many times the user has answered `again` on it.
    @Default(0) int lapses,

    /// When it was last reviewed.
    DateTime? lastReviewedAt,

    /// How it was last graded.
    ReviewOutcome? lastResult,

    /// Suspended cards never appear in a due pool.
    @Default(false) bool suspended,
  }) = _StudyCard;

  /// A brand-new card: box 0, due immediately.
  ///
  /// Created the moment a word is saved (F-001), so a word is practisable
  /// straight away rather than only after some later sweep.
  factory newCard({required String wordId, required DateTime now}) =>
      StudyCard(wordId: wordId, dueAt: now);

  const new _();

  /// The highest Leitner box (`docs/GAMES.md` §5).
  static const int maxBox = 6;

  /// Whether this card is due at [now] and not suspended.
  bool isDue(DateTime now) => !suspended && !dueAt.isAfter(now);

  /// Whether the user has never reviewed this card.
  bool get isNew => repetitions == 0;
}
