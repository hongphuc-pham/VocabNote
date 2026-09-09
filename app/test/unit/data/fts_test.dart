// `isNull`/`isNotNull` exist in both drift and matcher; matcher's win here.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/fts_query.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';

import 'db_fixtures.dart';

/// Full-text search over words and notes (F-041).
///
/// `words_fts` is kept in step by triggers, so most of what is tested here is
/// really "does the trigger fire" - the failure mode being a word the user
/// saved that search cannot find, which looks exactly like data loss to them.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  Future<List<String>> search(String term) async {
    final rows = await db.wordsDao.getWords(WordQuery(searchTerm: term));
    return rows.map((row) => row.headword).toList();
  }

  group('indexing words', () {
    test('a new word is searchable by its headword', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      expect(await search('cough'), <String>['cough']);
    });

    test('is searchable by definition and example', () async {
      await seedWord(
        db,
        id: 'w1',
        headword: 'cough',
        definition: 'to expel air from the lungs',
        example: 'She coughed all night',
      );

      expect(await search('lungs'), <String>['cough']);
      expect(await search('night'), <String>['cough']);
    });

    test('editing the definition updates the index', () async {
      await seedWord(db, id: 'w1', headword: 'cough', definition: 'original');
      await db.customStatement(
        "UPDATE words SET definition = 'replaced' WHERE id = 'w1'",
      );

      expect(await search('original'), isEmpty);
      expect(await search('replaced'), <String>['cough']);
    });

    test('deleting a word removes it from the index', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await (db.delete(db.words)..where((w) => w.id.equals('w1'))).go();

      expect(await search('cough'), isEmpty);
      final indexed = await db
          .customSelect('SELECT count(*) AS c FROM words_fts')
          .getSingle();
      expect(indexed.read<int>('c'), 0);
    });

    test('a soft-deleted word is not returned', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await db.wordsDao.softDelete('w1', DateTime.utc(2026, 9, 9));

      expect(await search('cough'), isEmpty);
    });

    test('restoring a soft-deleted word makes it findable again', () async {
      // The index keeps the row throughout, which is what makes Undo instant.
      await seedWord(db, id: 'w1', headword: 'cough');
      await db.wordsDao.softDelete('w1', DateTime.utc(2026, 9, 9));
      await db.wordsDao.restore('w1');

      expect(await search('cough'), <String>['cough']);
    });
  });

  group('indexing notes', () {
    test('a word is findable by the text of its note', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'mouth more open');

      expect(await search('mouth'), <String>['cough']);
    });

    test('editing a note replaces the old text in the index', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'original wording');
      await db.notesDao.patchNote(
        'n1',
        const WordNotesCompanion(body: Value('rewritten wording')),
      );

      expect(await search('original'), isEmpty);
      expect(await search('rewritten'), <String>['cough']);
    });

    test('deleting a note removes its text from the index', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'forgettable');
      await db.notesDao.deleteNote('n1');

      expect(await search('forgettable'), isEmpty);
      // ...but the word itself is still indexed.
      expect(await search('cough'), <String>['cough']);
    });

    test('several notes are all searchable', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'alpha');
      await seedNote(db, id: 'n2', wordId: 'w1', body: 'bravo');

      expect(await search('alpha'), <String>['cough']);
      expect(await search('bravo'), <String>['cough']);
    });

    test('deleting one note leaves the others indexed', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'alpha');
      await seedNote(db, id: 'n2', wordId: 'w1', body: 'bravo');
      await db.notesDao.deleteNote('n1');

      expect(await search('alpha'), isEmpty);
      expect(await search('bravo'), <String>['cough']);
    });
  });

  group('query building', () {
    test('quotes every token so operators are treated as text', () {
      expect(buildFtsMatchQuery('cough'), '"cough"*');
      expect(buildFtsMatchQuery('deep breath'), '"deep" "breath"*');
    });

    test('strips double quotes, which would escape the quoting', () {
      expect(buildFtsMatchQuery('say "ah"'), '"say" "ah"*');
    });

    test('returns null when nothing searchable remains', () {
      expect(buildFtsMatchQuery(''), isNull);
      expect(buildFtsMatchQuery('   '), isNull);
      expect(buildFtsMatchQuery('"""'), isNull);
    });

    test('FTS5 operators typed by a user do not blow up the query', () async {
      // Someone searching for `AND` or `*` should get no results, not a SQL
      // error - a user must not be able to break search by typing punctuation.
      await seedWord(db, id: 'w1', headword: 'cough');

      for (final term in <String>['AND', 'OR', 'NOT', 'NEAR', '*', '^', ':']) {
        await expectLater(search(term), completes, reason: 'term: $term');
      }
    });

    test('prefix matching finds a word before it is fully typed', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      expect(await search('cou'), <String>['cough']);
    });
  });

  group('filters combine with search', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'alpha', isFavourite: true);
      await seedWord(db, id: 'w2', headword: 'alpine');
      await seedList(db, id: 'l1', name: 'IELTS');
      await seedMembership(db, listId: 'l1', wordId: 'w2');
    });

    test('favourites narrows the results', () async {
      final rows = await db.wordsDao.getWords(
        const WordQuery(searchTerm: 'alp', filter: WordFilter.favourites),
      );
      expect(rows.map((r) => r.headword), <String>['alpha']);
    });

    test('a list narrows the results', () async {
      final rows = await db.wordsDao.getWords(
        const WordQuery(
          searchTerm: 'alp',
          filter: WordFilter.inList,
          listId: 'l1',
        ),
      );
      expect(rows.map((r) => r.headword), <String>['alpine']);
    });
  });

  group('rebuildFtsIndex', () {
    test('reproduces exactly what the triggers built', () async {
      await seedWord(
        db,
        id: 'w1',
        headword: 'cough',
        definition: 'expel air',
        example: 'she coughed',
      );
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'mouth more open');
      await seedWord(db, id: 'w2', headword: 'through');

      final before = await db
          .customSelect(
            'SELECT word_id, headword, definition, example, notes '
            'FROM words_fts ORDER BY word_id',
          )
          .get();

      await db.rebuildFtsIndex();

      final after = await db
          .customSelect(
            'SELECT word_id, headword, definition, example, notes '
            'FROM words_fts ORDER BY word_id',
          )
          .get();

      expect(after.map((r) => r.data), before.map((r) => r.data));
    });

    test(
      'search still works, and triggers still fire, after a rebuild',
      () async {
        await seedWord(db, id: 'w1', headword: 'cough');
        await db.rebuildFtsIndex();

        expect(await search('cough'), <String>['cough']);

        // A rebuild that forgot to recreate the triggers would pass the line
        // above and fail here.
        await seedWord(db, id: 'w2', headword: 'through');
        expect(await search('through'), <String>['through']);

        await seedNote(db, id: 'n1', wordId: 'w2', body: 'tricky vowel');
        expect(await search('tricky'), <String>['through']);
      },
    );

    test('recreates all six triggers', () async {
      await db.rebuildFtsIndex();
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'trigger' "
            'ORDER BY name',
          )
          .get();
      expect(rows.map((r) => r.read<String>('name')), <String>[
        'notes_fts_after_delete',
        'notes_fts_after_insert',
        'notes_fts_after_update',
        'words_fts_after_delete',
        'words_fts_after_insert',
        'words_fts_after_update',
      ]);
    });
  });

  group('at scale', () {
    test('finds one word among five thousand', () async {
      await seedManyWords(db, 5000);

      final stopwatch = Stopwatch()..start();
      final rows = await db.wordsDao.getWords(
        const WordQuery(searchTerm: 'word4242'),
      );
      stopwatch.stop();

      expect(rows.map((r) => r.headword), <String>['word4242']);
      // The F-041 budget is 100ms. Asserted loosely here because CI machines
      // vary; M7 owns the real benchmark.
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'search took ${stopwatch.elapsedMilliseconds}ms',
      );
    });
  });
}
