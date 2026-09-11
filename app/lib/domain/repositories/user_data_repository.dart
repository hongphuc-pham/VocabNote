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
}
