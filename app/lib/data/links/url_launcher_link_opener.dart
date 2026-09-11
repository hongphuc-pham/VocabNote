import 'package:url_launcher/url_launcher.dart';
import 'package:vocabnote/domain/repositories/link_opener.dart';

/// [LinkOpener] over `url_launcher` (RULES §4 ledger).
///
/// Launches and reports the result, rather than asking `canLaunchUrl` first:
/// that can say no where launching would work (`docs/DATA-SOURCES.md` §4).
/// The `SENDTO mailto` and `VIEW https` package-visibility queries are
/// already in the Android manifest.
class UrlLauncherLinkOpener implements LinkOpener {
  /// Creates the opener.
  const new();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
