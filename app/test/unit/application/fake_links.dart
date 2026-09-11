import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/diagnostics.dart';
import 'package:vocabnote/domain/repositories/diagnostics_source.dart';
import 'package:vocabnote/domain/repositories/link_opener.dart';

/// Records what would have been opened instead of opening it.
class FakeLinkOpener implements LinkOpener {
  /// Every link asked for, in order.
  final List<Uri> opened = <Uri>[];

  /// Whether something could open the link - false is a phone with no mail
  /// app.
  bool succeed = true;

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return succeed;
  }
}

/// The three facts a feedback email carries, fixed for tests.
class FakeDiagnostics implements DiagnosticsSource {
  /// What is reported.
  static const Diagnostics facts = Diagnostics(
    appVersion: '1.2.3 (45)',
    osVersion: 'Android 17',
    deviceModel: 'Google Pixel 9 Pro',
  );

  @override
  AsyncResult<Diagnostics> read() async =>
      const Ok<Diagnostics, AppFailure>(facts);
}
