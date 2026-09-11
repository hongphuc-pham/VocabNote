import 'dart:typed_data';

import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';

/// Records what would have been asked of the OS share sheet and file picker.
///
/// A test can open neither, and what matters is what the app asked for and
/// how it reacted to each answer they can give.
class FakeBackupFiles implements BackupFiles {
  /// Every backup offered to the share sheet, in order.
  final List<ExportedBackup> shared = <ExportedBackup>[];

  /// What the share sheet reports back.
  ShareOutcome outcome = ShareOutcome.shared;

  /// Makes the share sheet fail to open.
  bool fail = false;

  /// What the picker hands back: the chosen file's bytes, or null for a
  /// picker closed without choosing.
  Uint8List? picked;

  /// Makes the picker fail with this instead.
  AppFailure? pickFailure;

  /// How many times the picker was opened.
  int picks = 0;

  /// How many times the share sheet's and picker's copies were cleared.
  int forgets = 0;

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

  @override
  AsyncResult<Uint8List?> pick() async {
    picks++;
    final failure = pickFailure;
    if (failure != null) return Err<Uint8List?, AppFailure>(failure);
    return Ok<Uint8List?, AppFailure>(picked);
  }

  @override
  Future<void> forgetCopies() async => forgets++;
}
