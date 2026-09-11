import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/utils/bundled_licences.dart';

/// The fonts' licence texts reach Flutter's licence page (F-075).
///
/// The SIL Open Font License asks that its text travel with the fonts
/// (`docs/DATA-SOURCES.md` §5). `showLicensePage` only knows about packages,
/// so the two bundled `OFL.txt` files are registered by hand - and a missing
/// asset path would fail silently, which is what this guards.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(LicenseRegistry.reset);
  tearDown(LicenseRegistry.reset);

  test('both font licences are registered, with their full text', () async {
    BundledLicences.register();

    final entries = await LicenseRegistry.licenses.toList();
    String textOf(String package) => entries
        .where((entry) => entry.packages.contains(package))
        .expand((entry) => entry.paragraphs)
        .map((paragraph) => paragraph.text)
        .join('\n');

    for (final font in <String>['Inter', 'Charis SIL']) {
      expect(textOf(font), contains('Open Font License'), reason: font);
    }
  });
}
