import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/fts_query.dart';
import 'package:vocabnote/data/db/tables/study_cards.dart';
import 'package:vocabnote/data/db/tables/word_list_items.dart';
import 'package:vocabnote/data/db/tables/word_notes.dart';
import 'package:vocabnote/data/db/tables/words.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';

part 'words_dao.g.dart';

/// Reads and writes `words` (`docs/DATABASE.md` section 2).
///
/// Returns Drift row classes; mapping to domain entities is the repository's
/// job (`docs/RULES.md` section 25).
@DriftAccessor(tables: <Type>[Words, WordNotes, WordListItems, StudyCards])
class WordsDao extends DatabaseAccessor<AppDatabase> with _$WordsDaoMixin {
  /// Creates the DAO.
  new(super.attachedDatabase);

  /// Watches the word list for [query].
  ///
  /// Soft-deleted and archived rows are excluded everywhere: a deleted word is
  /// invisible until Undo restores it or the 30-day purge removes it.
  Stream<List<WordRow>> watchWords(WordQuery query) {
    if (query.isSearching) return _searchQuery(query).watch();
    if (query.sort == WordSort.leastKnown) {
      return _leastKnownQuery(query).watch();
    }
    return _plainQuery(query).watch();
  }

  /// One-shot version of [watchWords].
  Future<List<WordRow>> getWords(WordQuery query) {
    if (query.isSearching) return _searchQuery(query).get();
    if (query.sort == WordSort.leastKnown) {
      return _leastKnownQuery(query).get();
    }
    return _plainQuery(query).get();
  }

  /// The filter predicate, shared by every query path so a chip means the same
  /// thing whether or not the user is also searching or sorting.
  Expression<bool> _filter(Words w, WordQuery query) {
    var predicate = w.deletedAt.isNull() & w.isArchived.equals(false);
    // Converted columns compare against their SQL type, not their Dart one:
    // due_at holds epoch milliseconds.
    final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch;

    switch (query.filter) {
      case WordFilter.all:
        break;
      case WordFilter.favourites:
        predicate = predicate & w.isFavourite.equals(true);
      case WordFilter.dueToday:
        predicate =
            predicate &
            existsQuery(
              select(studyCards)
                ..where((c) => c.wordId.equalsExp(w.id))
                ..where((c) => c.suspended.equals(false))
                ..where((c) => c.dueAt.isSmallerOrEqualValue(nowMillis)),
            );
      case WordFilter.noIpa:
        predicate =
            predicate &
            (w.ipaUk.isNull() | w.ipaUk.equals('')) &
            (w.ipaUs.isNull() | w.ipaUs.equals(''));
      case WordFilter.inList:
        final listId = query.listId;
        if (listId != null) {
          predicate =
              predicate &
              existsQuery(
                select(wordListItems)
                  ..where((i) => i.wordId.equalsExp(w.id))
                  ..where((i) => i.listId.equals(listId)),
              );
        }
    }
    return predicate;
  }

  MultiSelectable<WordRow> _plainQuery(WordQuery query) {
    final statement = select(words)..where((w) => _filter(w, query));

    switch (query.sort) {
      case WordSort.recent:
        statement.orderBy(<OrderClauseGenerator<Words>>[
          (w) => OrderingTerm.desc(w.updatedAt),
        ]);
      case WordSort.alphabetical:
        statement.orderBy(<OrderClauseGenerator<Words>>[
          (w) => OrderingTerm.asc(w.headwordNormalized),
        ]);
      case WordSort.leastKnown:
        // Handled by _leastKnownQuery; unreachable here.
        break;
    }

    if (query.limit != null) statement.limit(query.limit!);
    return statement;
  }

  /// Weakest first, which needs the study card joined in.
  ///
  /// A left join, not an inner one: a word with no card yet must still appear,
  /// and must sort first. SQLite orders NULL before non-NULL ascending, which
  /// is exactly that behaviour.
  MultiSelectable<WordRow> _leastKnownQuery(WordQuery query) {
    final statement =
        select(words).join(<Join<HasResultSet, dynamic>>[
            leftOuterJoin(studyCards, studyCards.wordId.equalsExp(words.id)),
          ])
          ..where(_filter(words, query))
          ..orderBy(<OrderingTerm>[
            OrderingTerm.asc(studyCards.box),
            OrderingTerm.desc(studyCards.lapses),
            OrderingTerm.asc(words.headwordNormalized),
          ]);

    if (query.limit != null) statement.limit(query.limit!);
    return statement.map((row) => row.readTable(words));
  }

  /// Full-text search over headword, definition, example and note bodies
  /// (F-041).
  ///
  /// Ordered by FTS5 `rank` - relevance, not recency. [WordQuery.sort] is
  /// deliberately ignored while searching.
  MultiSelectable<WordRow> _searchQuery(WordQuery query) {
    final match = buildFtsMatchQuery(query.searchTerm!);
    if (match == null) return _plainQuery(query.copyWith(clearSearch: true));

    final buffer = StringBuffer(
      'SELECT w.* FROM words_fts f '
      'JOIN words w ON w.id = f.word_id '
      'WHERE words_fts MATCH ? '
      'AND w.deleted_at IS NULL AND w.is_archived = 0',
    );
    final variables = <Variable<Object>>[Variable<String>(match)];

    switch (query.filter) {
      case WordFilter.all:
      case WordFilter.dueToday:
        break;
      case WordFilter.favourites:
        buffer.write(' AND w.is_favourite = 1');
      case WordFilter.noIpa:
        buffer.write(
          " AND (w.ipa_uk IS NULL OR w.ipa_uk = '')"
          " AND (w.ipa_us IS NULL OR w.ipa_us = '')",
        );
      case WordFilter.inList:
        if (query.listId != null) {
          buffer.write(
            ' AND EXISTS (SELECT 1 FROM word_list_items i '
            'WHERE i.word_id = w.id AND i.list_id = ?)',
          );
          variables.add(Variable<String>(query.listId));
        }
    }

    buffer.write(' ORDER BY rank');
    if (query.limit != null) buffer.write(' LIMIT ${query.limit}');

    return customSelect(
      buffer.toString(),
      variables: variables,
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
        words,
        wordNotes,
      },
    ).map((row) => words.map(row.data));
  }

  /// Watches one word.
  Stream<WordRow?> watchById(String id) =>
      (select(words)..where((w) => w.id.equals(id))).watchSingleOrNull();

  /// Reads one word, including a soft-deleted one - Undo has to find it.
  Future<WordRow?> getById(String id) =>
      (select(words)..where((w) => w.id.equals(id))).getSingleOrNull();

  /// Finds a live word with this normalised headword, for the duplicate
  /// warning (F-001).
  ///
  /// Non-blocking by design: the caller shows "You already have X - open it?"
  /// and still lets the user save.
  Future<WordRow?> findByNormalized(String normalized) =>
      (select(words)
            ..where((w) => w.headwordNormalized.equals(normalized))
            ..where((w) => w.deletedAt.isNull())
            ..limit(1))
          .getSingleOrNull();

  /// Inserts a word.
  Future<void> insertWord(WordsCompanion word) => into(words).insert(word);

  /// Applies a partial update to one word.
  Future<int> patchWord(String id, WordsCompanion patch) =>
      (update(words)..where((w) => w.id.equals(id))).write(patch);

  /// Soft-deletes a word (F-008).
  ///
  /// Sets `deleted_at` and nothing else, so Undo is a single write back to
  /// null and every note, highlight and list membership survives untouched.
  Future<int> softDelete(String id, DateTime deletedAt) =>
      (update(words)..where((w) => w.id.equals(id))).write(
        WordsCompanion(deletedAt: Value(deletedAt)),
      );

  /// Restores a soft-deleted word - the Undo action.
  Future<int> restore(String id) =>
      (update(words)..where((w) => w.id.equals(id))).write(
        const WordsCompanion(deletedAt: Value(null)),
      );

  /// Permanently removes words soft-deleted before [cutoff].
  ///
  /// The only place in the app that hard-deletes user content, and only after
  /// the 30 days `docs/RULES.md` section 10 allows. Cascades take the notes,
  /// highlights, memberships and study card with it.
  Future<int> purgeDeletedBefore(DateTime cutoff) =>
      (delete(words)
            ..where((w) => w.deletedAt.isNotNull())
            ..where(
              (w) => w.deletedAt.isSmallerThanValue(
                cutoff.toUtc().millisecondsSinceEpoch,
              ),
            ))
          .go();

  /// How many live words there are - drives the practice hub's unlock hints.
  Stream<int> watchCount() {
    final count = words.id.count();
    final query = selectOnly(words)
      ..addColumns(<Expression<Object>>[count])
      ..where(words.deletedAt.isNull() & words.isArchived.equals(false));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }
}
