import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/study_cards.dart';
import 'package:vocabnote/data/db/tables/word_list_items.dart';
import 'package:vocabnote/data/db/tables/word_lists.dart';
import 'package:vocabnote/data/db/tables/words.dart';

part 'lists_dao.g.dart';

/// A list row plus the counts its card shows (`docs/UI-UX.md` section 4.5).
class ListWithCounts {
  /// Creates a summary row.
  const new({
    required this.list,
    required this.wordCount,
    required this.dueCount,
  });

  /// The list itself.
  final WordListRow list;

  /// Live words in it, excluding soft-deleted and archived.
  final int wordCount;

  /// How many of those are due now - the badge.
  final int dueCount;
}

/// Reads and writes `word_lists` and `word_list_items` (F-042).
@DriftAccessor(tables: <Type>[WordLists, WordListItems, Words, StudyCards])
class ListsDao extends DatabaseAccessor<AppDatabase> with _$ListsDaoMixin {
  /// Creates the DAO.
  new(super.attachedDatabase);

  /// Watches every list in display order.
  Stream<List<WordListRow>> watchLists() =>
      (select(wordLists)..orderBy(<OrderClauseGenerator<WordLists>>[
            (l) => OrderingTerm.asc(l.sortOrder),
            (l) => OrderingTerm.asc(l.createdAt),
          ]))
          .watch();

  /// Watches every list together with its word and due counts.
  ///
  /// One grouped query for the whole grid rather than two per card, so adding
  /// a hundred lists does not mean two hundred queries.
  Stream<List<ListWithCounts>> watchListsWithCounts() {
    final wordCount = wordListItems.wordId.count();
    final dueCount = studyCards.wordId.count(
      filter:
          studyCards.suspended.equals(false) &
          studyCards.dueAt.isSmallerOrEqualValue(
            DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
    );

    final query =
        select(wordLists).join(<Join<HasResultSet, dynamic>>[
            leftOuterJoin(
              wordListItems,
              wordListItems.listId.equalsExp(wordLists.id),
            ),
            // Joining words lets the counts exclude deleted and archived
            // rows, which a plain count of memberships would wrongly include.
            leftOuterJoin(
              words,
              words.id.equalsExp(wordListItems.wordId) &
                  words.deletedAt.isNull() &
                  words.isArchived.equals(false),
            ),
            leftOuterJoin(studyCards, studyCards.wordId.equalsExp(words.id)),
          ])
          ..addColumns(<Expression<Object>>[wordCount, dueCount])
          ..groupBy(<Expression<Object>>[wordLists.id])
          ..orderBy(<OrderingTerm>[
            OrderingTerm.asc(wordLists.sortOrder),
            OrderingTerm.asc(wordLists.createdAt),
          ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ListWithCounts(
              list: row.readTable(wordLists),
              wordCount: row.read(wordCount) ?? 0,
              dueCount: row.read(dueCount) ?? 0,
            ),
          )
          .toList(),
    );
  }

  /// Watches one list.
  Stream<WordListRow?> watchById(String id) =>
      (select(wordLists)..where((l) => l.id.equals(id))).watchSingleOrNull();

  /// Reads one list.
  Future<WordListRow?> getById(String id) =>
      (select(wordLists)..where((l) => l.id.equals(id))).getSingleOrNull();

  /// Inserts a list.
  Future<void> insertList(WordListsCompanion list) =>
      into(wordLists).insert(list);

  /// Applies a partial update - rename, recolour or reorder.
  Future<int> patchList(String id, WordListsCompanion patch) =>
      (update(wordLists)..where((l) => l.id.equals(id))).write(patch);

  /// Deletes a list.
  ///
  /// **Never deletes words.** The cascade runs `word_lists` ->
  /// `word_list_items` and stops; the words themselves are untouched, and
  /// `lists_dao_test.dart` asserts exactly that.
  Future<int> deleteList(String id) =>
      (delete(wordLists)..where((l) => l.id.equals(id))).go();

  /// Writes a new display order in one transaction, so a reorder is never
  /// half-applied.
  Future<void> reorder(List<String> orderedIds) async {
    await transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(
          wordLists,
        )..where((l) => l.id.equals(orderedIds[i]))).write(
          WordListsCompanion(
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  /// Adds a word to a list. Doing it twice is not an error.
  Future<void> addWord({
    required String listId,
    required String wordId,
    required DateTime addedAt,
  }) => into(wordListItems).insert(
    WordListItemsCompanion.insert(
      listId: listId,
      wordId: wordId,
      addedAt: addedAt,
    ),
    mode: InsertMode.insertOrIgnore,
  );

  /// Removes a word from a list. The word itself is untouched.
  Future<int> removeWord({required String listId, required String wordId}) =>
      (delete(wordListItems)
            ..where((i) => i.listId.equals(listId))
            ..where((i) => i.wordId.equals(wordId)))
          .go();

  /// Sets exactly which lists a word belongs to, in one transaction.
  ///
  /// What the add-to-lists chips on the word form commit (F-042).
  Future<void> setListsForWord({
    required String wordId,
    required List<String> listIds,
    required DateTime addedAt,
  }) async {
    await transaction(() async {
      await (delete(wordListItems)..where((i) => i.wordId.equals(wordId))).go();
      if (listIds.isEmpty) return;
      await batch(
        (batch) => batch.insertAll(wordListItems, <WordListItemsCompanion>[
          for (final listId in listIds)
            WordListItemsCompanion.insert(
              listId: listId,
              wordId: wordId,
              addedAt: addedAt,
            ),
        ], mode: InsertMode.insertOrIgnore),
      );
    });
  }

  /// Watches which lists a word is in - drives the selected chips.
  Stream<List<String>> watchListIdsForWord(String wordId) =>
      (select(wordListItems)..where((i) => i.wordId.equals(wordId)))
          .watch()
          .map((rows) => rows.map((r) => r.listId).toList());
}
