/// A half-open range of grapheme clusters, `[start, end)`.
///
/// This is the unit an IPA highlight is stored in
/// (`ipa_highlights.start_grapheme` / `end_grapheme`, `docs/DATABASE.md` §2).
/// Never code units: `/ˈtʃɜːtʃ/` contains combining marks and multi-codepoint
/// symbols, and slicing it by code unit corrupts them (ADR-006).
///
/// Pure Dart — `domain/` imports nothing but Dart and freezed
/// (`docs/RULES.md` §20).
library;

import 'package:meta/meta.dart';

/// A half-open span of grapheme clusters.
///
/// [start] is inclusive, [end] exclusive, both counted in grapheme clusters
/// over a specific string. A range means nothing without the string it was
/// measured against, which is why [isValidFor] takes the length.
@immutable
final class GraphemeRange implements Comparable<GraphemeRange> {
  /// Creates a range.
  ///
  /// Throws [ArgumentError] if [start] is negative or [end] is not greater than
  /// [start] — an empty or reversed highlight is always a bug, not user data.
  new(this.start, this.end) {
    if (start < 0) {
      throw ArgumentError.value(start, 'start', 'must not be negative');
    }
    if (end <= start) {
      throw ArgumentError.value(end, 'end', 'must be greater than start');
    }
  }

  /// Builds a range from values read out of the database.
  ///
  /// Returns null instead of throwing when the stored pair is nonsense, so one
  /// bad row cannot take down the screen that lists it. `docs/FEATURES.md`
  /// F-023 also requires validating ranges on read.
  static GraphemeRange? tryCreate(int start, int end) {
    if (start < 0 || end <= start) return null;
    return GraphemeRange(start, end);
  }

  /// First grapheme in the range, inclusive.
  final int start;

  /// One past the last grapheme in the range, exclusive.
  final int end;

  /// How many grapheme clusters the range covers. Always at least 1.
  int get length => end - start;

  /// Whether this range fits a string of [graphemeLength] clusters.
  ///
  /// Called after an IPA edit (F-023) to decide which highlights survive.
  bool isValidFor(int graphemeLength) => end <= graphemeLength;

  /// Whether [index] falls inside the range.
  bool contains(int index) => index >= start && index < end;

  /// Whether this range shares at least one grapheme with [other].
  ///
  /// Overlapping highlights are allowed (`docs/UI-UX.md` §4.4), so this is a
  /// query, not a guard.
  bool overlaps(GraphemeRange other) => start < other.end && other.start < end;

  /// This range clipped to a string of [graphemeLength] clusters, or null if
  /// nothing of it survives.
  GraphemeRange? clampTo(int graphemeLength) {
    if (start >= graphemeLength) return null;
    final clampedEnd = end < graphemeLength ? end : graphemeLength;
    if (clampedEnd <= start) return null;
    return GraphemeRange(start, clampedEnd);
  }

  @override
  int compareTo(GraphemeRange other) {
    final byStart = start.compareTo(other.start);
    return byStart != 0 ? byStart : end.compareTo(other.end);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GraphemeRange && other.start == start && other.end == end);

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'GraphemeRange($start, $end)';
}
