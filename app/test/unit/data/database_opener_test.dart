import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_opener.dart';

/// The data-safety promise, tested (`docs/DATABASE.md` §3, §1).
///
/// Installing a new version must adopt the existing file in place. There is no
/// backend to restore from, so these are the tests that stand between a user
/// and losing every word they ever saved.
void main() {
  late Directory tempRoot;
  late DatabaseOpener opener;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('vocabnote_open_test');
    opener = DatabaseOpener(resolveDirectory: () async => tempRoot);
  });

  tearDown(() async {
    if (tempRoot.existsSync()) await tempRoot.delete(recursive: true);
  });

  /// Writes a database file that claims to be at [version].
  Future<File> writeDatabaseAt(int version, {String? marker}) async {
    final location = await opener.resolveLocation();
    sqlite3.open(location.file.path)
      ..execute('CREATE TABLE IF NOT EXISTS keepsake (note TEXT)')
      ..execute(
        marker == null
            ? 'SELECT 1'
            : "INSERT INTO keepsake (note) VALUES ('$marker')",
      )
      // Last, so the version reflects a fully written file.
      ..execute('PRAGMA user_version = $version')
      ..close();
    return location.file;
  }

  group('location', () {
    test('lives under a vocabnote folder in application support', () async {
      final location = await opener.resolveLocation();

      expect(location.directory.path, endsWith('vocabnote'));
      expect(location.file.path, endsWith('vocabnote.sqlite'));
      expect(location.directory.existsSync(), isTrue);
    });

    test('names the backup after the version being left behind', () async {
      final location = await opener.resolveLocation();
      expect(location.backupFor(3).path, endsWith('vocabnote.pre-v3.bak'));
    });
  });

  group('reading the on-disk version', () {
    test('is 0 when there is no file yet', () async {
      final location = await opener.resolveLocation();
      expect(opener.readOnDiskVersion(location.file), 0);
    });

    test('reads user_version without migrating', () async {
      final file = await writeDatabaseAt(7);
      expect(opener.readOnDiskVersion(file), 7);
      // Still 7: reading must not have opened it through Drift.
      expect(opener.readOnDiskVersion(file), 7);
    });

    test('returns null for a file that is not a database', () async {
      final location = await opener.resolveLocation();
      await location.file.writeAsString('this is not a database');
      expect(opener.readOnDiskVersion(location.file), isNull);
    });
  });

  group('a fresh install', () {
    test('creates the database and seeds it', () async {
      final result = await opener.open();

      expect(result.isOk, isTrue, reason: '${result.failureOrNull}');
      final opened = result.valueOrNull!;
      expect(opened.migratedFrom, isNull);
      expect(opened.backup, isNull);

      final settings = await opened.database.settingsDao.getSettings();
      expect(settings.dailyGoal, 20);

      await opened.database.close();
    });

    test('takes no backup, because there is nothing to back up', () async {
      final result = await opener.open();
      final opened = result.valueOrNull!;

      expect(
        opened.location.backupFor(1).existsSync(),
        isFalse,
        reason: 'a fresh install has no previous version to preserve',
      );
      await opened.database.close();
    });
  });

  group('reopening at the same version', () {
    test('opens in place and takes no backup', () async {
      final first = await opener.open();
      await first.valueOrNull!.database.close();

      final second = await opener.open();
      expect(second.isOk, isTrue);
      expect(second.valueOrNull!.migratedFrom, isNull);
      expect(second.valueOrNull!.backup, isNull);
      await second.valueOrNull!.database.close();
    });

    test('keeps the data written by the previous run', () async {
      final first = await opener.open();
      await first.valueOrNull!.database.metaDao.set('probe', 'kept');
      await first.valueOrNull!.database.close();

      final second = await opener.open();
      expect(
        await second.valueOrNull!.database.metaDao.get('probe'),
        'kept',
        reason: 'reopening must adopt the existing file, not replace it',
      );
      await second.valueOrNull!.database.close();
    });
  });

  group('a database from a newer version', () {
    test('is refused rather than migrated downwards', () async {
      await writeDatabaseAt(99, marker: 'precious');

      final result = await opener.open();

      expect(result.isErr, isTrue);
      final failure = result.failureOrNull;
      expect(failure, isA<SchemaTooNewFailure>());
      expect((failure! as SchemaTooNewFailure).onDiskVersion, 99);
      // Whatever this build supports - hard-coding it would make the test
      // fail on every schema bump for no reason.
      expect(
        (failure as SchemaTooNewFailure).supportedVersion,
        AppDatabase.latestSchemaVersion,
      );
    });

    test('leaves the file completely untouched', () async {
      final file = await writeDatabaseAt(99, marker: 'precious');
      final before = await file.readAsBytes();

      await opener.open();

      expect(file.existsSync(), isTrue, reason: 'the file must survive');
      expect(
        await file.readAsBytes(),
        before,
        reason: 'refusing to open must not write a single byte',
      );

      // And the user's row is still readable.
      final raw = sqlite3.open(file.path);
      final rows = raw.select('SELECT note FROM keepsake');
      expect(rows.single['note'], 'precious');
      raw.close();
    });
  });

  group('an unreadable database', () {
    test('reports a corrupt file rather than starting fresh', () async {
      final location = await opener.resolveLocation();
      await location.file.writeAsString('not a database at all');

      final result = await opener.open();

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<FileFailure>());
      expect(
        (result.failureOrNull! as FileFailure).kind,
        FileFailureKind.corrupt,
      );
    });

    test('does not delete or overwrite the unreadable file', () async {
      final location = await opener.resolveLocation();
      await location.file.writeAsString('not a database at all');

      await opener.open();

      expect(location.file.existsSync(), isTrue);
      expect(
        await location.file.readAsString(),
        'not a database at all',
        reason: 'a file we cannot read is not a file we may destroy',
      );
    });
  });

  group('the promise', () {
    test('no code path in the opener deletes the database', () async {
      // Belt and braces alongside tool/check_migration_safety.dart: this
      // asserts the behaviour, that asserts the source text.
      final location = await opener.resolveLocation();

      for (final setup in <Future<void> Function()>[
        () async => await location.file.writeAsString('garbage'),
        () async => await writeDatabaseAt(99),
        () async {},
      ]) {
        if (location.file.existsSync()) await location.file.delete();
        await setup();
        final existedBefore = location.file.existsSync();

        final result = await opener.open();
        await result.valueOrNull?.database.close();

        if (existedBefore) {
          expect(
            location.file.existsSync(),
            isTrue,
            reason: 'the database file was removed by open()',
          );
        }
      }
    });
  });
}
