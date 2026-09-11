import 'package:meta/meta.dart';

/// The three facts a feedback email carries (F-072) - and nothing else.
///
/// Chosen to help answer "why does this happen for you?" without saying who
/// "you" is: no device name (that is the owner's own label for their phone),
/// no identifier, no account, no location.
@immutable
class Diagnostics {
  /// Creates the facts.
  const new({
    required this.appVersion,
    required this.osVersion,
    required this.deviceModel,
  });

  /// This build, e.g. `1.0.0 (12)`.
  final String appVersion;

  /// The operating system and its version, e.g. `Android 17`.
  final String osVersion;

  /// The kind of phone, e.g. `Google Pixel 9 Pro` - never its name.
  final String deviceModel;
}
