/// The URLs the app links out to.
///
/// Built in one place and tested, because a malformed one fails silently: the
/// browser opens on a 404 and the user is left thinking the app is broken.
///
/// `docs/RULES.md` §13 is the reason there is nothing else here for Cambridge.
/// Linking out is the **only** allowed integration — no scraping, no embedded
/// webview of their content, no parsing what comes back.
library;

/// dictionary.cambridge.org, as a link only (F-025).
abstract final class CambridgeDictionary {
  /// Where an entry lives.
  static const String _base =
      'https://dictionary.cambridge.org/dictionary/english';

  /// The page for [normalisedHeadword], or null when there is nothing to look
  /// up.
  ///
  /// Takes the **normalised** headword (`Headword.normalized`): already
  /// trimmed, lowercased and with inner whitespace collapsed. Cambridge slugs
  /// multi-word entries with hyphens — `/english/look-up`, not `/english/look%20up`
  /// — so spaces become hyphens before the segment is percent-encoded.
  ///
  /// Returns null rather than a URL to a blank entry when the headword is
  /// empty, so the caller hides the button instead of offering a dead link.
  static Uri? entryFor(String normalisedHeadword) {
    final slug = normalisedHeadword.trim().replaceAll(RegExp(r'\s+'), '-');
    if (slug.isEmpty) return null;
    return Uri.parse('$_base/${Uri.encodeComponent(slug)}');
  }
}
