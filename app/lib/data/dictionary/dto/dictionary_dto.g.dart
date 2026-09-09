// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DictionaryResponseDto _$DictionaryResponseDtoFromJson(
  Map<String, dynamic> json,
) => _DictionaryResponseDto(
  word: json['word'] as String?,
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => DictionaryEntryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DictionaryEntryDto>[],
  source: json['source'] == null
      ? null
      : DictionarySourceDto.fromJson(json['source'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DictionaryResponseDtoToJson(
  _DictionaryResponseDto instance,
) => <String, dynamic>{
  'word': instance.word,
  'entries': instance.entries,
  'source': instance.source,
};

_DictionaryEntryDto _$DictionaryEntryDtoFromJson(Map<String, dynamic> json) =>
    _DictionaryEntryDto(
      partOfSpeech: json['partOfSpeech'] as String?,
      language: json['language'] == null
          ? null
          : DictionaryLanguageDto.fromJson(
              json['language'] as Map<String, dynamic>,
            ),
      pronunciations:
          (json['pronunciations'] as List<dynamic>?)
              ?.map((e) => PronunciationDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PronunciationDto>[],
      senses:
          (json['senses'] as List<dynamic>?)
              ?.map((e) => SenseDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SenseDto>[],
    );

Map<String, dynamic> _$DictionaryEntryDtoToJson(_DictionaryEntryDto instance) =>
    <String, dynamic>{
      'partOfSpeech': instance.partOfSpeech,
      'language': instance.language,
      'pronunciations': instance.pronunciations,
      'senses': instance.senses,
    };

_DictionaryLanguageDto _$DictionaryLanguageDtoFromJson(
  Map<String, dynamic> json,
) => _DictionaryLanguageDto(
  code: json['code'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$DictionaryLanguageDtoToJson(
  _DictionaryLanguageDto instance,
) => <String, dynamic>{'code': instance.code, 'name': instance.name};

_PronunciationDto _$PronunciationDtoFromJson(Map<String, dynamic> json) =>
    _PronunciationDto(
      type: json['type'] as String?,
      text: json['text'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
    );

Map<String, dynamic> _$PronunciationDtoToJson(_PronunciationDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'tags': instance.tags,
    };

_SenseDto _$SenseDtoFromJson(Map<String, dynamic> json) => _SenseDto(
  definition: json['definition'] as String?,
  examples:
      (json['examples'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$SenseDtoToJson(_SenseDto instance) => <String, dynamic>{
  'definition': instance.definition,
  'examples': instance.examples,
  'tags': instance.tags,
};

_DictionarySourceDto _$DictionarySourceDtoFromJson(Map<String, dynamic> json) =>
    _DictionarySourceDto(
      url: json['url'] as String?,
      license: json['license'] == null
          ? null
          : DictionaryLicenseDto.fromJson(
              json['license'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$DictionarySourceDtoToJson(
  _DictionarySourceDto instance,
) => <String, dynamic>{'url': instance.url, 'license': instance.license};

_DictionaryLicenseDto _$DictionaryLicenseDtoFromJson(
  Map<String, dynamic> json,
) => _DictionaryLicenseDto(
  name: json['name'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$DictionaryLicenseDtoToJson(
  _DictionaryLicenseDto instance,
) => <String, dynamic>{'name': instance.name, 'url': instance.url};
