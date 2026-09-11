import 'dart:typed_data';

import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/backup.dart';

/// The user's whole library, as one thing: backing it up, bringing a backup
/// in, and removing it all (F-073, F-074, `docs/UI-UX.md` §4.9).
///
/// There is no server. A backup file is how a user moves to a new phone, so
/// this is the only way their words leave the device (P1).
abstract interface class UserDataRepository {
  /// Writes every table to a new `.vnb` file and says where it is.
  ///
  /// Nothing is shared or uploaded here; the file is handed on separately,
  /// and only when the user asks.
  AsyncResult<ExportedBackup> exportBackup();

  /// Reads what a backup file holds, without writing anything.
  ///
  /// Fails with an `InvalidBackupFailure` for anything that is not a usable
  /// backup, so the user hears about it before being asked to choose.
  AsyncResult<BackupManifest> previewBackup(Uint8List bytes);

  /// Brings a backup in, all at once or not at all.
  ///
  /// [ImportMode.replace] takes a safety copy of what is here first, and does
  /// nothing if that copy cannot be written.
  AsyncResult<ImportReport> importBackup(Uint8List bytes, ImportMode mode);

  /// Removes the whole library: every row, and every copy of it on disk -
  /// safety copies, exports, the copies taken before an upgrade, the
  /// dictionary cache. Settings return to their defaults.
  ///
  /// The install keeps its local id and its finished onboarding: those
  /// describe the install, not the user's words.
  AsyncResult<void> deleteAll();

  /// How many bytes the library takes on this phone, copies included.
  AsyncResult<int> storageUsed();
}
