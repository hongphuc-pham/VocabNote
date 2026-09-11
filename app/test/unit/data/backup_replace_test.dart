import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/backup/library_wipe.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/app_meta.dart';
import 'package:vocabnote/data/repositories/user_data_repository_impl.dart';
import 'package:vocabnote/domain/entities/backup.dart';

import 'backup_support.dart';
import 'db_fixtures.dart';

/// Replacing everything with a backup, the wipe it shares, and the round
/// trip that is M6's exit criterion (F-074, `docs/PLAN.md` M6,
/// `docs/DATABASE.md` §5).
void main() {
  late AppDatabase phone;
  late Directory exports;
  late Directory safety;
  var clock = DateTime(2026, 9, 11, 14, 5);

  setUp(() async {
    phone = AppDatabase.memory();
    exports = await Directory.systemTemp.createTemp('vnb_exports_');
    safety = await Directory.systemTemp.createTemp('vnb_safety_');
    clock = DateTime(2026, 9, 11, 14, 5);
  });

  tearDown(() async {
    await phone.close();
    await exports.delete(recursive: true);
    await safety.delete(recursive: true);
  });

  UserDataRepositoryImpl repositoryFor(AppDatabase db) =>
      UserDataRepositoryImpl(
        db,
        appVersion: '1.0.0',
        exportDirectory: () async => exports,
        safetyDirectory: () async => safety,
        now: () => clock,
      );

  Future<Uint8List> exportOf(AppDatabase db) async {
    final exported = (await repositoryFor(db).exportBackup()).valueOrNull!;
    return await File(exported.path).readAsBytes();
  }

  AsyncResult<ImportReport> replaceWith(Uint8List bytes) =>
      repositoryFor(phone).importBackup(bytes, ImportMode.replace);

  Future<void> seedLibrary(AppDatabase db) async {
    await seedWord(db, id: 'w1', headword: 'church', ipaUk: 'ˈtʃɜːtʃ');
    await seedWord(db, id: 'w2', headword: 'cough', isFavourite: true);
    await seedWord(db, id: 'w3', headword: 'gone');
    await db.customStatement(
      'UPDATE words SET deleted_at = ? WHERE id = ?',
      <Object>[ms(testNow), 'w3'],
    );
    await seedNote(db, id: 'n1', wordId: 'w1', body: 'rounded lips');
    await seedHighlight(db, id: 'h1', wordId: 'w1', end: 3, label: 'tʃ');
    await seedList(db, id: 'l1', name: 'IELTS');
    await seedMembership(db, listId: 'l1', wordId: 'w1');
    await db.customStatement(
      "UPDATE study_cards SET box = 3, lapses = 2, last_result = 'good', "
      "last_reviewed_at = ? WHERE word_id = 'w1'",
      <Object>[ms(testNow)],
    );
    await seedSession(db, id: 's1', endedAt: testNow, totalRounds: 1);
    await seedAnswer(db, id: 'a1', sessionId: 's1', wordId: 'w1');
    await db.customStatement(
      "UPDATE settings SET theme_mode = 'dark', daily_goal = 30, "
      "tts_rate = 0.35, review_schedule = '[0,1,3,5,8,20,40]'",
    );
  }

  test('export, wipe, import: every table comes back exactly', () async {
    // PLAN.md M6's exit criterion, on the host. The same path runs on a
    // device in integration_test/.
    await seedLibrary(phone);
    final before = await snapshot(phone);
    final bytes = await exportOf(phone);

    await wipeLibrary(phone);
    expect(await rowsOf(phone, 'words'), isEmpty);

    final report = await replaceWith(bytes);

    expect(report.isOk, isTrue, reason: '$report');
    expect(await snapshot(phone), before);
  });

  test('search works on what a replace brought back', () async {
    await seedLibrary(phone);
    final bytes = await exportOf(phone);
    await wipeLibrary(phone);

    await replaceWith(bytes);

    final hits = await phone
        .customSelect(
          "SELECT word_id FROM words_fts WHERE words_fts MATCH 'rounded'",
        )
        .get();
    expect(hits.map((r) => r.data['word_id']), <String>['w1']);
  });

  test('keeps a copy of what was here before replacing it', () async {
    await seedWord(phone, id: 'old', headword: 'mine');
    final other = AppDatabase.memory();
    addTearDown(other.close);
    await seedWord(other, id: 'new', headword: 'theirs');

    await replaceWith(await exportOf(other));

    expect((await rowsOf(phone, 'words')).map((w) => w['id']), <String>['new']);
    final copies = safety.listSync().whereType<File>().toList();
    expect(copies, hasLength(1));
    final copy = BackupCodec.decode(copies.single.readAsBytesSync());
    expect(copy.valueOrNull!.tables['words']!.map((w) => w['id']), <String>[
      'old',
    ]);
  });

  test('only the three newest safety copies are kept', () async {
    final bytes = await exportOf(phone);
    for (var i = 0; i < 4; i++) {
      clock = clock.add(const Duration(minutes: 1));
      await replaceWith(bytes);
    }

    expect(safety.listSync().whereType<File>(), hasLength(3));
  });

  test('a replaced library never switches the reminder on', () async {
    // The reminder needs *this* phone's permission, and only its switch may
    // ask (F-066).
    final other = AppDatabase.memory();
    addTearDown(other.close);
    await other.customStatement(
      'UPDATE settings SET reminder_enabled = 1, reminder_time_minutes = 480',
    );

    await replaceWith(await exportOf(other));

    final settings = (await rowsOf(phone, 'settings')).single;
    expect(settings['reminder_enabled'], 0);
    expect(settings['reminder_time_minutes'], 480);
  });

  test('a replace that fails leaves this phone as it was', () async {
    await seedWord(phone, id: 'old', headword: 'mine');
    final other = AppDatabase.memory();
    addTearDown(other.close);
    await seedLibrary(other);
    final bytes = await exportOf(other);
    final before = await snapshot(phone);
    await failInsertsInto(phone, 'word_lists');

    final result = await replaceWith(bytes);

    expect(result.isErr, isTrue);
    expect(await snapshot(phone), before);
    expect(
      safety.listSync().whereType<File>(),
      hasLength(1),
      reason: 'the safety copy was taken before anything was touched',
    );
  });

  test('a file that is not a backup changes nothing', () async {
    await seedWord(phone, id: 'old', headword: 'mine');
    final before = await snapshot(phone);

    final result = await repositoryFor(phone).importBackup(
      Uint8List.fromList(<int>[1, 2, 3, 4, 5]),
      ImportMode.replace,
    );

    expect(
      result,
      isA<Err<ImportReport, AppFailure>>().having(
        (e) => e.failure,
        'failure',
        isA<InvalidBackupFailure>().having(
          (f) => f.problem,
          'problem',
          BackupProblem.notABackup,
        ),
      ),
    );
    expect(await snapshot(phone), before);
    expect(safety.listSync(), isEmpty, reason: 'refused before any copy');
  });

  test('a preview says what a backup holds and writes nothing', () async {
    final other = AppDatabase.memory();
    addTearDown(other.close);
    await seedLibrary(other);
    final bytes = await exportOf(other);

    final preview = await repositoryFor(phone).previewBackup(bytes);

    expect(preview.valueOrNull!.wordCount, 3);
    expect(preview.valueOrNull!.appVersion, '1.0.0');
    expect(await rowsOf(phone, 'words'), isEmpty);
  });

  group('the wipe', () {
    test('removes every row and restores default settings', () async {
      await seedLibrary(phone);

      await wipeLibrary(phone);

      final after = await snapshot(phone);
      for (final MapEntry(:key, :value) in after.entries) {
        if (key == 'settings') continue;
        expect(value, isEmpty, reason: key);
      }
      final fresh = AppDatabase.memory();
      addTearDown(fresh.close);
      expect(after['settings'], (await snapshot(fresh))['settings']);
    });

    test('keeps this install its id and its finished onboarding', () async {
      await phone.metaDao.setBool(AppMetaKeys.onboardingCompleted, value: true);
      final id = await phone.metaDao.get(AppMetaKeys.installId);

      await wipeLibrary(phone);

      expect(await phone.metaDao.get(AppMetaKeys.installId), id);
      expect(
        await phone.metaDao.getBool(AppMetaKeys.onboardingCompleted),
        isTrue,
      );
    });
  });
}
