/// Grapheme-safe string operations.
///
/// **ADR-006 / `docs/RULES.md` §21.** IPA strings are only ever indexed by
/// grapheme cluster. `substring`, `codeUnitAt` and `[i]` on an IPA string are
/// forbidden: `/ˈtʃɜːtʃ/` mixes combining marks with multi-codepoint symbols,
/// and code-unit arithmetic silently splits them — orphaning a tie bar or a
/// diacritic and corrupting the highlight the user carefully placed.
///
/// Every IPA slice in the app goes through this file. It is the only place
/// allowed to call the underlying `characters` API.
library;

import 'package:characters/characters.dart';
import 'package:flutter/cupertino.dart' show TextSpan;
import 'package:flutter/material.dart' show TextSpan;
import 'package:flutter/painting.dart' show TextSpan;
import 'package:flutter/rendering.dart' show TextSpan;
import 'package:flutter/widgets.dart' show TextSpan;
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';

/// Grapheme-cluster operations on a [String].
extension GraphemeText on String {
  /// The number of grapheme clusters — what a reader would call "symbols".
  ///
  /// Differs from [length], which counts UTF-16 code units. For `'t͡ʃ'` this is
  /// 2 (the tie-barred `t͡` and `ʃ`) while [length] is 3.
  int get graphemeLength => characters.length;

  /// The grapheme clusters, in order.
  ///
  /// This is what the highlight editor turns into individually hit-testable
  /// chips (`docs/UI-UX.md` §4.4).
  List<String> get graphemeClusters => characters.toList();

  /// The cluster at [index].
  ///
  /// Throws [RangeError] if [index] is outside `[0, graphemeLength)`.
  String graphemeAt(int index) {
    if (index < 0 || index >= graphemeLength) {
      throw RangeError.index(index, this, 'index', null, graphemeLength);
    }
    return characters.elementAt(index);
  }

  /// The substring spanning clusters `[start, end)`.
  ///
  /// [end] defaults to [graphemeLength]. Mirrors [String.substring]'s contract,
  /// including throwing [RangeError] on an invalid span — callers that expect
  /// user data to be out of date should check [isValidGraphemeRange] first
  /// rather than catching.
  String graphemeSubstring(int start, [int? end]) {
    final total = graphemeLength;
    final stop = end ?? total;
    if (start < 0 || start > total) {
      throw RangeError.range(start, 0, total, 'start');
    }
    if (stop < start || stop > total) {
      throw RangeError.range(stop, start, total, 'end');
    }
    if (start == stop) return '';
    return characters.getRange(start, stop).toString();
  }

  /// The substring covered by [range].
  ///
  /// Throws [RangeError] if the range no longer fits this string. After an IPA
  /// edit, validate with [isValidGraphemeRange] first (F-023).
  String graphemeSlice(GraphemeRange range) =>
      graphemeSubstring(range.start, range.end);

  /// One [GraphemeRange] per cluster, in order.
  ///
  /// The canonical enumeration of a string's symbols: index *i* of the result
  /// is the range that selects cluster *i*. The highlight editor uses it to
  /// build hit targets and to snap a drag to cluster boundaries, so a selection
  /// can never land mid-symbol.
  List<GraphemeRange> get graphemeRanges {
    final total = graphemeLength;
    return <GraphemeRange>[
      for (var i = 0; i < total; i++) GraphemeRange(i, i + 1),
    ];
  }

  /// Whether [range] still fits this string.
  bool isValidGraphemeRange(GraphemeRange range) =>
      range.isValidFor(graphemeLength);

  /// This string cut to at most [maxGraphemes] clusters.
  ///
  /// Grapheme-safe truncation, which a plain `substring` is not: cutting a
  /// label by code unit can split an accented letter from its diacritic or
  /// leave half a surrogate pair, and the result is a broken glyph in the
  /// user's own note. Returns the string unchanged when it already fits.
  String truncateGraphemes(int maxGraphemes) {
    if (maxGraphemes <= 0) return '';
    final clusters = characters;
    if (clusters.length <= maxGraphemes) return this;
    return clusters.take(maxGraphemes).toString();
  }

  /// Splits this string into the clusters covered by [range] and those not.
  ///
  /// Returns `(before, inside, after)`, any of which may be empty. Used to
  /// build the three [TextSpan]s that render one highlight.
  (String before, String inside, String after) splitAroundGraphemes(
    GraphemeRange range,
  ) {
    final total = graphemeLength;
    final clamped = range.clampTo(total);
    if (clamped == null) return (this, '', '');
    return (
      graphemeSubstring(0, clamped.start),
      graphemeSubstring(clamped.start, clamped.end),
      graphemeSubstring(clamped.end, total),
    );
  }
}
