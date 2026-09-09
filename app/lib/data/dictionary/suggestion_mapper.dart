/// Turning an API response into the per-field chips the form offers (F-004).
library;

import 'package:vocabnote/data/dictionary/dto/dictionary_dto.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';

/// Tags Wiktionary uses to mark a British pronunciation.
///
/// There is no accent field in the response; the accent is carried in
/// `pronunciations[].tags`, so it has to be recognised by name.
const Set<String> _ukTags = <String>{
  'received pronunciation',
  'rp',
  'british',
  'uk',
  'general british',
  'england',
};

/// Tags Wiktionary uses to mark an American pronunciation.
const Set<String> _usTags = <String>{
  'general american',
  'genam',
  'ga',
  'us',
  'american',
  'north america',
};

/// How many suggestions to offer per field.
///
/// `cough` alone returns seven pronunciations. Offering all of them turns a
/// helpful card into a wall of near-identical chips, so each field shows the
/// few most likely to be useful and the user types anything else themselves.
const int _maxPerField = 3;

/// Builds the suggestion set for a look-up response.
///
/// Returns an empty set - never null - when there is nothing usable, so the
/// caller shows "no results" rather than branching on null.
WordSuggestions mapResponseToSuggestions(
  DictionaryResponseDto response, {
  required String headword,
}) {
  final english = response.entries
      .where(
        (entry) => entry.language?.code == null || entry.language?.code == 'en',
      )
      .toList();

  final suggestions = <FieldSuggestion>[
    ..._ipaSuggestions(english, _ukTags, SuggestionField.ipaUk),
    ..._ipaSuggestions(english, _usTags, SuggestionField.ipaUs),
    ..._partsOfSpeech(english),
    ..._definitions(english),
    ..._examples(english),
  ];

  final license = response.source?.license;

  return WordSuggestions(
    headword: headword,
    source: WordSource.api,
    suggestions: suggestions,
    // Attribution is attached whenever there is anything to attribute. CC
    // BY-SA 4.0 is owed on the text, not on our having asked for it.
    attribution: suggestions.isEmpty
        ? null
        : WordSuggestions.wiktionaryAttribution,
    sourceUrl: response.source?.url,
    licenseName: license?.name,
    licenseUrl: license?.url,
  );
}

/// Pronunciations matching [tags], most specific first.
///
/// An untagged pronunciation is offered only for the US field, and only when
/// nothing is explicitly tagged: Wiktionary's untagged transcriptions skew
/// American, and offering one as "UK" would be a guess presented as fact.
List<FieldSuggestion> _ipaSuggestions(
  List<DictionaryEntryDto> entries,
  Set<String> tags,
  SuggestionField field,
) {
  final tagged = <FieldSuggestion>[];
  final untagged = <FieldSuggestion>[];

  for (final entry in entries) {
    for (final pronunciation in entry.pronunciations) {
      if (pronunciation.type != null && pronunciation.type != 'ipa') continue;

      final ipa = Ipa.tryParse(pronunciation.text ?? '');
      if (ipa == null) continue;

      final lowered = pronunciation.tags
          .map((t) => t.toLowerCase().trim())
          .toSet();
      final matches = lowered.any(tags.contains);

      final suggestion = FieldSuggestion(
        field: field,
        value: ipa.value,
        source: WordSource.api,
        hint: pronunciation.tags.isEmpty ? null : pronunciation.tags.first,
      );

      if (matches) {
        tagged.add(suggestion);
      } else if (lowered.isEmpty && field == SuggestionField.ipaUs) {
        untagged.add(suggestion);
      }
    }
  }

  final chosen = tagged.isNotEmpty ? tagged : untagged;
  return _dedupe(chosen).take(_maxPerField).toList();
}

List<FieldSuggestion> _partsOfSpeech(List<DictionaryEntryDto> entries) {
  return _dedupe(<FieldSuggestion>[
    for (final entry in entries)
      if ((entry.partOfSpeech ?? '').trim().isNotEmpty)
        FieldSuggestion(
          field: SuggestionField.partOfSpeech,
          value: entry.partOfSpeech!.trim(),
          source: WordSource.api,
        ),
  ]).take(_maxPerField).toList();
}

List<FieldSuggestion> _definitions(List<DictionaryEntryDto> entries) {
  return _dedupe(<FieldSuggestion>[
    for (final entry in entries)
      for (final sense in entry.senses)
        if ((sense.definition ?? '').trim().isNotEmpty)
          FieldSuggestion(
            field: SuggestionField.definition,
            value: sense.definition!.trim(),
            source: WordSource.api,
            hint: entry.partOfSpeech,
          ),
  ]).take(_maxPerField).toList();
}

List<FieldSuggestion> _examples(List<DictionaryEntryDto> entries) {
  return _dedupe(<FieldSuggestion>[
    for (final entry in entries)
      for (final sense in entry.senses)
        for (final example in sense.examples)
          if (example.trim().isNotEmpty)
            FieldSuggestion(
              field: SuggestionField.example,
              value: example.trim(),
              source: WordSource.api,
              hint: entry.partOfSpeech,
            ),
  ]).take(_maxPerField).toList();
}

/// Removes repeats by value, keeping the first - which is the most specific,
/// because tagged pronunciations are collected before untagged ones.
List<FieldSuggestion> _dedupe(List<FieldSuggestion> suggestions) {
  final seen = <String>{};
  return <FieldSuggestion>[
    for (final suggestion in suggestions)
      if (seen.add(suggestion.value.toLowerCase())) suggestion,
  ];
}
