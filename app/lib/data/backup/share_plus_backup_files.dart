import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';

/// [BackupFiles] over the OS share sheet (`share_plus`, RULES §4 ledger).
class SharePlusBackupFiles implements BackupFiles {
  /// Creates the adapter. Inert until the first call.
  const new();

  /// A `.vnb` is a ZIP. Naming it so lets mail and cloud apps accept it,
  /// where an unknown type is refused by some.
  static const String _mimeType = 'application/zip';

  @override
  AsyncResult<ShareOutcome> share(
    ExportedBackup backup, {
    ShareAnchor? anchor,
  }) => Results.guard(
    () async {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile(backup.path, mimeType: _mimeType, name: backup.fileName),
          ],
          // Without this some targets receive a generated name.
          fileNameOverrides: <String>[backup.fileName],
          sharePositionOrigin: switch (anchor) {
            final ShareAnchor a => Rect.fromLTWH(
              a.left,
              a.top,
              a.width,
              a.height,
            ),
            null => null,
          },
        ),
      );
      return switch (result.status) {
        ShareResultStatus.success => ShareOutcome.shared,
        ShareResultStatus.dismissed => ShareOutcome.dismissed,
        ShareResultStatus.unavailable => ShareOutcome.unknown,
      };
    },
    onError: (error, stackTrace) => UnavailableFailure(
      capability: 'share sheet',
      cause: error,
      stackTrace: stackTrace,
    ),
  );
}
