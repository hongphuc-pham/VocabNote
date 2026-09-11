import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/backup.dart';

/// What the share sheet reported.
enum ShareOutcome {
  /// The user picked somewhere to send it.
  shared,

  /// The sheet was closed without choosing.
  dismissed,

  /// The platform cannot say what happened.
  unknown,
}

/// Where the share sheet should point from.
///
/// An iPad draws it as a popover anchored to the button that opened it, and
/// refuses to draw it at all without one. Plain numbers rather than a `Rect`,
/// because `domain/` may not import Flutter.
@immutable
class ShareAnchor {
  /// Creates an anchor from the button's position on screen.
  const new({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// Distance from the left of the screen, in logical pixels.
  final double left;

  /// Distance from the top of the screen, in logical pixels.
  final double top;

  /// The button's width.
  final double width;

  /// The button's height.
  final double height;
}

/// The device's own ways of moving a file: the OS share sheet, and (for
/// import) the file picker.
///
/// Behind an interface like `SpeechService`, so nothing above `data/` names a
/// plugin and a test can record what would have been asked of the OS.
abstract interface class BackupFiles {
  /// Offers [backup] to the OS share sheet.
  AsyncResult<ShareOutcome> share(ExportedBackup backup, {ShareAnchor? anchor});

  /// Lets the user choose a backup file, and reads it.
  ///
  /// Null when the picker is closed without choosing. A file too large to be
  /// a backup fails as `InvalidBackupFailure(tooLarge)`, refused on its size
  /// before any of it is read.
  AsyncResult<Uint8List?> pick();
}
