import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/practice_answers.dart';
import 'package:vocabnote/data/db/tables/practice_sessions.dart';
import 'package:vocabnote/data/db/tables/study_cards.dart';
import 'package:vocabnote/data/db/tables/word_list_items.dart';
import 'package:vocabnote/data/db/tables/words.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';

part 'practice_dao.g.dart';

/// A word paired with its study state, as a practice pool needs it.
class WordWithCard {
  /// Creates a pool entry.
  const new({required this.word, required this.card});

  /// The word being practised.
  final WordRow word;

  /// Its study state. Never null: a card is created with the word (F-001).
  final StudyCardRow card;
}

/// Reads and writes `study_cards`, `practice_sessions` and `practice_answers`
/// (`docs/GAMES.md`).
@DriftAccessor(
  tables: <Type>[
    StudyCards,
    PracticeSessions,
    PracticeAnswers,
    Words,
    WordListItems,
  ],
)
class PracticeDao extends DatabaseAccessor<AppDatabase>
    with _$PracticeDaoMixin {
  /// Creates the DAO.
  new(super.attachedDatabase);

  // --- Study cards ---------------------------------------------------------

  /// Creates the study card that a new word gets: box 0, due now (F-001).
  Future<void> insertCard(StudyCardsCompanion card) =>
      into(studyCards).insert(card, mode: InsertMode.insertOrIgnore);

  /// Reads one card.
  Future<StudyCardRow?> getCard(String wordId) => (select(
    studyCards,
  )..where((c) => c.wordId.equals(wordId))).getSingleOrNull();

  /// Writes a card back after the scheduler has moved it.
  ///
  /// Only ever called when the session's `affects_scheduling` is true - a
  /// quick test records answers and leaves this table alone
  /// (`docs/GAMES.md` section 4).
  Future<int> updateCard(String wordId, StudyCardsCompanion patch) =>
      (update(studyCards)..where((c) => c.wordId.equals(wordId))).write(patch);

  /// How many cards are due now - the "Daily review (N due)" count.
  Stream<int> watchDueCount({DateTime? now}) {
    final at = now ?? DateTime.now();
    final count = studyCards.wordId.count();
    final query =
        selectOnly(studyCards).join(<Join<HasResultSet, dynamic>>[
            innerJoin(
              words,
              words.id.equalsExp(studyCards.wordId) &
                  words.deletedAt.isNull() &
                  words.isArchived.equals(false),
            ),
          ])
          ..addColumns(<Expression<Object>>[count])
          ..where(
            studyCards.suspended.equals(false) &
                studyCards.dueAt.isSmallerOrEqualValue(
                  at.toUtc().millisecondsSinceEpoch,
                ),
          );
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  /// The cards due now, soonest first, capped at [limit].
  ///
  /// Suspended cards and deleted or archived words never appear.
  Future<List<WordWithCard>> dueCards({
    required int limit,
    DateTime? now,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
  }) {
    final at = now ?? DateTime.now();
    final query = _poolQuery(source, sourceId)
      ..where(
        studyCards.suspended.equals(false) &
            studyCards.dueAt.isSmallerOrEqualValue(
              at.toUtc().millisecondsSinceEpoch,
            ),
      )
      ..orderBy(<OrderingTerm>[OrderingTerm.asc(studyCards.dueAt)])
      ..limit(limit);
    return _readPool(query);
  }

  /// A random pool, capped at [limit] - the quick test.
  ///
  /// The 30-card ceiling is enforced by the caller in `GameConfig` **and**
  /// again here by whatever [limit] it passes, so neither layer can be the
  /// only thing standing between a user and a 500-card session.
  Future<List<WordWithCard>> randomCards({
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
  }) {
    final query = _poolQuery(source, sourceId)
      ..orderBy(<OrderingTerm>[OrderingTerm.random()])
      ..limit(limit);
    return _readPool(query);
  }

  /// The weakest cards first: lowest box, then most lapses.
  Future<List<WordWithCard>> weakestCards({
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
  }) {
    final query = _poolQuery(source, sourceId)
      ..where(studyCards.suspended.equals(false))
      ..orderBy(<OrderingTerm>[
        OrderingTerm.asc(studyCards.box),
        OrderingTerm.desc(studyCards.lapses),
      ])
      ..limit(limit);
    return _readPool(query);
  }

  /// The most recently added words first.
  Future<List<WordWithCard>> newestCards({
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
  }) {
    final query = _poolQuery(source, sourceId)
      ..orderBy(<OrderingTerm>[OrderingTerm.desc(words.createdAt)])
      ..limit(limit);
    return _readPool(query);
  }

  JoinedSelectStatement<HasResultSet, dynamic> _poolQuery(
    CardSourceKind source,
    String? sourceId,
  ) {
    final query = select(studyCards).join(<Join<HasResultSet, dynamic>>[
      innerJoin(words, words.id.equalsExp(studyCards.wordId)),
    ])..where(words.deletedAt.isNull() & words.isArchived.equals(false));

    switch (source) {
      case CardSourceKind.all:
        break;
      case CardSourceKind.favourites:
        query.where(words.isFavourite.equals(true));
      case CardSourceKind.list:
        if (sourceId != null) {
          query.where(
            existsQuery(
              select(wordListItems)
                ..where((i) => i.wordId.equalsExp(words.id))
                ..where((i) => i.listId.equals(sourceId)),
            ),
          );
        }
    }
    return query;
  }

  Future<List<WordWithCard>> _readPool(
    JoinedSelectStatement<HasResultSet, dynamic> query,
  ) async {
    final rows = await query.get();
    return rows
        .map(
          (row) => WordWithCard(
            word: row.readTable(words),
            card: row.readTable(studyCards),
          ),
        )
        .toList();
  }

  // --- Sessions and answers ------------------------------------------------

  /// Opens a session row.
  Future<void> insertSession(PracticeSessionsCompanion session) =>
      into(practiceSessions).insert(session);

  /// Closes a session with its totals.
  Future<int> closeSession(String id, PracticeSessionsCompanion patch) =>
      (update(practiceSessions)..where((s) => s.id.equals(id))).write(patch);

  /// Reads one session.
  Future<PracticeSessionRow?> getSession(String id) => (select(
    practiceSessions,
  )..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Records one graded round.
  Future<void> insertAnswer(PracticeAnswersCompanion answer) =>
      into(practiceAnswers).insert(answer);

  /// The answers in a session, in the order they were given.
  Future<List<PracticeAnswerRow>> answersForSession(String sessionId) =>
      (select(practiceAnswers)
            ..where((a) => a.sessionId.equals(sessionId))
            ..orderBy(<OrderClauseGenerator<PracticeAnswers>>[
              (a) => OrderingTerm.asc(a.roundIndex),
            ]))
          .get();

  /// The most recent finished sessions - the streak and history on the hub.
  Stream<List<PracticeSessionRow>> watchRecentSessions({int limit = 30}) =>
      (select(practiceSessions)
            ..where((s) => s.endedAt.isNotNull())
            ..orderBy(<OrderClauseGenerator<PracticeSessions>>[
              (s) => OrderingTerm.desc(s.startedAt),
            ])
            ..limit(limit))
          .watch();
}
