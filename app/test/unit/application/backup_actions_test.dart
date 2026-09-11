import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/backup/backup_actions.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';

import 'fake_backup_files.dart';
import 'fake_reminder_service.dart';
import 'fake_speech_service.dart';

/// Making a backup and handing it over (F-073).
///
/// The question here is when a backup counts as *made*: `last_backup_at` is
/// what Settings shows, so it must only move when the file actually went
/// somewhere.
void main() {
  late AppDatabase db;
  late Directory folder;
  late FakeBackupFiles files;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.memory();
    folder = await Directory.systemTemp.createTemp('vnb_actions_');
    files = FakeBackupFiles();
    container = ProviderContainer(
      overrides: <Override>[
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
          backupFiles: files,
          exportDirectory: () async => folder,
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await folder.delete(recursive: true);
  });

  BackupActions actions() => container.read(backupActionsProvider.notifier);

  Future<DateTime?> lastBackup() => container.read(lastBackupAtProvider.future);

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
}
