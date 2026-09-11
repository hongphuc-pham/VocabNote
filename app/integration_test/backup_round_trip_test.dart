import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vocabnote/data/backup/library_wipe.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/user_data_repository_impl.dart';
import 'package:vocabnote/domain/entities/backup.dart';

import '../test/unit/data/backup_support.dart';
import '../test/unit/data/db_fixtures.dart';

/// PLAN.md M6's exit criterion, on a device: export → wipe → import
/// round-trips, every table deep-equal.
///
/// The host test (`test/unit/data/backup_replace_test.dart`) proves the same
/// thing against SQLite on the build machine. This one proves it where users
/// are: the phone's own SQLite, a real file in the app's storage,
/// `path_provider`'s real folders, and encoding on a real second isolate.
///
///     flutter test integration_test/backup_round_trip_test.dart -d <device>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('export, wipe, import: every table comes back exactly', (
    tester,
  ) async {
    final temporary = await getTemporaryDirectory();
    final root = Directory(p.join(temporary.path, 'vnb_round_trip'));
    if (root.existsSync()) root.deleteSync(recursive: true);
    root.createSync(recursive: true);
    final db = AppDatabase(
      NativeDatabase(File(p.join(root.path, 'vocabnote.sqlite'))),
    );

    try {
      // A library with something in every table, including a soft-deleted
      // word (Replace must restore it with its deletion time) and IPA with
      // multi-codepoint symbols.
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
      final before = await snapshot(db);

      final repository = UserDataRepositoryImpl(
        db,
        appVersion: 'integration',
        exportDirectory: () async => Directory(p.join(root.path, 'export')),
        safetyDirectory: () async => Directory(p.join(root.path, 'backups')),
        libraryDirectory: () async => root,
      );

      final exported = (await repository.exportBackup()).valueOrNull;
      expect(exported, isNotNull, reason: 'the export was written');
      final bytes = await File(exported!.path).readAsBytes();

      await wipeLibrary(db);
      expect(await rowsOf(db, 'words'), isEmpty, reason: 'the wipe wiped');

      final imported = await repository.importBackup(bytes, ImportMode.replace);
      expect(imported.isOk, isTrue, reason: '$imported');

      expect(await snapshot(db), before);
    } finally {
      await db.close();
      root.deleteSync(recursive: true);
    }
  });
}
