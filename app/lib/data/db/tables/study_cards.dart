import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/converters/converters.dart';
import 'package:vocabnote/data/db/tables/words.dart';

/// `study_cards` - one row per word, SRS-ready from day one.
///
/// [StudyCards.easeFactor] is unused by the v1 Leitner scheduler and exists so
/// `Sm2Scheduler` can be swapped in at phase 2 with **no migration** (ADR-005).
/// Do not read it into any v1 logic.
// The due-pool query orders on exactly this pair (docs/GAMES.md section 4).
@TableIndex(name: 'idx_cards_due', columns: {#dueAt, #suspended})
// The least-known sort orders on exactly this pair. Without it the query
// left-joins every study card and sorts unindexed - ~80ms on 5,000 words, the
// slowest query in the app by 15x (PROGRESS §3 decision 3).
@TableIndex(name: 'idx_cards_box_lapses', columns: {#box, #lapses})
@DataClassName('StudyCardRow')
class StudyCards extends Table {
  /// The word this card is for - also the primary key, so the one-card-per-word
  /// rule is structural rather than a convention someone can forget.
  TextColumn get wordId => text()
      .named('word_id')
      .references(Words, #id, onDelete: KeyAction.cascade)();

  /// Leitner box, 0-6 (`docs/GAMES.md` §5).
  IntColumn get box => integer().withDefault(const Constant(0))();

  /// When the card next comes up. Epoch milliseconds UTC.
  IntColumn get dueAt => integer().named('due_at').map(epochMillisConverter)();

  /// The interval that produced [dueAt], in days.
  IntColumn get intervalDays =>
      integer().named('interval_days').withDefault(const Constant(0))();

  /// SM-2 ease. Present, unused in v1.
  RealColumn get easeFactor =>
      real().named('ease_factor').withDefault(const Constant(2.5))();

  /// How many times the card has been reviewed.
  IntColumn get repetitions => integer().withDefault(const Constant(0))();

  /// How many times the user answered `again`.
  IntColumn get lapses => integer().withDefault(const Constant(0))();

  /// Epoch milliseconds UTC, or null if never reviewed.
  IntColumn get lastReviewedAt => integer()
      .named('last_reviewed_at')
      .map(nullableEpochMillisConverter)
      .nullable()();

  /// `again` | `good` | `easy`, or null if never reviewed.
  TextColumn get lastResult => text()
      .named('last_result')
      .map(nullableReviewOutcomeConverter)
      .nullable()();

  /// Suspended cards never appear in a due pool.
  BoolColumn get suspended => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {wordId};

  @override
  List<String> get customConstraints => <String>[
    'CHECK (box >= 0 AND box <= 6)',
  ];
}
