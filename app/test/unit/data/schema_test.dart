import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/app_meta.dart';

/// Asserts the physical schema matches `docs/DATABASE.md` section 2.
///
/// The generated code is trusted to compile, but not to be *right*: this reads
/// what SQLite actually created and compares it to the specification, so a
/// column silently renamed or a foreign key silently dropped fails the build.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
    // beforeOpen only runs on first use, so touch the database once.
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  Future<List<Map<String, Object?>>> pragma(String sql) async {
    final rows = await db.customSelect(sql).get();
    return rows.map((row) => row.data).toList();
  }

  Future<Set<String>> columnsOf(String table) async {
    final rows = await pragma("PRAGMA table_info('$table')");
    return rows.map((row) => row['name']! as String).toSet();
  }

  Future<Map<String, String>> columnTypesOf(String table) async {
    final rows = await pragma("PRAGMA table_info('$table')");
    return <String, String>{
      for (final row in rows)
        row['name']! as String: (row['type']! as String).toUpperCase(),
    };
  }

  Future<Set<String>> notNullColumnsOf(String table) async {
    final rows = await pragma("PRAGMA table_info('$table')");
    return rows
        .where((row) => (row['notnull']! as int) == 1)
        .map((row) => row['name']! as String)
        .toSet();
  }

  group('tables', () {
    test('every documented table exists', () async {
      final rows = await pragma(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final names = rows.map((row) => row['name']! as String).toSet();

      expect(
        names,
        containsAll(<String>[
          'words',
          'word_notes',
          'ipa_highlights',
          'word_lists',
          'word_list_items',
          'study_cards',
          'practice_sessions',
          'practice_answers',
          'app_meta',
          'settings',
          'words_fts',
        ]),
      );
    });
  });

  group('words', () {
    test('has exactly the documented columns', () async {
      expect(await columnsOf('words'), <String>{
        'id',
        'headword',
        'headword_normalized',
        'part_of_speech',
        'ipa_uk',
        'ipa_us',
        'definition',
        'example',
        'source',
        'source_attribution',
        'is_favourite',
        'is_archived',
        'created_at',
        'updated_at',
        'deleted_at',
      });
    });

    test('ids are TEXT and timestamps are INTEGER', () async {
      final types = await columnTypesOf('words');
      expect(types['id'], 'TEXT');
      expect(types['headword'], 'TEXT');
      expect(types['created_at'], 'INTEGER');
      expect(types['updated_at'], 'INTEGER');
      expect(types['deleted_at'], 'INTEGER');
    });

    test('nullability matches the spec', () async {
      final notNull = await notNullColumnsOf('words');
      expect(
        notNull,
        containsAll(<String>[
          'id',
          'headword',
          'headword_normalized',
          'source',
          'is_favourite',
          'is_archived',
          'created_at',
          'updated_at',
        ]),
      );
      // Everything the user may leave blank must stay nullable.
      expect(
        notNull,
        isNot(
          anyOf(
            contains('part_of_speech'),
            contains('ipa_uk'),
            contains('ipa_us'),
            contains('definition'),
            contains('example'),
            contains('source_attribution'),
            contains('deleted_at'),
          ),
        ),
      );
    });
  });

  group('timestamps', () {
    test('every timestamp column is INTEGER, never TEXT', () async {
      // docs/DATABASE.md section 2: epoch milliseconds UTC. Drift's default
      // for dateTime() is unix *seconds*, and its text mode would make these
      // TEXT - either would be a silent data change.
      const expected = <String, List<String>>{
        'words': <String>['created_at', 'updated_at', 'deleted_at'],
        'word_notes': <String>['created_at', 'updated_at'],
        'ipa_highlights': <String>['created_at'],
        'word_lists': <String>['created_at', 'updated_at'],
        'word_list_items': <String>['added_at'],
        'study_cards': <String>['due_at', 'last_reviewed_at'],
        'practice_sessions': <String>['started_at', 'ended_at'],
        'practice_answers': <String>['answered_at'],
      };

      for (final entry in expected.entries) {
        final types = await columnTypesOf(entry.key);
        for (final column in entry.value) {
          expect(
            types[column],
            'INTEGER',
            reason: '${entry.key}.$column must be epoch milliseconds',
          );
        }
      }
    });
  });

  group('primary keys', () {
    test('study_cards is keyed by word_id, one card per word', () async {
      final rows = await pragma("PRAGMA table_info('study_cards')");
      final pk = rows
          .where((row) => (row['pk']! as int) > 0)
          .map((row) => row['name']! as String);
      expect(pk, <String>['word_id']);
    });

    test('word_list_items is keyed by (list_id, word_id)', () async {
      final rows = await pragma("PRAGMA table_info('word_list_items')");
      final pk = rows
          .where((row) => (row['pk']! as int) > 0)
          .map((row) => row['name']! as String)
          .toSet();
      expect(pk, <String>{'list_id', 'word_id'});
    });

    test('settings is a single row keyed by id', () async {
      final rows = await pragma("PRAGMA table_info('settings')");
      final pk = rows
          .where((row) => (row['pk']! as int) > 0)
          .map((row) => row['name']! as String);
      expect(pk, <String>['id']);
    });
  });

  group('foreign keys', () {
    Future<List<Map<String, Object?>>> foreignKeysOf(String table) =>
        pragma("PRAGMA foreign_key_list('$table')");

    test('every child table cascades from its parent', () async {
      const expected = <String, List<({String table, String from})>>{
        'word_notes': <({String table, String from})>[
          (table: 'words', from: 'word_id'),
        ],
        'ipa_highlights': <({String table, String from})>[
          (table: 'words', from: 'word_id'),
        ],
        'study_cards': <({String table, String from})>[
          (table: 'words', from: 'word_id'),
        ],
        'word_list_items': <({String table, String from})>[
          (table: 'words', from: 'word_id'),
          (table: 'word_lists', from: 'list_id'),
        ],
        'practice_answers': <({String table, String from})>[
          (table: 'words', from: 'word_id'),
          (table: 'practice_sessions', from: 'session_id'),
        ],
      };

      for (final entry in expected.entries) {
        final keys = await foreignKeysOf(entry.key);
        for (final want in entry.value) {
          final match = keys.firstWhere(
            (key) => key['table'] == want.table && key['from'] == want.from,
            orElse: () => <String, Object?>{},
          );
          expect(
            match,
            isNotEmpty,
            reason: '${entry.key}.${want.from} -> ${want.table} is missing',
          );
          expect(
            match['on_delete'],
            'CASCADE',
            reason: '${entry.key}.${want.from} must cascade',
          );
        }
      }
    });

    test(
      'practice_sessions.source_id is deliberately not a foreign key',
      () async {
        // Deleting a list must not erase the history of having practised it.
        final keys = await foreignKeysOf('practice_sessions');
        expect(keys, isEmpty);
      },
    );

    test('foreign keys are actually enforced on this connection', () async {
      // Without PRAGMA foreign_keys = ON, SQLite parses the constraints and
      // then ignores them - every cascade in this file would be decoration.
      final rows = await pragma('PRAGMA foreign_keys');
      expect(rows.single.values.first, 1);
    });
  });

  group('indexes', () {
    test('the documented indexes exist', () async {
      final rows = await pragma(
        "SELECT name FROM sqlite_master WHERE type = 'index'",
      );
      final names = rows.map((row) => row['name']! as String).toSet();
      expect(
        names,
        containsAll(<String>[
          'idx_words_normalized',
          'idx_words_updated',
          'idx_cards_due',
        ]),
      );
    });
  });

  group('seeded defaults', () {
    test('onCreate writes exactly one settings row', () async {
      final rows = await db.settingsDao.watchSettings().first;
      expect(rows.id, 1);
      expect(rows.dailyGoal, 20);
      expect(rows.lookupEnabled, isTrue);
      expect(rows.reminderEnabled, isFalse, reason: 'reminders are opt-in');
    });

    test('the settings CHECK constraint forbids a second row', () async {
      await expectLater(
        db.customStatement('INSERT INTO settings (id) VALUES (2)'),
        throwsA(anything),
      );
    });

    test('onCreate seeds app_meta but seeds no lists', () async {
      expect(
        await db.metaDao.get(AppMetaKeys.schemaVersionMirror),
        '${db.schemaVersion}',
      );
      expect(
        await db.metaDao.getBool(AppMetaKeys.onboardingCompleted),
        isFalse,
      );
      expect(await db.metaDao.get(AppMetaKeys.installId), isNotEmpty);

      // "All words" is a filter chip, not a row (docs/UI-UX.md section 4.1).
      expect(await db.listsDao.watchLists().first, isEmpty);
    });
  });

  group('check constraints', () {
    test('a highlight cannot be zero-width or reversed', () async {
      await db.customStatement(
        'INSERT INTO words (id, headword, headword_normalized, source, '
        'is_favourite, is_archived, created_at, updated_at) '
        "VALUES ('w1', 'cough', 'cough', 'manual', 0, 0, 1, 1)",
      );
      await expectLater(
        db.customStatement(
          'INSERT INTO ipa_highlights '
          '(id, word_id, target, start_grapheme, end_grapheme, color_token, '
          'created_at) '
          "VALUES ('h1', 'w1', 'ipa_uk', 3, 3, 'amber', 1)",
        ),
        throwsA(anything),
      );
    });

    test('a Leitner box outside 0-6 is rejected', () async {
      await db.customStatement(
        'INSERT INTO words (id, headword, headword_normalized, source, '
        'is_favourite, is_archived, created_at, updated_at) '
        "VALUES ('w2', 'cough', 'cough', 'manual', 0, 0, 1, 1)",
      );
      await expectLater(
        db.customStatement(
          'INSERT INTO study_cards (word_id, box, due_at) '
          "VALUES ('w2', 9, 1)",
        ),
        throwsA(anything),
      );
    });
  });
}
