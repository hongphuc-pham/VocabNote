import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/backup/backup_actions.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/diagnostics/file_error_log.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';

import '../data/backup_support.dart';
import '../data/db_fixtures.dart';
import 'fake_backup_files.dart';
import 'fake_reminder_service.dart';
import 'fake_speech_service.dart';

/// Making a backup and handing it over (F-073), and choosing one to bring in
/// (F-074).
///
/// For export the question is when a backup counts as *made*:
/// `last_backup_at` is what Settings shows, so it must only move when the
/// file actually went somewhere. For import it is what the user is told about
/// a file before anything on the phone changes.
void main() {
  late AppDatabase db;
  late Directory folder;
  late Directory safety;
  late FakeBackupFiles files;
  late FakeReminderService reminders;
  late FileErrorLog errorLog;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.memory();
    folder = await Directory.systemTemp.createTemp('vnb_actions_');
    safety = await Directory.systemTemp.createTemp('vnb_actions_safety_');
    files = FakeBackupFiles();
    reminders = FakeReminderService();
    errorLog = FileErrorLog(File('${folder.path}/errors.log'));
    container = ProviderContainer(
      overrides: <Override>[
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: reminders,
          backupFiles: files,
          exportDirectory: () async => folder,
          safetyDirectory: () async => safety,
          errorLog: errorLog,
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await folder.delete(recursive: true);
    await safety.delete(recursive: true);
  });

  BackupActions actions() => container.read(backupActionsProvider.notifier);

  Future<DateTime?> lastBackup() => container.read(lastBackupAtProvider.future);

  /// A real `.vnb` holding [headwords], made on another "phone".
  Future<Uint8List> backupOfWords(List<String> headwords) async {
    final other = AppDatabase.memory();
    addTearDown(other.close);
    for (var i = 0; i < headwords.length; i++) {
      await seedWord(other, id: 'b$i', headword: headwords[i]);
    }
    final tables = await snapshot(other);
    return BackupCodec.encode(
      BackupCodec.manifestFor(
        appVersion: '1.0.0',
        schemaVersion: AppDatabase.latestSchemaVersion,
        exportedAt: testNow,
        tables: tables,
      ),
      tables,
    );
  }

  group('export', () {
    test('a backup that was shared is recorded', () async {
      expect(await lastBackup(), isNull, reason: 'a new install has none');

      final outcome = await actions().export();

      expect(outcome, ExportOutcome.shared);
      expect(files.shared.single.fileName, endsWith('.vnb'));
      expect(await lastBackup(), isNotNull);
    });

    test('closing the share sheet without choosing records nothing', () async {
      files.outcome = ShareOutcome.dismissed;

      final outcome = await actions().export();

      expect(outcome, ExportOutcome.notShared);
      expect(await lastBackup(), isNull);
    });

    test('a share sheet that cannot tell counts as shared', () async {
      // Some platforms never report what the user picked. Saying "not backed
      // up" after they did would be worse than trusting them.
      files.outcome = ShareOutcome.unknown;

      expect(await actions().export(), ExportOutcome.shared);
      expect(await lastBackup(), isNotNull);
    });

    test('a share sheet that will not open records nothing', () async {
      files.fail = true;

      expect(await actions().export(), ExportOutcome.failed);
      expect(await lastBackup(), isNull);
    });
  });

  group('choosing a backup to import', () {
    test('a picker closed without choosing is nothing at all', () async {
      expect(await actions().pickBackup(), isA<PickCancelled>());
    });

    test('a file that is not a backup is refused, with the reason', () async {
      files.picked = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

      expect(
        await actions().pickBackup(),
        isA<PickRefused>().having(
          (r) => r.problem,
          'problem',
          BackupProblem.notABackup,
        ),
      );
    });

    test('a file the picker found too large keeps that reason', () async {
      // Refused on its size, before a byte of it is read.
      files.pickFailure = const InvalidBackupFailure(
        problem: BackupProblem.tooLarge,
      );

      expect(
        await actions().pickBackup(),
        isA<PickRefused>().having(
          (r) => r.problem,
          'problem',
          BackupProblem.tooLarge,
        ),
      );
    });

    test('a file that cannot be opened is refused without a reason', () async {
      files.pickFailure = const FileFailure(kind: FileFailureKind.io);

      expect(
        await actions().pickBackup(),
        isA<PickRefused>().having((r) => r.problem, 'problem', isNull),
      );
    });

    test('a real backup is ready, saying what it holds', () async {
      files.picked = await backupOfWords(<String>['cough', 'church']);

      final outcome = await actions().pickBackup();

      expect(outcome, isA<PickReady>());
      expect((outcome as PickReady).backup.manifest.wordCount, 2);
      expect(
        await db.customSelect('SELECT id FROM words').get(),
        isEmpty,
        reason: 'choosing is not importing',
      );
    });
  });

  group('bringing it in', () {
    Future<PickedBackup> ready() async {
      files.picked = await backupOfWords(<String>['cough', 'church']);
      return (await actions().pickBackup() as PickReady).backup;
    }

    test('merge brings the words in and leaves the reminder alone', () async {
      final report = await actions().importBackup(
        await ready(),
        ImportMode.merge,
      );

      expect(report?.wordsAdded, 2);
      expect(reminders.cancels, 0);
    });

    test('deleting everything empties the library and cancels the '
        'reminder', () async {
      await seedWord(db, id: 'w1', headword: 'cough');

      final deleted = await actions().deleteEverything();

      expect(deleted, isTrue);
      expect(await db.customSelect('SELECT id FROM words').get(), isEmpty);
      expect(reminders.cancels, 1);
    });

    test('deleting everything clears the error log too', () async {
      // A message line in it may still hold something the user typed.
      errorLog.record(StateError('something went wrong'), StackTrace.empty);

      await actions().deleteEverything();

      expect((await errorLog.read()).valueOrNull, isEmpty);
    });

    test(
      'deleting everything clears the share sheet and picker copies',
      () async {
        // Found on a device: both plugins keep a copy of the backup they
        // handled in the app's cache, and it holds the user's words.
        await actions().deleteEverything();

        expect(files.forgets, 1);
      },
    );

    test('replace also cancels a reminder this phone had scheduled', () async {
      // The restored settings have it off (it needs this phone's
      // permission); a notification still booked with the OS must not fire.
      final report = await actions().importBackup(
        await ready(),
        ImportMode.replace,
      );

      expect(report?.wordsAdded, 2);
      expect(reminders.cancels, 1);
    });
  });
}
