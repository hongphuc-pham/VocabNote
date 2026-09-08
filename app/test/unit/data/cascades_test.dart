// `isNull`/`isNotNull` exist in both drift and matcher; matcher's win here.
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/mappers.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

import 'db_fixtures.dart';

/// Proves the referential integrity `docs/DATABASE.md` §2 relies on.
///
/// Cascades are only real if `PRAGMA foreign_keys = ON` is set on the
/// connection - SQLite parses the constraints either way and silently ignores
/// them otherwise. These tests fail loudly if that pragma is ever dropped.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  group('deleting a word', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'mouth more open');
      await seedHighlight(db, id: 'h1', wordId: 'w1');
      await seedList(db, id: 'l1', name: 'IELTS');
      await seedMembership(db, listId: 'l1', wordId: 'w1');
      await seedSession(db, id: 's1');
      await seedAnswer(db, id: 'a1', sessionId: 's1', wordId: 'w1');
    });

    test(
      'takes its notes, highlights, card, memberships and answers',
      () async {
        await (db.delete(db.words)..where((w) => w.id.equals('w1'))).go();

        expect(await db.select(db.wordNotes).get(), isEmpty);
        expect(await db.select(db.ipaHighlights).get(), isEmpty);
        expect(await db.select(db.studyCards).get(), isEmpty);
        expect(await db.select(db.wordListItems).get(), isEmpty);
        expect(await db.select(db.practiceAnswers).get(), isEmpty);
      },
    );

    test('leaves the list itself alone', () async {
      await (db.delete(db.words)..where((w) => w.id.equals('w1'))).go();

      final lists = await db.select(db.wordLists).get();
      expect(lists.single.id, 'l1');
    });

    test('leaves the practice session alone', () async {
      // The answers go, but the session is history and stays.
      await (db.delete(db.words)..where((w) => w.id.equals('w1'))).go();

      final sessions = await db.select(db.practiceSessions).get();
      expect(sessions.single.id, 's1');
    });
  });

  group('deleting a list', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedWord(db, id: 'w2', headword: 'through');
      await seedList(db, id: 'l1', name: 'IELTS');
      await seedMembership(db, listId: 'l1', wordId: 'w1');
      await seedMembership(db, listId: 'l1', wordId: 'w2');
    });

    test('NEVER deletes the words in it', () async {
      // F-042, stated as an acceptance criterion: "deleting a list never
      // deletes words". This is the test that keeps it true.
      await db.listsDao.deleteList('l1');

      final words = await db.select(db.words).get();
      expect(words.map((w) => w.id), containsAll(<String>['w1', 'w2']));
      expect(await db.select(db.wordLists).get(), isEmpty);
      expect(await db.select(db.wordListItems).get(), isEmpty);
    });

    test('leaves their notes and study cards untouched', () async {
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'keep me');
      await db.listsDao.deleteList('l1');

      expect(await db.select(db.wordNotes).get(), hasLength(1));
      expect(await db.select(db.studyCards).get(), hasLength(2));
    });
  });

  group('deleting a practice session', () {
    test('takes its answers but not the words they refer to', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedSession(db, id: 's1');
      await seedAnswer(db, id: 'a1', sessionId: 's1', wordId: 'w1');

      await (db.delete(
        db.practiceSessions,
      )..where((s) => s.id.equals('s1'))).go();

      expect(await db.select(db.practiceAnswers).get(), isEmpty);
      expect(await db.select(db.words).get(), hasLength(1));
    });
  });

  group('orphans are refused', () {
    test('a note cannot reference a word that does not exist', () async {
      await expectLater(
        seedNote(db, id: 'n1', wordId: 'nope', body: 'orphan'),
        throwsA(anything),
      );
    });

    test('a highlight cannot reference a word that does not exist', () async {
      await expectLater(
        seedHighlight(db, id: 'h1', wordId: 'nope'),
        throwsA(anything),
      );
    });

    test('a membership cannot reference a list that does not exist', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await expectLater(
        seedMembership(db, listId: 'nope', wordId: 'w1'),
        throwsA(anything),
      );
    });

    test('an answer cannot reference a session that does not exist', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await expectLater(
        seedAnswer(db, id: 'a1', sessionId: 'nope', wordId: 'w1'),
        throwsA(anything),
      );
    });
  });

  group('soft delete', () {
    test('keeps every related row, so Undo restores the whole word', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'keep me');
      await seedHighlight(db, id: 'h1', wordId: 'w1');

      await db.wordsDao.softDelete('w1', DateTime.utc(2026, 9, 9));

      // Nothing cascaded: the row is still there, just flagged.
      expect(await db.select(db.wordNotes).get(), hasLength(1));
      expect(await db.select(db.ipaHighlights).get(), hasLength(1));
      expect(await db.select(db.studyCards).get(), hasLength(1));

      await db.wordsDao.restore('w1');
      final restored = await db.wordsDao.getById('w1');
      expect(restored!.deletedAt, isNull);
    });

    test('hides the word from queries while it is deleted', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await db.wordsDao.softDelete('w1', DateTime.utc(2026, 9, 9));

      expect(await db.wordsDao.getWords(const WordQuery()), isEmpty);
      // ...but getById still finds it, because Undo has to.
      expect(await db.wordsDao.getById('w1'), isNotNull);
    });
  });

  group('purge', () {
    test('removes only words deleted before the cutoff', () async {
      await seedWord(db, id: 'old', headword: 'old');
      await seedWord(db, id: 'recent', headword: 'recent');

      await db.wordsDao.softDelete('old', DateTime.utc(2026));
      await db.wordsDao.softDelete('recent', DateTime.utc(2026, 9));

      final purged = await db.wordsDao.purgeDeletedBefore(
        DateTime.utc(2026, 6),
      );

      expect(purged, 1);
      expect(await db.wordsDao.getById('old'), isNull);
      expect(await db.wordsDao.getById('recent'), isNotNull);
    });

    test('never touches a word that is not soft-deleted', () async {
      await seedWord(db, id: 'live', headword: 'live');

      final purged = await db.wordsDao.purgeDeletedBefore(DateTime.utc(2099));

      expect(purged, 0);
      expect(await db.wordsDao.getById('live'), isNotNull);
    });

    test("cascades to the purged word's children", () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedNote(db, id: 'n1', wordId: 'w1', body: 'gone too');
      await db.wordsDao.softDelete('w1', DateTime.utc(2026));

      await db.wordsDao.purgeDeletedBefore(DateTime.utc(2026, 6));

      expect(await db.select(db.wordNotes).get(), isEmpty);
    });
  });

  group('study cards', () {
    test('there can only ever be one per word', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      // seedWord already created one; a second insert must not duplicate it.
      await db.practiceDao.insertCard(
        StudyCard.newCard(
          wordId: 'w1',
          now: DateTime.utc(2026, 9, 9),
        ).toCompanion(),
      );
      expect(await db.select(db.studyCards).get(), hasLength(1));
    });
  });

  group('enums round-trip through storage', () {
    test('values are stored as documented, not as Dart identifiers', () async {
      await seedWord(db, id: 'w1', headword: 'cough', source: WordSource.api);
      await seedHighlight(
        db,
        id: 'h1',
        wordId: 'w1',
        target: HighlightTarget.ipaUs,
        color: IpaColorToken.violet,
      );
      await seedSession(db, id: 's1', mode: PracticeMode.quickTest);

      final raw = await db
          .customSelect(
            'SELECT w.source AS s, h.target AS t, h.color_token AS c, '
            'p.mode AS m, p.source_kind AS k '
            'FROM words w, ipa_highlights h, practice_sessions p',
          )
          .getSingle();

      expect(raw.read<String>('s'), 'api');
      expect(raw.read<String>('t'), 'ipa_us');
      expect(raw.read<String>('c'), 'violet');
      // The one that would silently break with drift's textEnum().
      expect(raw.read<String>('m'), 'quick_test');
      expect(raw.read<String>('k'), 'all');
    });

    test('an unknown stored value falls back instead of throwing', () async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await db.customStatement(
        "UPDATE words SET source = 'telepathy' WHERE id = 'w1'",
      );

      final row = await db.wordsDao.getById('w1');
      // manual is the safe fallback: it claims no attribution.
      expect(row!.source, WordSource.manual);
    });
  });

  group('timestamps', () {
    test('are stored as epoch milliseconds UTC', () async {
      final when = DateTime.utc(2026, 9, 9, 12, 34, 56, 789);
      await seedWord(db, id: 'w1', headword: 'cough', createdAt: when);

      final raw = await db
          .customSelect("SELECT created_at AS c FROM words WHERE id = 'w1'")
          .getSingle();

      expect(raw.read<int>('c'), when.millisecondsSinceEpoch);
      // The millisecond must survive: drift's default dateTime() would store
      // seconds and silently drop it.
      expect(raw.read<int>('c') % 1000, 789);
    });

    test('come back as UTC, not local time', () async {
      final when = DateTime.utc(2026, 9, 9, 12);
      await seedWord(db, id: 'w1', headword: 'cough', createdAt: when);

      final row = await db.wordsDao.getById('w1');
      expect(row!.createdAt.isUtc, isTrue);
      expect(row.createdAt, when);
    });
  });
}
