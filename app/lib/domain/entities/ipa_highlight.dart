import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';
import 'package:vocabnote/domain/value_objects/storage_enum.dart';

part 'ipa_highlight.freezed.dart';

/// Which transcription a highlight applies to (`ipa_highlights.target`).
enum HighlightTarget implements StorageEnum {
  /// `words.ipa_uk`.
  ipaUk('ipa_uk'),

  /// `words.ipa_us`.
  ipaUs('ipa_us');

  new(this.storageValue);

  /// The exact string written to `ipa_highlights.target`.
  ///
  /// Note the snake_case: it matches the column it points at, and is pinned
  /// independently of the Dart identifier so a rename cannot corrupt data.
  @override
  final String storageValue;

  /// Parses a stored value, or null if this build does not recognise it.
  ///
  /// Null rather than a fallback: a highlight pointing at a transcription we
  /// cannot identify must be skipped, not silently painted onto the wrong one.
  static HighlightTarget? tryFromStorage(String value) {
    for (final target in HighlightTarget.values) {
      if (target.storageValue == value) return target;
    }
    return null;
  }
}

/// A coloured run of IPA symbols with an optional label - the signature
/// feature (F-022).
///
/// The range is measured in **grapheme clusters** over the target
/// transcription, never code units (ADR-006). A range is only meaningful
/// against the exact string it was drawn on, which is why editing the IPA
/// re-validates every highlight (F-023).
@freezed
abstract class IpaHighlight with _$IpaHighlight {
  /// Creates a highlight.
  const factory({
    /// UUID v4.
    required String id,

    /// The word this highlight belongs to. Cascades on delete.
    required String wordId,

    /// Which transcription it marks.
    required HighlightTarget target,

    /// The run of symbols, in grapheme-cluster offsets.
    required GraphemeRange range,

    /// One of the five palette tokens - stored by name, never as a hex value,
    /// so a theme change repaints existing highlights.
    required IpaColorToken color,

    /// When it was created.
    required DateTime createdAt,

    /// The user's note on this run, e.g. "I say /s/ here". Max 40 characters
    /// (`UI-UX.md` §4.4).
    String? label,
  }) = _IpaHighlight;

  const new _();

  /// The longest a label may be.
  static const int maxLabelLength = 40;

  /// Whether this highlight still fits a transcription of [graphemeLength]
  /// clusters.
  ///
  /// Checked both when the IPA changes (F-023) and defensively on read, so one
  /// stale row cannot break the screen that lists it.
  bool fits(int graphemeLength) => range.isValidFor(graphemeLength);

  /// Whether this highlight shares any symbol with [other].
  ///
  /// Overlaps are allowed - the newest wins visually and both show in the
  /// legend (`UI-UX.md` §4.4) - so this is a query, not a guard.
  bool overlaps(IpaHighlight other) =>
      target == other.target && range.overlaps(other.range);
}
