/// Making a backup and handing it over (F-073), and choosing one to bring in
/// (F-074).
library;

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';

part 'backup_actions.g.dart';

/// What exporting came to.
enum ExportOutcome {
  /// Written and handed to wherever the user chose.
  shared,

  /// Written, but the share sheet was closed without choosing. Not a failure,
  /// and not a backup either.
  notShared,

  /// The file could not be written, or the share sheet would not open.
  failed,
}

/// A backup file chosen and read, waiting for the user to say how it comes
/// in.
@immutable
class PickedBackup {
  /// Creates the picked backup.
  const new({required this.bytes, required this.manifest});

  /// The file, as read.
  final Uint8List bytes;

  /// What it says it holds.
  final BackupManifest manifest;
}

/// What choosing a backup file came to.
@immutable
sealed class PickOutcome {
  const new();
}

/// The picker was closed without choosing.
final class PickCancelled extends PickOutcome {
  /// Creates the outcome.
  const new();
}

/// The file cannot be used; [problem] says why, or is null when the file
/// could not be opened at all.
final class PickRefused extends PickOutcome {
  /// Creates the outcome.
  const new(this.problem);

  /// Why it was refused.
  final BackupProblem? problem;
}

/// A usable backup, read and previewed. Nothing has been written.
final class PickReady extends PickOutcome {
  /// Creates the outcome.
  const new(this.backup);

  /// The backup, ready to import.
  final PickedBackup backup;
}

/// When the last backup was handed over, or null if never.
@riverpod
Future<DateTime?> lastBackupAt(Ref ref) async =>
    (await ref.watch(settingsRepositoryProvider).lastBackupAt()).valueOrNull;

/// How many bytes the library takes on this phone, or null if it cannot be
/// measured just now.
@riverpod
Future<int?> storageUsed(Ref ref) async =>
    (await ref.watch(userDataRepositoryProvider).storageUsed()).valueOrNull;

/// The write side of the user's whole library: backup, import, delete.
@Riverpod(keepAlive: true)
class BackupActions extends _$BackupActions {
  @override
  void build() {}

  /// Writes a backup and offers it to the share sheet.
  ///
  /// `last_backup_at` moves only when the file went somewhere: Settings shows
  /// it, and "backed up" must not be claimed for a file that is still sitting
  /// in a cache folder. A platform that cannot say what the user chose is
  /// trusted - telling them "not backed up" after they did would be worse.
  Future<ExportOutcome> export({ShareAnchor? anchor}) async {
    final exported =
        (await ref.read(userDataRepositoryProvider).exportBackup()).valueOrNull;
    if (exported == null) return ExportOutcome.failed;

    final outcome =
        (await ref.read(backupFilesProvider).share(exported, anchor: anchor))
            .valueOrNull;
    switch (outcome) {
      case null:
        return ExportOutcome.failed;
      case ShareOutcome.dismissed:
        return ExportOutcome.notShared;
      case ShareOutcome.shared || ShareOutcome.unknown:
        await ref
            .read(settingsRepositoryProvider)
            .recordBackup(DateTime.now().toUtc());
        ref.invalidate(lastBackupAtProvider);
        return ExportOutcome.shared;
    }
  }

  /// Lets the user choose a backup, and reads what it holds.
  ///
  /// Writes nothing: the user sees what is inside - or why it cannot be used -
  /// before being asked how it should come in.
  Future<PickOutcome> pickBackup() async {
    final picked = await ref.read(backupFilesProvider).pick();
    final Uint8List bytes;
    switch (picked) {
      case Err(:final failure):
        return PickRefused(_problemOf(failure));
      case Ok(value: null):
        return const PickCancelled();
      case Ok(:final Uint8List value):
        bytes = value;
    }

    final preview = await ref
        .read(userDataRepositoryProvider)
        .previewBackup(bytes);
    return switch (preview) {
      Ok(value: final manifest) => PickReady(
        PickedBackup(bytes: bytes, manifest: manifest),
      ),
      Err(:final failure) => PickRefused(_problemOf(failure)),
    };
  }

  static BackupProblem? _problemOf(AppFailure failure) =>
      failure is InvalidBackupFailure ? failure.problem : null;

  /// Brings [backup] in, or returns null if it could not be - in which case
  /// nothing on the phone changed.
  Future<ImportReport?> importBackup(
    PickedBackup backup,
    ImportMode mode,
  ) async {
    final report =
        (await ref
                .read(userDataRepositoryProvider)
                .importBackup(backup.bytes, mode))
            .valueOrNull;
    if (report != null && mode == ImportMode.replace) {
      // The restored settings have the reminder off - it needs this phone's
      // permission - so nothing may still be booked with the OS.
      await ref.read(reminderServiceProvider).cancel();
    }
    if (report != null) ref.invalidate(storageUsedProvider);
    return report;
  }

  /// Removes the whole library - every row and every copy on disk, the
  /// error log and the copies the OS share sheet and picker keep - and
  /// cancels the reminder, whose setting has just gone back to off.
  ///
  /// False if the rows could not be removed, in which case nothing was: the
  /// wipe is one transaction.
  Future<bool> deleteEverything() async {
    final deleted = await ref.read(userDataRepositoryProvider).deleteAll();
    if (deleted.isErr) return false;
    await ref.read(reminderServiceProvider).cancel();
    // A message line in the error log may still hold something the user
    // typed; "all data" includes it.
    await ref.read(errorLogProvider).clear();
    // So do the copies the share sheet and the picker keep of a backup.
    await ref.read(backupFilesProvider).forgetCopies();
    ref.invalidate(storageUsedProvider);
    return true;
  }
}
