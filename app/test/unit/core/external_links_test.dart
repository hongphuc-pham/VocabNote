import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/utils/external_links.dart';

/// The Cambridge link (F-025).
///
/// The only integration `docs/RULES.md` §13 allows is linking out, so this URL
/// is the entire feature — and a malformed one fails quietly, opening the
/// browser on a 404 while the user concludes the app is broken.
void main() {
  group('entry URLs', () {
    test('builds the documented path for a simple word', () {
      expect(
        CambridgeDictionary.entryFor('cough').toString(),
        'https://dictionary.cambridge.org/dictionary/english/cough',
      );
    });

    test('slugs a multi-word entry with hyphens, as Cambridge does', () {
      expect(
        CambridgeDictionary.entryFor('look up').toString(),
        'https://dictionary.cambridge.org/dictionary/english/look-up',
      );
    });

    test('collapses runs of whitespace into one hyphen', () {
      expect(
        CambridgeDictionary.entryFor('look   up').toString(),
        endsWith('/look-up'),
      );
    });

    test('percent-encodes anything that would break the path', () {
      // A word with an apostrophe or an accent must not corrupt the URL.
      final url = CambridgeDictionary.entryFor('café')!;
      expect(url.toString(), startsWith('https://dictionary.cambridge.org/'));
      expect(url.pathSegments.last, 'café');
    });

    test('returns null for a blank headword rather than a dead link', () {
      expect(CambridgeDictionary.entryFor(''), isNull);
      expect(CambridgeDictionary.entryFor('   '), isNull);
    });

    test('is always https', () {
      expect(CambridgeDictionary.entryFor('cough')!.scheme, 'https');
    });
  });
}
