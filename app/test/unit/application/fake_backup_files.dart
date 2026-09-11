import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';

/// Records what would have been handed to the OS share sheet.
///
/// A test cannot open a share sheet, and what matters is what the app asked
/// it to share and how it reacted to each answer the sheet can give.
class FakeBackupFiles implements BackupFiles {
  /// Every backup offered to the share sheet, in order.
  final List<ExportedBackup> shared = <ExportedBackup>[];

  /// What the share sheet reports back.
  ShareOutcome outcome = ShareOutcome.shared;

  /// Makes the share sheet fail to open.
  bool fail = false;

  @override
  AsyncResult<ShareOutcome> share(
    ExportedBackup backup, {
    ShareAnchor? anchor,
  }) async {
    if (fail) {
      return const Err<ShareOutcome, AppFailure>(
        UnavailableFailure(capability: 'share sheet'),
      );
    }
    shared.add(backup);
    return Ok<ShareOutcome, AppFailure>(outcome);
  }
}
