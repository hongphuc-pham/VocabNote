import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/recovery_export.dart';
import 'package:vocabnote/data/db/app_database.dart';

import 'backup_support.dart';
import 'db_fixtures.dart';

/// *Export my data* on the recovery screen (DATABASE §3.6 and §3.10, A14).
///
/// The one situation in which Drift is, by definition, unavailable: it has
/// refused the file - a schema from a newer build, or a migration that
/// failed. The words are still in there, and this is how the user gets them
/// out: raw, read-only, into the same `.vnb` any other backup is.
void main() {
  late Directory dir;
  late Directory exports;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('vnb_recovery_');
    exports = await Directory(p.join(dir.path, 'export')).create();
    file = File(p.join(dir.path, 'vocabnote.sqlite'));
  });

  tearDown(() => dir.delete(recursive: true));

  Future<DecodedBackup> run() async {
    final exported = await exportUnopenableDatabase(
      database: file,
      appVersion: '1.0.0',
      exportDirectory: exports,
    );
    final backup = exported.valueOrNull;
    expect(backup, isNotNull, reason: '$exported');
    return BackupCodec.decode(await File(backup!.path).readAsBytes())
        .valueOrNull!;
  }

  test('a database too new to open is still exported, every table', () async {
    final db = AppDatabase(NativeDatabase(file));
    await seedWord(db, id: 'w1', headword: 'church', ipaUk: 'ˈtʃɜːtʃ');
    await seedNote(db, id: 'n1', wordId: 'w1', body: 'rounded lips');
    await seedHighlight(db, id: 'h1', wordId: 'w1', end: 3);
    await seedList(db, id: 'l1', name: 'IELTS');
    await seedMembership(db, listId: 'l1', wordId: 'w1');
    final before = await snapshot(db);
    await db.close();
    // What DatabaseOpener refuses: a schema from a build this one predates.
    sqlite3.open(file.path)
      ..execute('PRAGMA user_version = 99')
      ..close();

    final backup = await run();

    expect(backup.tables, before);
    expect(backup.manifest.schemaVersion, 99);
  });

  test('tables an older database lacks come out empty, not as a failure', () {
    sqlite3.open(file.path)
      ..execute('CREATE TABLE words (id TEXT PRIMARY KEY, headword TEXT)')
      ..execute("INSERT INTO words VALUES ('w1', 'cough')")
      ..close();

    return run().then((backup) {
      expect(backup.tables['words']!.single['headword'], 'cough');
      expect(backup.tables['word_notes'], isEmpty);
    });
  });

  test('the database file is only read, never changed', () async {
    final db = AppDatabase(NativeDatabase(file));
    await seedWord(db, id: 'w1', headword: 'cough');
    await db.close();
    final untouched = file.readAsBytesSync();

    await run();

    expect(file.readAsBytesSync(), untouched);
  });

  test('a file that is not a database is a failure, not a crash', () async {
    file.writeAsStringSync('these are not the pages you are looking for');

    final exported = await exportUnopenableDatabase(
      database: file,
      appVersion: '1.0.0',
      exportDirectory: exports,
    );

    expect(exported.isErr, isTrue);
  });
}
