import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';

void main() {
  group('construction', () {
    test('accepts a well-formed range', () {
      final range = GraphemeRange(2, 5);
      expect(range.start, 2);
      expect(range.end, 5);
      expect(range.length, 3);
    });

    test('rejects a negative start', () {
      expect(() => GraphemeRange(-1, 2), throwsArgumentError);
    });

    test('rejects an empty or reversed range', () {
      expect(() => GraphemeRange(3, 3), throwsArgumentError);
      expect(() => GraphemeRange(4, 2), throwsArgumentError);
    });
  });

  group('tryCreate', () {
    test('returns a range for valid values', () {
      expect(GraphemeRange.tryCreate(0, 1), GraphemeRange(0, 1));
    });

    test('returns null instead of throwing for a bad row', () {
      // Read defensively: one corrupt row must not take down the screen that
      // lists it (F-023 validates on read as well as on write).
      expect(GraphemeRange.tryCreate(-1, 3), isNull);
      expect(GraphemeRange.tryCreate(5, 5), isNull);
      expect(GraphemeRange.tryCreate(9, 4), isNull);
    });
  });

  group('isValidFor', () {
    test('accepts a range that fits', () {
      expect(GraphemeRange(0, 7).isValidFor(7), isTrue);
      expect(GraphemeRange(5, 6).isValidFor(7), isTrue);
    });

    test('rejects a range that runs past the end', () {
      expect(GraphemeRange(5, 8).isValidFor(7), isFalse);
    });
  });

  group('contains', () {
    test('is inclusive of start and exclusive of end', () {
      final range = GraphemeRange(2, 5);
      expect(range.contains(1), isFalse);
      expect(range.contains(2), isTrue);
      expect(range.contains(4), isTrue);
      expect(range.contains(5), isFalse);
    });
  });

  group('overlaps', () {
    test('detects a shared symbol', () {
      // Overlapping highlights are allowed (UI-UX.md section 4.4), so this is
      // a query rather than a guard.
      expect(GraphemeRange(0, 3).overlaps(GraphemeRange(2, 5)), isTrue);
      expect(GraphemeRange(2, 5).overlaps(GraphemeRange(0, 3)), isTrue);
    });

    test('adjacent ranges do not overlap', () {
      expect(GraphemeRange(0, 3).overlaps(GraphemeRange(3, 5)), isFalse);
    });

    test('a range overlaps itself', () {
      final range = GraphemeRange(1, 4);
      expect(range.overlaps(range), isTrue);
    });

    test('a fully contained range overlaps', () {
      expect(GraphemeRange(0, 9).overlaps(GraphemeRange(3, 4)), isTrue);
    });
  });

  group('clampTo', () {
    test('leaves a fitting range alone', () {
      expect(GraphemeRange(1, 4).clampTo(7), GraphemeRange(1, 4));
    });

    test('trims a range that overruns', () {
      expect(GraphemeRange(4, 12).clampTo(7), GraphemeRange(4, 7));
    });

    test('returns null when nothing survives', () {
      expect(GraphemeRange(8, 12).clampTo(7), isNull);
      expect(GraphemeRange(7, 9).clampTo(7), isNull);
    });
  });

  group('value semantics', () {
    test('equal ranges are equal and hash alike', () {
      expect(GraphemeRange(1, 4), GraphemeRange(1, 4));
      expect(GraphemeRange(1, 4).hashCode, GraphemeRange(1, 4).hashCode);
    });

    test('different ranges are not equal', () {
      expect(GraphemeRange(1, 4), isNot(GraphemeRange(1, 5)));
    });

    test('sorts by start, then by end', () {
      final ranges = <GraphemeRange>[
        GraphemeRange(3, 9),
        GraphemeRange(0, 5),
        GraphemeRange(3, 4),
      ]..sort();
      expect(ranges, <GraphemeRange>[
        GraphemeRange(0, 5),
        GraphemeRange(3, 4),
        GraphemeRange(3, 9),
      ]);
    });
  });
}
