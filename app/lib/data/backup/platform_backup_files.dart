import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';

/// [BackupFiles] over the OS share sheet (`share_plus`) and file picker
/// (`file_picker`) - RULES §4 ledger.
class PlatformBackupFiles implements BackupFiles {
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

  @override
  AsyncResult<Uint8List?> pick() async {
    try {
      // Any file: Android cannot filter by an extension it has never heard
      // of, so `.vnb` is checked after choosing - by the codec, which names a
      // wrong file as "not a backup" rather than showing an empty picker.
      //
      // On Android the plugin copies the chosen `content://` document into
      // the app's cache and hands back a path, so reading it is a plain file
      // read.
      final file = await FilePicker.pickFile();
      if (file == null) return const Ok<Uint8List?, AppFailure>(null);
      try {
        if (await file.length() > BackupCodec.defaultMaxArchiveBytes) {
          return const Err<Uint8List?, AppFailure>(
            InvalidBackupFailure(problem: BackupProblem.tooLarge),
          );
        }
        return Ok<Uint8List?, AppFailure>(await file.readAsBytes());
      } finally {
        // Read or refused, the copy has served its purpose - and it is a
        // copy of the user's words.
        await _quietly(FilePicker.clearTemporaryFiles);
      }
    } on Object catch (error, stackTrace) {
      return Err<Uint8List?, AppFailure>(
        FileFailure(
          kind: FileFailureKind.io,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<void> forgetCopies() async {
    // Each on its own: one that fails must not keep the other.
    await _quietly(FilePicker.clearTemporaryFiles);
    await _quietly(() async {
      // share_plus empties this folder only at the next share.
      final shared = Directory(
        p.join((await getTemporaryDirectory()).path, 'share_plus'),
      );
      if (shared.existsSync()) await shared.delete(recursive: true);
    });
  }

  static Future<void> _quietly(Future<void> Function() step) async {
    try {
      await step();
    } on Object {
      // Nothing to clear, or a platform that keeps no such copy.
    }
  }
}
