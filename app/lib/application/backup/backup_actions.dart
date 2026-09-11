/// Making a backup and handing it over (F-073).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
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

/// When the last backup was handed over, or null if never.
@riverpod
Future<DateTime?> lastBackupAt(Ref ref) async =>
    (await ref.watch(settingsRepositoryProvider).lastBackupAt()).valueOrNull;

/// The backup screen's write side.
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
}
