import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/extensions/grapheme.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';

/// Grapheme-safety tests for IPA strings (ADR-006, `docs/RULES.md` section 21).
///
/// These guard the signature feature. A highlight is stored as a pair of
/// grapheme offsets; if the offsets ever drift onto code units, the user's
/// carefully placed colour lands on half a symbol, and the diacritic that
/// carries the meaning gets orphaned.
void main() {
  // church - the worked example from the docs. Every symbol here is its own
  // cluster, including the stress mark and the length mark.
  const church = 'ˈtʃɜːtʃ';

  // international - a longer string with two stress marks.
  const international = 'ˌɪntəˈneɪʃənəl';

  // A tie bar (U+0361) binds t to the following symbol. It is a combining
  // mark, so it forms one cluster with the t it follows.
  const tieBarred = 't͡ʃ';

  // Escapes, not literals: a precomposed 'o with tilde' (U+00F5) looks
  // identical in an editor but is a single code point, so it would prove
  // nothing. Spelled out: b + ring below (voiceless), o + tilde above
  // (nasalised), n - five code units, three symbols.
  const withDiacritics = 'b\u0325o\u0303n';

  group('graphemeLength', () {
    test('counts the seven symbols of /ˈtʃɜːtʃ/', () {
      expect(church.graphemeLength, 7);
    });

    test('counts the fourteen symbols of /ˌɪntəˈneɪʃənəl/', () {
      expect(international.graphemeLength, 14);
    });

    test('treats a tie-barred t as one cluster, unlike String.length', () {
      expect(tieBarred.length, 3, reason: 'three UTF-16 code units');
      expect(tieBarred.graphemeLength, 2, reason: 'the tie bar joins the t');
    });

    test('folds combining diacritics into the symbol they modify', () {
      // b + ring, o + tilde, n  ->  three clusters from five code units.
      expect(withDiacritics.length, 5);
      expect(withDiacritics.graphemeLength, 3);
    });

    test('is zero for the empty string', () {
      expect(''.graphemeLength, 0);
    });
  });

  group('graphemeAt', () {
    test('returns each symbol of /ˈtʃɜːtʃ/ in order', () {
      expect(
        <String>[
          for (var i = 0; i < church.graphemeLength; i++) church.graphemeAt(i),
        ],
        <String>['ˈ', 't', 'ʃ', 'ɜ', 'ː', 't', 'ʃ'],
      );
    });

    test('keeps a combining mark attached to its base', () {
      expect(tieBarred.graphemeAt(0), 't͡');
      expect(tieBarred.graphemeAt(1), 'ʃ');
      // The corruption this exists to prevent: index 0 by code unit gives a
      // bare t and strands the tie bar.
      expect(tieBarred[0], isNot(tieBarred.graphemeAt(0)));
    });

    test('never returns a bare combining mark', () {
      for (var i = 0; i < withDiacritics.graphemeLength; i++) {
        final cluster = withDiacritics.graphemeAt(i);
        expect(
          cluster.runes.first,
          isNot(anyOf(0x0325, 0x0303)),
          reason: 'cluster $i starts with an orphaned diacritic',
        );
      }
    });

    test('throws for an index outside the string', () {
      expect(() => church.graphemeAt(7), throwsRangeError);
      expect(() => church.graphemeAt(-1), throwsRangeError);
    });
  });

  group('graphemeSubstring', () {
    test('slices /ˈtʃɜːtʃ/ on symbol boundaries', () {
      expect(church.graphemeSubstring(1, 3), 'tʃ');
      expect(church.graphemeSubstring(3, 5), 'ɜː');
      expect(church.graphemeSubstring(5), 'tʃ');
      expect(church.graphemeSubstring(0), church);
    });

    test('slices the long string correctly', () {
      expect(international.graphemeSubstring(0, 1), 'ˌ');
      expect(international.graphemeSubstring(5, 6), 'ˈ');
      expect(international.graphemeSubstring(9, 10), 'ʃ');
    });

    test('carries the tie bar with its base symbol', () {
      expect(tieBarred.graphemeSubstring(0, 1), 't͡');
      // Naive slicing would return a lone 't' and drop the bar.
      expect(tieBarred.substring(0, 1), 't');
    });

    test('carries diacritics with their base symbols', () {
      expect(withDiacritics.graphemeSubstring(0, 1), 'b\u0325');
      expect(withDiacritics.graphemeSubstring(1, 2), 'o\u0303');
      expect(withDiacritics.graphemeSubstring(2, 3), 'n');
    });

    test('returns empty for a zero-width span', () {
      expect(church.graphemeSubstring(2, 2), '');
    });

    test('every slice reassembles into the original', () {
      for (var i = 0; i <= church.graphemeLength; i++) {
        expect(
          church.graphemeSubstring(0, i) + church.graphemeSubstring(i),
          church,
          reason: 'split at $i lost or duplicated data',
        );
      }
    });

    test('throws for a span outside the string', () {
      expect(() => church.graphemeSubstring(0, 8), throwsRangeError);
      expect(() => church.graphemeSubstring(-1), throwsRangeError);
      expect(() => church.graphemeSubstring(4, 2), throwsRangeError);
    });
  });

  group('graphemeClusters', () {
    test('enumerates /ˌɪntəˈneɪʃənəl/ symbol by symbol', () {
      expect(international.graphemeClusters, <String>[
        'ˌ',
        'ɪ',
        'n',
        't',
        'ə',
        'ˈ',
        'n',
        'e',
        'ɪ',
        'ʃ',
        'ə',
        'n',
        'ə',
        'l',
      ]);
    });

    test('rejoins into the original string', () {
      expect(withDiacritics.graphemeClusters.join(), withDiacritics);
    });
  });

  group('graphemeRanges', () {
    test('yields one single-symbol range per cluster', () {
      final ranges = church.graphemeRanges;
      expect(ranges, hasLength(7));
      expect(ranges.first, GraphemeRange(0, 1));
      expect(ranges.last, GraphemeRange(6, 7));
      expect(ranges.every((r) => r.length == 1), isTrue);
    });

    test('each range selects exactly its own symbol', () {
      for (final (index, range) in tieBarred.graphemeRanges.indexed) {
        expect(tieBarred.graphemeSlice(range), tieBarred.graphemeAt(index));
      }
    });

    test('is empty for the empty string', () {
      expect(''.graphemeRanges, isEmpty);
    });
  });

  group('isValidGraphemeRange', () {
    test('accepts a range inside the string', () {
      expect(church.isValidGraphemeRange(GraphemeRange(1, 3)), isTrue);
      expect(church.isValidGraphemeRange(GraphemeRange(0, 7)), isTrue);
    });

    test('rejects a range that runs past the end', () {
      // The F-023 case: the user shortened the IPA and this highlight no
      // longer fits.
      expect(church.isValidGraphemeRange(GraphemeRange(5, 9)), isFalse);
    });
  });

  group('splitAroundGraphemes', () {
    test('splits /ˈtʃɜːtʃ/ around the vowel', () {
      final (before, inside, after) = church.splitAroundGraphemes(
        GraphemeRange(3, 5),
      );
      expect(before, 'ˈtʃ');
      expect(inside, 'ɜː');
      expect(after, 'tʃ');
      expect(before + inside + after, church);
    });

    test('handles a range at the very start', () {
      final (before, inside, after) = church.splitAroundGraphemes(
        GraphemeRange(0, 1),
      );
      expect(before, '');
      expect(inside, 'ˈ');
      expect(after, 'tʃɜːtʃ');
    });

    test('clamps a range that no longer fits rather than throwing', () {
      final (before, inside, after) = church.splitAroundGraphemes(
        GraphemeRange(5, 20),
      );
      expect(before, 'ˈtʃɜː');
      expect(inside, 'tʃ');
      expect(after, '');
    });

    test('returns the whole string when the range starts past the end', () {
      final (before, inside, after) = church.splitAroundGraphemes(
        GraphemeRange(9, 12),
      );
      expect(before, church);
      expect(inside, '');
      expect(after, '');
    });

    test('never splits a combining mark from its base', () {
      final (before, inside, after) = withDiacritics.splitAroundGraphemes(
        GraphemeRange(1, 2),
      );
      expect(before, 'b\u0325');
      expect(inside, 'o\u0303');
      expect(after, 'n');
      expect(before + inside + after, withDiacritics);
    });
  });
}
