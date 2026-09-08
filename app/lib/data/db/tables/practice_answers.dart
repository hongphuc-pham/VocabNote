import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/converters/converters.dart';
import 'package:vocabnote/data/db/tables/practice_sessions.dart';
import 'package:vocabnote/data/db/tables/words.dart';

/// `practice_answers` - one row per graded round.
///
/// Recorded for every mode, including quick test: a casual test still counts
/// for stats even though it must never touch `study_cards`
/// (`docs/GAMES.md` section 4).
@DataClassName('PracticeAnswerRow')
class PracticeAnswers extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  /// Owning session. Cascades.
  TextColumn get sessionId => text()
      .named('session_id')
      .references(PracticeSessions, #id, onDelete: KeyAction.cascade)();

  /// The word that was asked. Cascades.
  TextColumn get wordId => text()
      .named('word_id')
      .references(Words, #id, onDelete: KeyAction.cascade)();

  /// Zero-based position within the session.
  IntColumn get roundIndex => integer().named('round_index')();

  /// `again`, `good`, `easy` or `skipped`.
  TextColumn get result => text().map(reviewOutcomeConverter)();

  /// How long the user took, in milliseconds.
  IntColumn get responseMs => integer().named('response_ms').nullable()();

  /// Epoch milliseconds UTC.
  IntColumn get answeredAt =>
      integer().named('answered_at').map(epochMillisConverter)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
