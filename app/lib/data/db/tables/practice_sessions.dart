import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/converters/converters.dart';

/// `practice_sessions` - one row per run of one game.
///
/// [PracticeSessions.affectsScheduling] is **stored**, not recomputed from
/// [PracticeSessions.mode]. If the rule ever changes, history must still say
/// what actually happened to the user's schedule.
@DataClassName('PracticeSessionRow')
class PracticeSessions extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  /// Which game ran, e.g. `flashcard`. Stable across releases, so a session
  /// recorded by an older build stays attributable.
  TextColumn get gameId => text().named('game_id')();

  /// `daily` or `quick_test`.
  TextColumn get mode => text().map(practiceModeConverter)();

  /// `all`, `list` or `favourites`.
  TextColumn get sourceKind =>
      text().named('source_kind').map(cardSourceKindConverter)();

  /// The list id when [sourceKind] is `list`.
  ///
  /// Deliberately **not** a foreign key: deleting a list must not erase the
  /// history of having practised it. A dangling id here is expected, and is
  /// handled when the summary is rendered.
  TextColumn get sourceId => text().named('source_id').nullable()();

  /// The full `GameConfig` as JSON. Readers tolerate unknown keys, so a
  /// session written by a newer build stays readable (`docs/GAMES.md` section
  /// 2).
  TextColumn get configJson => text().named('config_json')();

  /// Epoch milliseconds UTC.
  IntColumn get startedAt =>
      integer().named('started_at').map(epochMillisConverter)();

  /// Null while the session is running, or if the user abandoned it.
  IntColumn get endedAt => integer()
      .named('ended_at')
      .map(nullableEpochMillisConverter)
      .nullable()();

  /// How many rounds were played.
  IntColumn get totalRounds =>
      integer().named('total_rounds').withDefault(const Constant(0))();

  /// How many were answered `good` or `easy`.
  IntColumn get correctRounds =>
      integer().named('correct_rounds').withDefault(const Constant(0))();

  /// Whether this session applied the review schedule.
  BoolColumn get affectsScheduling => boolean().named('affects_scheduling')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
