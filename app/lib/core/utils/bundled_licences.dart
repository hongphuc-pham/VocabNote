/// The licence texts that ship with VocabNote's own assets (F-075).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The fonts' SIL Open Font License texts.
///
/// OFL 1.1 asks that its text travel with the fonts
/// (`docs/DATA-SOURCES.md` §5). `showLicensePage` only knows about packages,
/// so these are added to it by hand, and shown on *Data sources & licences*.
abstract final class BundledLicences {
  /// Inter's licence, as bundled.
  static const String interPath = 'assets/fonts/inter/OFL.txt';

  /// Charis SIL's licence, as bundled.
  static const String charisPath = 'assets/fonts/charis_sil/OFL.txt';

  /// Adds both font licences to Flutter's licence page.
  ///
  /// Lazy: nothing is read until the page asks, so calling this at start-up
  /// costs nothing on the cold-start budget (F-092).
  static void register() {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(const <String>[
        'Inter',
      ], await rootBundle.loadString(interPath));
      yield LicenseEntryWithLineBreaks(const <String>[
        'Charis SIL',
      ], await rootBundle.loadString(charisPath));
    });
  }
}
