import 'package:meta/meta.dart';

/// An IPA transcription, stored without slashes.
///
/// `DATABASE.md` §2: `words.ipa_uk` and `words.ipa_us` hold the bare symbols;
/// the UI adds the enclosing slashes as fixed affixes (`UI-UX.md` §4.2), so the
/// user never types them and a highlight offset never has to account for them.
///
/// Length and slicing are the caller's business, but only ever through
/// `core/extensions/grapheme.dart` (ADR-006) - this class deliberately exposes
/// no `substring`.
@immutable
final class Ipa {
  /// Rebuilds an IPA value from a stored column, which is already clean.
  factory fromStorage(String stored) => Ipa._(stored);
  const new _(this.value);

  /// Creates an IPA string from raw input, stripping any slashes the user
  /// pasted along with it.
  ///
  /// Returns null when nothing is left: an empty IPA field is a normal state,
  /// not an error - "No IPA yet" is one of the filter chips (F-043).
  static Ipa? tryParse(String raw) {
    final cleaned = strip(raw);
    if (cleaned.isEmpty) return null;
    return Ipa._(cleaned);
  }

  /// Removes surrounding whitespace and the `/` or `[` `]` delimiters people
  /// habitually paste from a dictionary.
  ///
  /// Only strips them at the ends: a `/` in the middle of a transcription is
  /// the user's business, not ours to rewrite.
  static String strip(String raw) {
    var text = raw.trim();
    while (text.length > 1 && (text.startsWith('/') || text.startsWith('['))) {
      text = text.substring(1).trim();
    }
    while (text.length > 1 && (text.endsWith('/') || text.endsWith(']'))) {
      text = text.substring(0, text.length - 1).trim();
    }
    // A lone delimiter is not a transcription.
    if (text == '/' || text == '[' || text == ']') return '';
    return text;
  }

  /// The bare transcription, without slashes.
  ///
  /// `strip` uses `substring`, which is safe here and only here: `/`, `[` and
  /// `]` are ASCII and can never be part of a multi-code-unit cluster. Every
  /// other operation on this string must go through the grapheme helpers.
  final String value;

  /// The display form, with the slashes the UI shows around it.
  String get display => '/$value/';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ipa && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => display;
}
