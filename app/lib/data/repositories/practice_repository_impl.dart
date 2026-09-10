import 'dart:math';

import 'package:drift/drift.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/daos/practice_dao.dart';
import 'package:vocabnote/data/repositories/mappers.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';

/// Drift-backed [PracticeRepository].
class PracticeRepositoryImpl implements PracticeRepository {
  /// Creates the repository over the given database.
  new(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  AppFailure _dbFailure(String operation) =>
      DatabaseFailure(operation: operation);

  @override
  AsyncResult<List<PracticeCardData>> loadPool({
    required CardSelection selection,
    required PracticeMode mode,
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
    int? seed,
  }) => Results.guard(() async {
    // The 30-card ceiling, enforced again at the query. GameConfig also
    // clamps it; neither layer is the only thing between a user and a
    // 500-card session (docs/GAMES.md §4).
    final effectiveLimit = mode == PracticeMode.quickTest
        ? min(limit, PracticeRepository.quickTestMaxCards)
        : limit;

    final pool = switch (selection) {
      CardSelection.due => await _db.practiceDao.dueCards(
        limit: effectiveLimit,
        now: _now(),
        source: source,
        sourceId: sourceId,
      ),
      CardSelection.random => await _db.practiceDao.randomCards(
        limit: effectiveLimit,
        source: source,
        sourceId: sourceId,
      ),
      CardSelection.weakest => await _db.practiceDao.weakestCards(
        limit: effectiveLimit,
        source: source,
        sourceId: sourceId,
      ),
      CardSelection.newest => await _db.practiceDao.newestCards(
        limit: effectiveLimit,
        source: source,
        sourceId: sourceId,
      ),
    };

    return await _attachHighlights(pool, seed: seed);
  }, onError: (_, _) => _dbFailure('load practice pool'));

  /// Loads the highlights and first notes for a whole pool and attaches them.
  ///
  /// A running game must never touch the database, so everything a round can
  /// need is resolved before the session starts (`docs/GAMES.md` §2).
  ///
  /// When [seed] is given the pool is shuffled deterministically, so a session
  /// can be replayed exactly - which is why the seed is stored on the session
  /// row.
  Future<List<PracticeCardData>> _attachHighlights(
    List<WordWithCard> pool, {
    int? seed,
  }) async {
    if (pool.isEmpty) return <PracticeCardData>[];

    final ids = pool.map((entry) => entry.word.id).toSet();
    final grouped = await _db.highlightsDao.watchGroupedByWord().first;
    final firstNotes = await _db.notesDao.firstBodyByWord(ids);

    final cards = <PracticeCardData>[
      for (final entry in pool)
        if (ids.contains(entry.word.id))
          PracticeCardData(
            word: entry.word.toEntity(),
            card: entry.card.toEntity(),
            highlights: (grouped[entry.word.id] ?? const <IpaHighlightRow>[])
                .map((row) => row.toEntityOrNull())
                .whereType<IpaHighlight>()
                .toList(),
            firstNote: firstNotes[entry.word.id],
          ),
    ];

    if (seed != null) cards.shuffle(Random(seed));
    return cards;
  }

  @override
  ResultStream<int> watchDueCount() => _db.practiceDao.watchDueCount().guarded(
    onError: (_, _) => _dbFailure('count due cards'),
  );

  @override
  AsyncResult<void> createCardForWord(String wordId) => Results.guard(
    () => _db.practiceDao.insertCard(
      StudyCard.newCard(wordId: wordId, now: _now()).toCompanion(),
    ),
    onError: (_, _) => _dbFailure('create study card'),
  );

  @override
  AsyncResult<PracticeSession> startSession(PracticeSession session) =>
      Results.guard(() async {
        await _db.practiceDao.insertSession(session.toCompanion());
        return session;
      }, onError: (_, _) => _dbFailure('start practice session'));

  @override
  AsyncResult<void> recordAnswer({
    required PracticeAnswer answer,
    required bool affectsScheduling,
    StudyCard? updatedCard,
  }) => Results.guard(
    () => _db.transaction(() async {
      await _db.practiceDao.insertAnswer(answer.toCompanion());

      // The single most important line in the practice layer: a quick test
      // records answers and leaves study_cards alone. Asserted by
      // practice_repository_test.dart.
      if (affectsScheduling && updatedCard != null) {
        await _db.practiceDao.updateCard(
          updatedCard.wordId,
          updatedCard.toCompanion(),
        );
      }
    }),
    onError: (_, _) => _dbFailure('record answer'),
  );

  @override
  AsyncResult<PracticeSession> endSession({
    required String sessionId,
    required DateTime endedAt,
    required int totalRounds,
    required int correctRounds,
  }) => Results.guard(() async {
    await _db.practiceDao.closeSession(
      sessionId,
      PracticeSessionsCompanion(
        endedAt: Value(endedAt),
        totalRounds: Value(totalRounds),
        correctRounds: Value(correctRounds),
      ),
    );
    final row = await _db.practiceDao.getSession(sessionId);
    if (row == null) {
      throw StateError('session $sessionId vanished while closing');
    }
    return row.toEntity();
  }, onError: (_, _) => _dbFailure('end practice session'));

  @override
  AsyncResult<PracticeSession?> getSession(String id) => Results.guard(
    () async => (await _db.practiceDao.getSession(id))?.toEntity(),
    onError: (_, _) => _dbFailure('read practice session'),
  );

  @override
  AsyncResult<List<PracticeAnswer>> answersForSession(String sessionId) =>
      Results.guard(
        () async =>
            (await _db.practiceDao.answersForSession(sessionId))
                .map((row) => row.toEntity())
                .toList(),
        onError: (_, _) => _dbFailure('read session answers'),
      );

  @override
  ResultStream<List<PracticeSession>> watchRecentSessions({int limit = 30}) =>
      _db.practiceDao
          .watchRecentSessions(limit: limit)
          .map((rows) => rows.map((row) => row.toEntity()).toList())
          .guarded(onError: (_, _) => _dbFailure('watch recent sessions'));
}
