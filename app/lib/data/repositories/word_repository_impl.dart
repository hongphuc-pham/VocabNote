import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/core/utils/combine_latest.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/mappers.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_note.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';

/// Drift-backed [WordRepository].
class WordRepositoryImpl implements WordRepository {
  /// Creates the repository over the given database.
  ///
  /// [_uuid] and [now] are injectable so tests can produce stable ids and
  /// timestamps instead of asserting on whatever the clock happened to say.
  new(this._db, {this._uuid = const Uuid(), DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  AppFailure _dbFailure(String operation) =>
      DatabaseFailure(operation: operation);

  @override
  ResultStream<List<WordListEntry>> watchWords(WordQuery query) {
    // Three streams combined rather than a join, because note counts and
    // highlights change independently of the words themselves and each has its
    // own natural update signal.
    return combineLatest3(
      _db.wordsDao.watchWords(query),
      _db.notesDao.watchCountsByWord(),
      _db.highlightsDao.watchGroupedByWord(),
      (rows, counts, highlights) => <WordListEntry>[
        for (final row in rows)
          WordListEntry(
            word: row.toEntity(),
            noteCount: counts[row.id] ?? 0,
            highlights: (highlights[row.id] ?? const <IpaHighlightRow>[])
                .map((h) => h.toEntityOrNull())
                .whereType<IpaHighlight>()
                .toList(),
          ),
      ],
    ).guarded(onError: (_, _) => _dbFailure('watch words'));
  }

  @override
  ResultStream<Word?> watchWord(String id) => _db.wordsDao
      .watchById(id)
      .map((row) => row?.toEntity())
      .guarded(onError: (_, _) => _dbFailure('watch word'));

  @override
  AsyncResult<Word?> getWord(String id) => Results.guard(
    () async => (await _db.wordsDao.getById(id))?.toEntity(),
    onError: (_, _) => _dbFailure('read word'),
  );

  @override
  AsyncResult<Word?> findDuplicate(String headword) => Results.guard(() async {
    // Normalise exactly the way the column was written, so the lookup
    // cannot disagree with what is stored.
    final parsed = Headword.tryParse(headword);
    if (parsed == null) return null;
    final row = await _db.wordsDao.findByNormalized(parsed.normalized);
    return row?.toEntity();
  }, onError: (_, _) => _dbFailure('find duplicate'));

  @override
  AsyncResult<Word> createWord({
    required Word word,
    List<String> listIds = const <String>[],
    String? firstNote,
  }) => Results.guard(() async {
    final now = _now();
    final created = word.copyWith(createdAt: now, updatedAt: now);

    // One transaction: a word without its study card would be invisible
    // to practice, and a half-written note is worse than none.
    await _db.transaction(() async {
      await _db.wordsDao.insertWord(created.toCompanion());
      await _db.practiceDao.insertCard(
        StudyCard.newCard(wordId: created.id, now: now).toCompanion(),
      );

      final note = firstNote?.trim();
      if (note != null && note.isNotEmpty) {
        await _db.notesDao.insertNote(
          WordNote(
            id: _uuid.v4(),
            wordId: created.id,
            body: note,
            createdAt: now,
            updatedAt: now,
          ).toCompanion(),
        );
      }

      if (listIds.isNotEmpty) {
        await _db.listsDao.setListsForWord(
          wordId: created.id,
          listIds: listIds,
          addedAt: now,
        );
      }
    });
    return created;
  }, onError: (_, _) => _dbFailure('create word'));

  @override
  AsyncResult<Word> updateWord(Word word) => Results.guard(() async {
    final updated = word.copyWith(updatedAt: _now());
    await _db.wordsDao.patchWord(updated.id, updated.toCompanion());
    return updated;
  }, onError: (_, _) => _dbFailure('update word'));

  @override
  AsyncResult<void> setFavourite(String id, {required bool isFavourite}) =>
      Results.guard(
        () => _db.wordsDao.patchWord(
          id,
          WordsCompanion(
            isFavourite: Value(isFavourite),
            updatedAt: Value(_now()),
          ),
        ),
        onError: (_, _) => _dbFailure('set favourite'),
      );

  @override
  AsyncResult<void> softDelete(String id) => Results.guard(
    () => _db.wordsDao.softDelete(id, _now()),
    onError: (_, _) => _dbFailure('delete word'),
  );

  @override
  AsyncResult<void> restore(String id) => Results.guard(
    () => _db.wordsDao.restore(id),
    onError: (_, _) => _dbFailure('restore word'),
  );

  @override
  AsyncResult<int> purgeExpired({
    Duration retention = const Duration(days: 30),
  }) => Results.guard(
    () => _db.wordsDao.purgeDeletedBefore(_now().subtract(retention)),
    onError: (_, _) => _dbFailure('purge deleted words'),
  );

  @override
  ResultStream<int> watchWordCount() => _db.wordsDao.watchCount().guarded(
    onError: (_, _) => _dbFailure('count words'),
  );

  @override
  ResultStream<List<WordNote>> watchNotes(String wordId) => _db.notesDao
      .watchForWord(wordId)
      .map((rows) => rows.map((row) => row.toEntity()).toList())
      .guarded(onError: (_, _) => _dbFailure('watch notes'));

  @override
  AsyncResult<WordNote> addNote({
    required String wordId,
    required String body,
  }) => Results.guard(() async {
    final now = _now();
    final note = WordNote(
      id: _uuid.v4(),
      wordId: wordId,
      body: body.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _db.notesDao.insertNote(note.toCompanion());
    return note;
  }, onError: (_, _) => _dbFailure('add note'));

  @override
  AsyncResult<void> updateNote(WordNote note) => Results.guard(
    () => _db.notesDao.patchNote(
      note.id,
      note.copyWith(updatedAt: _now()).toCompanion(),
    ),
    onError: (_, _) => _dbFailure('update note'),
  );

  @override
  AsyncResult<void> deleteNote(String id) => Results.guard(
    () => _db.notesDao.deleteNote(id),
    onError: (_, _) => _dbFailure('delete note'),
  );

  @override
  ResultStream<List<IpaHighlight>> watchHighlights(String wordId) => _db
      .highlightsDao
      .watchForWord(wordId)
      // Rows whose stored range is nonsense are dropped rather than thrown on
      // (F-023 validates on read): one bad row must not break the screen.
      .map(
        (rows) => rows
            .map((row) => row.toEntityOrNull())
            .whereType<IpaHighlight>()
            .toList(),
      )
      .guarded(onError: (_, _) => _dbFailure('watch highlights'));

  @override
  AsyncResult<void> replaceHighlights({
    required String wordId,
    required HighlightTarget target,
    required List<IpaHighlight> highlights,
  }) => Results.guard(
    () => _db.highlightsDao.replaceForTarget(
      wordId,
      target,
      highlights.map((highlight) => highlight.toCompanion()).toList(),
    ),
    onError: (_, _) => _dbFailure('save highlights'),
  );
}
