import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';

part 'word_draft.freezed.dart';

/// The add/edit form's state (`docs/UI-UX.md` §4.2).
///
/// Everything the user has typed, plus which fields they accepted from a
/// look-up. Attribution is tracked **per field** because CC BY-SA 4.0 is owed
/// on what was taken, not on the word as a whole: someone who accepts the IPA
/// and writes their own definition owes a credit for the IPA only
/// (`docs/RULES.md` §16).
@freezed
abstract class WordDraft with _$WordDraft {
  /// Creates a draft.
  const factory({
    /// The word being edited, or null when adding a new one.
    String? id,

    /// As typed. Required, trimmed on save.
    @Default('') String headword,

    /// British transcription, without slashes.
    @Default('') String ipaUk,

    /// American transcription, without slashes.
    @Default('') String ipaUs,

    /// Free text.
    @Default('') String partOfSpeech,

    /// What it means.
    @Default('') String definition,

    /// A sentence using it.
    @Default('') String example,

    /// The first note, offered only when adding.
    @Default('') String firstNote,

    /// Which lists it goes into.
    @Default(<String>[]) List<String> listIds,

    /// Starred.
    @Default(false) bool isFavourite,

    /// Which fields were accepted from a look-up, and from where.
    ///
    /// Drives both the attribution stored on the word and the "this came from
    /// the dictionary" affordance in the form.
    @Default(<SuggestionField, WordSource>{})
    Map<SuggestionField, WordSource> acceptedFields,

    /// The credit line for whatever was accepted.
    String? attribution,

    /// The source page, stored alongside the attribution.
    String? sourceUrl,

    /// When the word was first created. Null for a new one.
    DateTime? createdAt,
  }) = _WordDraft;

  const new _();

  /// Builds a draft from an existing word.
  factory fromWord(Word word) => WordDraft(
    id: word.id,
    headword: word.headword.value,
    ipaUk: word.ipaUk?.value ?? '',
    ipaUs: word.ipaUs?.value ?? '',
    partOfSpeech: word.partOfSpeech ?? '',
    definition: word.definition ?? '',
    example: word.example ?? '',
    isFavourite: word.isFavourite,
    attribution: word.sourceAttribution,
    createdAt: word.createdAt,
  );

  /// Whether this is editing an existing word rather than adding one.
  bool get isEditing => id != null;

  /// Whether the form can be saved - the headword is the one required field.
  bool get canSave => Headword.tryParse(headword) != null;

  /// Reads the current value of one field, for the overwrite check.
  String valueOf(SuggestionField field) => switch (field) {
    SuggestionField.ipaUk => ipaUk,
    SuggestionField.ipaUs => ipaUs,
    SuggestionField.partOfSpeech => partOfSpeech,
    SuggestionField.definition => definition,
    SuggestionField.example => example,
  };

  /// Whether accepting a suggestion for [field] would overwrite typed text.
  ///
  /// The check behind F-004's promise that a chip never silently replaces
  /// something the user wrote. Accepting the *same* value is not an overwrite,
  /// and neither is replacing a value that came from a previous suggestion.
  bool wouldOverwrite(SuggestionField field, String value) {
    final current = valueOf(field).trim();
    if (current.isEmpty) return false;
    if (current == value.trim()) return false;
    return !acceptedFields.containsKey(field);
  }

  /// A copy with [field] set to [value].
  WordDraft withField(SuggestionField field, String value) => switch (field) {
    SuggestionField.ipaUk => copyWith(ipaUk: value),
    SuggestionField.ipaUs => copyWith(ipaUs: value),
    SuggestionField.partOfSpeech => copyWith(partOfSpeech: value),
    SuggestionField.definition => copyWith(definition: value),
    SuggestionField.example => copyWith(example: value),
  };

  /// A copy with [suggestion] accepted, recording where it came from.
  WordDraft accept(FieldSuggestion suggestion, WordSuggestions results) {
    return withField(suggestion.field, suggestion.value).copyWith(
      acceptedFields: <SuggestionField, WordSource>{
        ...acceptedFields,
        suggestion.field: suggestion.source,
      },
      // Only recorded once anything has actually been taken.
      attribution: results.attribution ?? attribution,
      sourceUrl: results.sourceUrl ?? sourceUrl,
    );
  }

  /// A copy with any record of [field] having come from a look-up removed.
  ///
  /// Called when the user edits a field by hand: from that moment the text is
  /// theirs, and if it was the only accepted field the attribution goes too.
  WordDraft markManual(SuggestionField field) {
    if (!acceptedFields.containsKey(field)) return this;

    final remaining = <SuggestionField, WordSource>{...acceptedFields}
      ..remove(field);

    return copyWith(
      acceptedFields: remaining,
      attribution: remaining.isEmpty ? null : attribution,
      sourceUrl: remaining.isEmpty ? null : sourceUrl,
    );
  }

  /// The `words.source` value this draft should be saved with.
  ///
  /// `manual` when the user wrote everything, the single source when
  /// everything came from one place, and `mixed` when they combined the two.
  WordSource get resolvedSource {
    if (acceptedFields.isEmpty) return WordSource.manual;

    final sources = acceptedFields.values.toSet();
    final hasTypedContent =
        <String>[
          ipaUk,
          ipaUs,
          partOfSpeech,
          definition,
          example,
        ].where((v) => v.trim().isNotEmpty).length >
        acceptedFields.length;

    if (hasTypedContent || sources.length > 1) return WordSource.mixed;
    return sources.single;
  }

  /// Builds the entity to save.
  ///
  /// [id] and [now] are supplied by the caller so the controller owns identity
  /// and time rather than the form.
  Word toWord({required String id, required DateTime now}) {
    final source = resolvedSource;
    return Word(
      id: this.id ?? id,
      headword: Headword(headword),
      createdAt: createdAt ?? now,
      updatedAt: now,
      partOfSpeech: _nullIfBlank(partOfSpeech),
      ipaUk: Ipa.tryParse(ipaUk),
      ipaUs: Ipa.tryParse(ipaUs),
      definition: _nullIfBlank(definition),
      example: _nullIfBlank(example),
      source: source,
      // The user's own writing owes nobody a credit.
      sourceAttribution: source == WordSource.manual
          ? null
          : _attributionWithSource(),
      isFavourite: isFavourite,
    );
  }

  String? _attributionWithSource() {
    final credit = attribution;
    if (credit == null) return null;
    final url = sourceUrl;
    return url == null ? credit : '$credit — $url';
  }

  static String? _nullIfBlank(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
