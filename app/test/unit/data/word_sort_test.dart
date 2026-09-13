import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';

import 'db_fixtures.dart';

/// The three orders the words list offers (`docs/UI-UX.md` §4.1), each pinned
/// by what the user sees.
///
/// Until M7 they had timing tests and no order tests, so a change made for
/// speed could have reordered the list without a test noticing.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  Future<List<String>> headwords(WordSort sort, {int? limit}) async => <String>[
    for (final word in await db.wordsDao.getWords(
      WordQuery(sort: sort, limit: limit),
    ))
      word.headword,
  ];

  group('least known', () {
    test(
      'no card first, then the lowest box, the most lapses, then A to Z',
      () async {
        await seedWord(db, id: 'a', headword: 'apple', box: 2);
        await seedWord(db, id: 'b', headword: 'banana');
        await seedWord(db, id: 'c', headword: 'cherry');
        await seedWord(db, id: 'd', headword: 'damson');
        // A word with no card yet has never been practised: the least known of
        // all.
        await seedWord(db, id: 'e', headword: 'elder', withCard: false);
        await db.customStatement(
          "UPDATE study_cards SET lapses = 3 WHERE word_id = 'd'",
        );
        await db.customStatement(
          "UPDATE study_cards SET lapses = 1 WHERE word_id = 'c'",
        );

        expect(await headwords(WordSort.leastKnown), <String>[
          'elder',
          'damson',
          'cherry',
          'banana',
          'apple',
        ]);
      },
    );

    test(
      'leaves out deleted and archived words, and honours a limit',
      () async {
        await seedWord(db, id: 'a', headword: 'apple');
        await seedWord(db, id: 'b', headword: 'banana');
        await seedWord(db, id: 'c', headword: 'cherry', isArchived: true);
        await seedWord(db, id: 'd', headword: 'damson');
        await db.customStatement(
          "UPDATE words SET deleted_at = 1 WHERE id = 'd'",
        );

        expect(await headwords(WordSort.leastKnown), <String>[
          'apple',
          'banana',
        ]);
        expect(await headwords(WordSort.leastKnown, limit: 1), <String>[
          'apple',
        ]);
      },
    );
  });

  test('recent: the most recently changed first', () async {
    await seedWord(db, id: 'a', headword: 'apple', updatedAt: testNow);
    await seedWord(
      db,
      id: 'b',
      headword: 'banana',
      updatedAt: testNow.add(const Duration(days: 2)),
    );
    await seedWord(
      db,
      id: 'c',
      headword: 'cherry',
      updatedAt: testNow.add(const Duration(days: 1)),
    );

    expect(await headwords(WordSort.recent), <String>[
      'banana',
      'cherry',
      'apple',
    ]);
  });

  test('alphabetical: A to Z, whatever the capitals', () async {
    await seedWord(db, id: 'a', headword: 'Zebra');
    await seedWord(db, id: 'b', headword: 'apple');
    await seedWord(db, id: 'c', headword: 'Mango');

    expect(await headwords(WordSort.alphabetical), <String>[
      'apple',
      'Mango',
      'Zebra',
    ]);
  });
}
