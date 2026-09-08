import 'package:meta/meta.dart';

/// The word the user is studying, and its normalised form.
///
/// `words.headword` keeps exactly what the user typed;
/// `words.headword_normalized` is what dedupe (F-001) and search (F-041) match
/// on. Both are derived here, in one place, so the two can never disagree.
@immutable
final class Headword {
  /// Creates a headword from raw user input.
  ///
  /// Throws [ArgumentError] when nothing is left after trimming - the headword
  /// is the one required field on the form (F-001). Use [tryParse] where empty
  /// input is an expected state, such as a form that has not been filled in.
  factory(String raw) {
    final headword = tryParse(raw);
    if (headword == null) {
      throw ArgumentError.value(raw, 'raw', 'headword cannot be empty');
    }
    return headword;
  }

  /// Rebuilds a headword from the two columns as stored.
  ///
  /// Does not re-derive [normalized]: a row written by an older build must keep
  /// the normalisation it was saved with, or dedupe would silently change
  /// meaning under the user after an upgrade.
  factory fromStorage({required String headword, required String normalized}) =>
      Headword._(headword, normalized);
  const new _(this.value, this.normalized);

  /// Creates a headword, or null when [raw] is blank.
  static Headword? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return Headword._(trimmed, normalize(trimmed));
  }

  /// The normalisation rule: trimmed, lowercased, inner whitespace collapsed.
  ///
  /// Deliberately conservative. It does not strip accents or punctuation,
  /// because "resume" and "résumé" are different words to someone studying
  /// pronunciation, and folding them would merge two entries the user meant to
  /// keep apart.
  ///
  /// **Changing this rule is a data migration**, not a refactor: existing rows
  /// would need backfilling or dedupe would behave differently for old and new
  /// words.
  static String normalize(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// As the user typed it, trimmed.
  final String value;

  /// The lowercased, whitespace-collapsed form used for dedupe and search.
  final String normalized;

  /// Whether this is the same word as [other], ignoring how it was typed.
  bool matches(Headword other) => normalized == other.normalized;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Headword &&
          other.value == value &&
          other.normalized == normalized);

  @override
  int get hashCode => Object.hash(value, normalized);

  @override
  String toString() => value;
}
