/// Wire types for FreeDictionaryAPI.com (`docs/DATA-SOURCES.md` §1).
///
/// Modelled against real responses, which are checked in under
/// `test/fixtures/dictionary/` so the parser is tested against what the API
/// actually sends rather than what we assumed it sends.
///
/// Every field is optional and every list defaults to empty. A dictionary
/// look-up is a convenience: a response that has changed shape must degrade to
/// "no suggestions" and leave the user typing, never throw into a form they
/// are halfway through filling in.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dictionary_dto.freezed.dart';
part 'dictionary_dto.g.dart';

/// The top-level response: `{word, entries[], source{}}`.
@freezed
abstract class DictionaryResponseDto with _$DictionaryResponseDto {
  /// Creates a response.
  const factory({
    String? word,
    @Default(<DictionaryEntryDto>[]) List<DictionaryEntryDto> entries,
    DictionarySourceDto? source,
  }) = _DictionaryResponseDto;

  /// Parses JSON.
  factory fromJson(Map<String, dynamic> json) =>
      _$DictionaryResponseDtoFromJson(json);
}

/// One entry - roughly one part of speech.
@freezed
abstract class DictionaryEntryDto with _$DictionaryEntryDto {
  /// Creates an entry.
  const factory({
    String? partOfSpeech,
    DictionaryLanguageDto? language,
    @Default(<PronunciationDto>[]) List<PronunciationDto> pronunciations,
    @Default(<SenseDto>[]) List<SenseDto> senses,
  }) = _DictionaryEntryDto;

  /// Parses JSON.
  factory fromJson(Map<String, dynamic> json) =>
      _$DictionaryEntryDtoFromJson(json);
}

/// The language an entry is in. Only `en` is requested, but the field is
/// checked rather than assumed.
@freezed
abstract class DictionaryLanguageDto with _$DictionaryLanguageDto {
  /// Creates a language.
  const factory({String? code, String? name}) = _DictionaryLanguageDto;

  /// Parses JSON.
  factory fromJson(Map<String, dynamic> json) =>
      _$DictionaryLanguageDtoFromJson(json);
}

/// One pronunciation: `{type, text, tags[]}`.
///
/// [text] arrives **with** slashes (`/kɒf/`); they are stripped before storage,
/// because `words.ipa_uk` holds the bare symbols and the UI adds the slashes
/// back as fixed affixes.
///
/// [tags] is how the accent is signalled - `Received Pronunciation` for UK,
/// `General American` for US. There is no dedicated field for it.
@freezed
abstract class PronunciationDto with _$PronunciationDto {
  /// Creates a pronunciation.
  const factory({
    String? type,
    String? text,
    @Default(<String>[]) List<String> tags,
  }) = _PronunciationDto;

  /// Parses JSON.
  factory fromJson(Map<String, dynamic> json) =>
      _$PronunciationDtoFromJson(json);
}

/// One sense: a definition and its examples.
@freezed
abstract class SenseDto with _$SenseDto {
  /// Creates a sense.
  const factory({
    String? definition,
    @Default(<String>[]) List<String> examples,
    @Default(<String>[]) List<String> tags,
  }) = _SenseDto;

  /// Parses JSON.
  factory fromJson(Map<String, dynamic> json) => _$SenseDtoFromJson(json);
}

/// Where the content came from, and under what licence.
///
/// CC BY-SA 4.0 obliges us to link back to the source page and name the
/// licence (`docs/DATA-SOURCES.md` §1), so this is not optional colour - it is
/// the compliance data, stored per word.
@freezed
abstract class DictionarySourceDto with _$DictionarySourceDto {
  /// Creates a source.
  const factory({String? url, DictionaryLicenseDto? license}) =
      _DictionarySourceDto;

  /// Parses JSON.
  factory fromJson(Map<String, dynamic> json) =>
      _$DictionarySourceDtoFromJson(json);
}

/// The licence a response was published under.
@freezed
abstract class DictionaryLicenseDto with _$DictionaryLicenseDto {
  /// Creates a licence.
  const factory({String? name, String? url}) = _DictionaryLicenseDto;

  /// Parses JSON.
  factory fromJson(Map<String, dynamic> json) =>
      _$DictionaryLicenseDtoFromJson(json);
}
