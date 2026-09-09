import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vocabnote/domain/entities/word.dart';

part 'word_suggestion.freezed.dart';

/// Which field a suggestion can fill (F-004).
///
/// Look-up results are offered **per field**, never as a whole-form fill:
/// tapping a chip fills that one field and nothing else, so the user keeps
/// whatever they had already typed elsewhere.
enum SuggestionField {
  /// `words.ipa_uk`.
  ipaUk,

  /// `words.ipa_us`.
  ipaUs,

  /// `words.part_of_speech`.
  partOfSpeech,

  /// `words.definition`.
  definition,

  /// `words.example`.
  example,
}

/// One offered value for one field.
@freezed
abstract class FieldSuggestion with _$FieldSuggestion {
  /// Creates a suggestion.
  const factory({
    /// Which field this fills.
    required SuggestionField field,

    /// The value that would be written.
    required String value,

    /// Where it came from - decides whether attribution is owed.
    required WordSource source,

    /// A short note shown on the chip, e.g. the accent tag the API gave.
    String? hint,
  }) = _FieldSuggestion;

  const new _();
}

/// Everything a look-up found for one word.
///
/// Carries the attribution alongside the values, because CC BY-SA 4.0 is owed
/// per accepted field (`docs/RULES.md` §16) - a user who takes the IPA but
/// writes their own definition owes a credit for the IPA only.
@freezed
abstract class WordSuggestions with _$WordSuggestions {
  /// Creates a suggestion set.
  const factory({
    /// The word that was looked up, as the user typed it.
    required String headword,

    /// Where these came from.
    required WordSource source,

    /// The per-field chips, in the order they should be offered.
    @Default(<FieldSuggestion>[]) List<FieldSuggestion> suggestions,

    /// The credit line stored on any field the user accepts.
    ///
    /// Null for [WordSource.manual], because the user's own writing is theirs
    /// and owes nobody a credit.
    String? attribution,

    /// The source page, linked from the results card as *View source*.
    String? sourceUrl,

    /// The licence name shown in the results card, e.g. `CC BY-SA 4.0`.
    String? licenseName,

    /// Where the licence text lives.
    String? licenseUrl,
  }) = _WordSuggestions;

  const new _();

  /// The credit line for content taken from Wiktionary via the API.
  ///
  /// Fixed text, matching `docs/DATA-SOURCES.md` §1 word for word.
  static const String wiktionaryAttribution =
      'Wiktionary via FreeDictionaryAPI.com — CC BY-SA 4.0';

  /// The credit line for the bundled CMUdict-derived asset.
  static const String cmudictAttribution = 'CMU Pronouncing Dictionary (CMU)';

  /// Whether there is anything at all to show.
  bool get isEmpty => suggestions.isEmpty;

  /// The suggestions for one field.
  List<FieldSuggestion> forField(SuggestionField field) =>
      suggestions.where((s) => s.field == field).toList();

  /// Whether an attribution line must be displayed with these results.
  bool get requiresAttribution => attribution != null && suggestions.isNotEmpty;
}
