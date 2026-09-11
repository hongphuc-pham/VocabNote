import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/diagnostics.dart';

/// Where the feedback email's three facts come from (F-072).
///
/// Behind an interface so nothing above `data/` names `package_info_plus` or
/// `device_info_plus`, and so a test can fix what they say.
abstract interface class DiagnosticsSource {
  /// Reads the app version, OS version and device model.
  AsyncResult<Diagnostics> read();
}
