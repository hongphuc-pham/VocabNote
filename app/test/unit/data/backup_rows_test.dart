import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/backup_rows.dart';
import 'package:vocabnote/data/db/app_database.dart';

/// Checking a backup's rows against the schema this build has (F-074,
/// `docs/DATABASE.md` §5: "readers ignore unknown fields and default missing
/// ones").
///
/// Driven by the live Drift schema rather than a hand-written list, so a
/// column added by a later migration is understood without this reader
/// changing - and so the two can never disagree.
void main() {
  late AppDatabase db;
  late BackupRowReader reader;

  setUp(() {
    db = AppDatabase.memory();
    reader = BackupRowReader(db.allTables);
  });

  tearDown(() => db.close());

  BackupRow word([Map<String, Object?> changes = const <String, Object?>{}]) =>
      <String, Object?>{
        'id': 'w1',
        'headword': 'cough',
        'headword_normalized': 'cough',
        'source': 'manual',
        'created_at': 1,
        'updated_at': 2,
        ...changes,
      };

  ({List<BackupRow> rows, int rejected}) readWords(BackupRow row) =>
      reader.read('words', <BackupRow>[row]);

  test('keeps a sound row, without columns this build does not have', () {
    // A newer app's `synonyms` column: ignored, not a reason to refuse.
    final read = readWords(word(<String, Object?>{'synonyms': 'hack'}));

    expect(read.rejected, 0);
    expect(read.rows.single['headword'], 'cough');
    expect(read.rows.single.containsKey('synonyms'), isFalse);
  });

  test('leaves a missing column with a default for SQLite to fill', () {
    final read = readWords(word());

    expect(read.rejected, 0);
    expect(read.rows.single.containsKey('is_favourite'), isFalse);
  });

  test('refuses a row missing a column that has no default', () {
    final row = word()..remove('created_at');

    final read = readWords(row);

    expect(read.rows, isEmpty);
    expect(read.rejected, 1);
  });

  test('refuses a value of the wrong type', () {
    expect(readWords(word(<String, Object?>{'headword': 7})).rejected, 1);
    expect(
      readWords(word(<String, Object?>{'created_at': '2026'})).rejected,
      1,
    );
  });

  test('keeps null where a column allows it, refuses it where it must be '
      'set', () {
    final kept = readWords(word(<String, Object?>{'definition': null}));
    expect(kept.rows.single['definition'], isNull);
    expect(kept.rows.single.containsKey('definition'), isTrue);

    expect(readWords(word(<String, Object?>{'headword': null})).rejected, 1);
  });

  test('treats null in a defaulted column as missing', () {
    final read = readWords(word(<String, Object?>{'is_favourite': null}));

    expect(read.rejected, 0);
    expect(read.rows.single.containsKey('is_favourite'), isFalse);
  });

  test('a yes/no column takes 0, 1, true or false - and nothing else', () {
    int? favourite(Object? value) =>
        readWords(word(<String, Object?>{'is_favourite': value}))
                .rows
                .singleOrNull?['is_favourite']
            as int?;

    expect(favourite(true), 1);
    expect(favourite(false), 0);
    expect(favourite(1), 1);
    expect(favourite(0), 0);
    expect(readWords(word(<String, Object?>{'is_favourite': 2})).rejected, 1);
    expect(
      readWords(word(<String, Object?>{'is_favourite': 'yes'})).rejected,
      1,
    );
  });

  test('a decimal column takes a whole number', () {
    final read = reader.read('settings', <BackupRow>[
      <String, Object?>{'id': 1, 'tts_rate': 1},
    ]);

    expect(read.rows.single['tts_rate'], isA<double>());
    expect(read.rows.single['tts_rate'], 1.0);
  });

  test('a whole-number column refuses a fraction', () {
    expect(readWords(word(<String, Object?>{'created_at': 1.5})).rejected, 1);
  });

  test('counts only the rows it refused', () {
    final read = reader.read('words', <BackupRow>[
      word(),
      word(<String, Object?>{'id': 'w2', 'headword': null}),
      word(<String, Object?>{'id': 'w3'}),
    ]);

    expect(read.rows.map((r) => r['id']), <String>['w1', 'w3']);
    expect(read.rejected, 1);
  });
}
