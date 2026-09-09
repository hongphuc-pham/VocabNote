// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictionary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DictionaryResponseDto {

 String? get word; List<DictionaryEntryDto> get entries; DictionarySourceDto? get source;
/// Create a copy of DictionaryResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryResponseDtoCopyWith<DictionaryResponseDto> get copyWith => _$DictionaryResponseDtoCopyWithImpl<DictionaryResponseDto>(this as DictionaryResponseDto, _$identity);

  /// Serializes this DictionaryResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DictionaryResponseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryResponseDto&&(identical(other.word, _this.word) || other.word == _this.word)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.source, _this.source) || other.source == _this.source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DictionaryResponseDto;
  return Object.hash(runtimeType,_this.word,const DeepCollectionEquality().hash(_this.entries),_this.source);
}

@override
String toString() {
  final _this = this as DictionaryResponseDto;
  return 'DictionaryResponseDto(word: ${_this.word}, entries: ${_this.entries}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $DictionaryResponseDtoCopyWith<$Res>  {
  factory $DictionaryResponseDtoCopyWith(DictionaryResponseDto value, $Res Function(DictionaryResponseDto) _then) = _$DictionaryResponseDtoCopyWithImpl;
@useResult
$Res call({
 String? word, List<DictionaryEntryDto> entries, DictionarySourceDto? source
});


$DictionarySourceDtoCopyWith<$Res>? get source;

}
/// @nodoc
class _$DictionaryResponseDtoCopyWithImpl<$Res>
    implements $DictionaryResponseDtoCopyWith<$Res> {
  _$DictionaryResponseDtoCopyWithImpl(this._self, this._then);

  final DictionaryResponseDto _self;
  final $Res Function(DictionaryResponseDto) _then;

/// Create a copy of DictionaryResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = freezed,Object? entries = null,Object? source = freezed,}) {
  return _then(DictionaryResponseDto(
word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String?,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<DictionaryEntryDto>,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DictionarySourceDto?,
  ));
}
/// Create a copy of DictionaryResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DictionarySourceDtoCopyWith<$Res>? get source {
    if (_self.source == null) {
    return null;
  }

  return $DictionarySourceDtoCopyWith<$Res>(_self.source!, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}


/// Adds pattern-matching-related methods to [DictionaryResponseDto].
extension DictionaryResponseDtoPatterns on DictionaryResponseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryResponseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? word,  List<DictionaryEntryDto> entries,  DictionarySourceDto? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryResponseDto() when $default != null:
return $default(_that.word,_that.entries,_that.source);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? word,  List<DictionaryEntryDto> entries,  DictionarySourceDto? source)  $default,) {final _that = this;
switch (_that) {
case _DictionaryResponseDto():
return $default(_that.word,_that.entries,_that.source);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? word,  List<DictionaryEntryDto> entries,  DictionarySourceDto? source)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryResponseDto() when $default != null:
return $default(_that.word,_that.entries,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionaryResponseDto implements DictionaryResponseDto {
  const _DictionaryResponseDto({this.word,  List<DictionaryEntryDto> entries = const <DictionaryEntryDto>[], this.source}): _entries = entries;
  factory _DictionaryResponseDto.fromJson(Map<String, dynamic> json) => _$DictionaryResponseDtoFromJson(json);

@override final  String? word;
 final  List<DictionaryEntryDto> _entries;
@override@JsonKey() List<DictionaryEntryDto> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  DictionarySourceDto? source;

/// Create a copy of DictionaryResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryResponseDtoCopyWith<_DictionaryResponseDto> get copyWith => __$DictionaryResponseDtoCopyWithImpl<_DictionaryResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionaryResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryResponseDto&&(identical(other.word, word) || other.word == word)&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,word,const DeepCollectionEquality().hash(_entries),source);
}

@override
String toString() {
    return 'DictionaryResponseDto(word: $word, entries: $entries, source: $source)';
}


}

/// @nodoc
abstract mixin class _$DictionaryResponseDtoCopyWith<$Res> implements $DictionaryResponseDtoCopyWith<$Res> {
  factory _$DictionaryResponseDtoCopyWith(_DictionaryResponseDto value, $Res Function(_DictionaryResponseDto) _then) = __$DictionaryResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String? word, List<DictionaryEntryDto> entries, DictionarySourceDto? source
});


@override $DictionarySourceDtoCopyWith<$Res>? get source;

}
/// @nodoc
class __$DictionaryResponseDtoCopyWithImpl<$Res>
    implements _$DictionaryResponseDtoCopyWith<$Res> {
  __$DictionaryResponseDtoCopyWithImpl(this._self, this._then);

  final _DictionaryResponseDto _self;
  final $Res Function(_DictionaryResponseDto) _then;

/// Create a copy of DictionaryResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = freezed,Object? entries = null,Object? source = freezed,}) {
  return _then(_DictionaryResponseDto(
word: freezed == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String?,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<DictionaryEntryDto>,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DictionarySourceDto?,
  ));
}

/// Create a copy of DictionaryResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DictionarySourceDtoCopyWith<$Res>? get source {
    if (_self.source == null) {
    return null;
  }

  return $DictionarySourceDtoCopyWith<$Res>(_self.source!, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}


/// @nodoc
mixin _$DictionaryEntryDto {

 String? get partOfSpeech; DictionaryLanguageDto? get language; List<PronunciationDto> get pronunciations; List<SenseDto> get senses;
/// Create a copy of DictionaryEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryEntryDtoCopyWith<DictionaryEntryDto> get copyWith => _$DictionaryEntryDtoCopyWithImpl<DictionaryEntryDto>(this as DictionaryEntryDto, _$identity);

  /// Serializes this DictionaryEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DictionaryEntryDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryEntryDto&&(identical(other.partOfSpeech, _this.partOfSpeech) || other.partOfSpeech == _this.partOfSpeech)&&(identical(other.language, _this.language) || other.language == _this.language)&&const DeepCollectionEquality().equals(other.pronunciations, _this.pronunciations)&&const DeepCollectionEquality().equals(other.senses, _this.senses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DictionaryEntryDto;
  return Object.hash(runtimeType,_this.partOfSpeech,_this.language,const DeepCollectionEquality().hash(_this.pronunciations),const DeepCollectionEquality().hash(_this.senses));
}

@override
String toString() {
  final _this = this as DictionaryEntryDto;
  return 'DictionaryEntryDto(partOfSpeech: ${_this.partOfSpeech}, language: ${_this.language}, pronunciations: ${_this.pronunciations}, senses: ${_this.senses})';
}


}

/// @nodoc
abstract mixin class $DictionaryEntryDtoCopyWith<$Res>  {
  factory $DictionaryEntryDtoCopyWith(DictionaryEntryDto value, $Res Function(DictionaryEntryDto) _then) = _$DictionaryEntryDtoCopyWithImpl;
@useResult
$Res call({
 String? partOfSpeech, DictionaryLanguageDto? language, List<PronunciationDto> pronunciations, List<SenseDto> senses
});


$DictionaryLanguageDtoCopyWith<$Res>? get language;

}
/// @nodoc
class _$DictionaryEntryDtoCopyWithImpl<$Res>
    implements $DictionaryEntryDtoCopyWith<$Res> {
  _$DictionaryEntryDtoCopyWithImpl(this._self, this._then);

  final DictionaryEntryDto _self;
  final $Res Function(DictionaryEntryDto) _then;

/// Create a copy of DictionaryEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partOfSpeech = freezed,Object? language = freezed,Object? pronunciations = null,Object? senses = null,}) {
  return _then(DictionaryEntryDto(
partOfSpeech: freezed == partOfSpeech ? _self.partOfSpeech : partOfSpeech // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as DictionaryLanguageDto?,pronunciations: null == pronunciations ? _self.pronunciations : pronunciations // ignore: cast_nullable_to_non_nullable
as List<PronunciationDto>,senses: null == senses ? _self.senses : senses // ignore: cast_nullable_to_non_nullable
as List<SenseDto>,
  ));
}
/// Create a copy of DictionaryEntryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DictionaryLanguageDtoCopyWith<$Res>? get language {
    if (_self.language == null) {
    return null;
  }

  return $DictionaryLanguageDtoCopyWith<$Res>(_self.language!, (value) {
    return _then(_self.copyWith(language: value));
  });
}
}


/// Adds pattern-matching-related methods to [DictionaryEntryDto].
extension DictionaryEntryDtoPatterns on DictionaryEntryDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryEntryDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryEntryDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryEntryDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? partOfSpeech,  DictionaryLanguageDto? language,  List<PronunciationDto> pronunciations,  List<SenseDto> senses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryEntryDto() when $default != null:
return $default(_that.partOfSpeech,_that.language,_that.pronunciations,_that.senses);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? partOfSpeech,  DictionaryLanguageDto? language,  List<PronunciationDto> pronunciations,  List<SenseDto> senses)  $default,) {final _that = this;
switch (_that) {
case _DictionaryEntryDto():
return $default(_that.partOfSpeech,_that.language,_that.pronunciations,_that.senses);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? partOfSpeech,  DictionaryLanguageDto? language,  List<PronunciationDto> pronunciations,  List<SenseDto> senses)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryEntryDto() when $default != null:
return $default(_that.partOfSpeech,_that.language,_that.pronunciations,_that.senses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionaryEntryDto implements DictionaryEntryDto {
  const _DictionaryEntryDto({this.partOfSpeech, this.language,  List<PronunciationDto> pronunciations = const <PronunciationDto>[],  List<SenseDto> senses = const <SenseDto>[]}): _pronunciations = pronunciations,_senses = senses;
  factory _DictionaryEntryDto.fromJson(Map<String, dynamic> json) => _$DictionaryEntryDtoFromJson(json);

@override final  String? partOfSpeech;
@override final  DictionaryLanguageDto? language;
 final  List<PronunciationDto> _pronunciations;
@override@JsonKey() List<PronunciationDto> get pronunciations {
  if (_pronunciations is EqualUnmodifiableListView) return _pronunciations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pronunciations);
}

 final  List<SenseDto> _senses;
@override@JsonKey() List<SenseDto> get senses {
  if (_senses is EqualUnmodifiableListView) return _senses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_senses);
}


/// Create a copy of DictionaryEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryEntryDtoCopyWith<_DictionaryEntryDto> get copyWith => __$DictionaryEntryDtoCopyWithImpl<_DictionaryEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionaryEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryEntryDto&&(identical(other.partOfSpeech, partOfSpeech) || other.partOfSpeech == partOfSpeech)&&(identical(other.language, language) || other.language == language)&&const DeepCollectionEquality().equals(other.pronunciations, _pronunciations)&&const DeepCollectionEquality().equals(other.senses, _senses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,partOfSpeech,language,const DeepCollectionEquality().hash(_pronunciations),const DeepCollectionEquality().hash(_senses));
}

@override
String toString() {
    return 'DictionaryEntryDto(partOfSpeech: $partOfSpeech, language: $language, pronunciations: $pronunciations, senses: $senses)';
}


}

/// @nodoc
abstract mixin class _$DictionaryEntryDtoCopyWith<$Res> implements $DictionaryEntryDtoCopyWith<$Res> {
  factory _$DictionaryEntryDtoCopyWith(_DictionaryEntryDto value, $Res Function(_DictionaryEntryDto) _then) = __$DictionaryEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String? partOfSpeech, DictionaryLanguageDto? language, List<PronunciationDto> pronunciations, List<SenseDto> senses
});


@override $DictionaryLanguageDtoCopyWith<$Res>? get language;

}
/// @nodoc
class __$DictionaryEntryDtoCopyWithImpl<$Res>
    implements _$DictionaryEntryDtoCopyWith<$Res> {
  __$DictionaryEntryDtoCopyWithImpl(this._self, this._then);

  final _DictionaryEntryDto _self;
  final $Res Function(_DictionaryEntryDto) _then;

/// Create a copy of DictionaryEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partOfSpeech = freezed,Object? language = freezed,Object? pronunciations = null,Object? senses = null,}) {
  return _then(_DictionaryEntryDto(
partOfSpeech: freezed == partOfSpeech ? _self.partOfSpeech : partOfSpeech // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as DictionaryLanguageDto?,pronunciations: null == pronunciations ? _self._pronunciations : pronunciations // ignore: cast_nullable_to_non_nullable
as List<PronunciationDto>,senses: null == senses ? _self._senses : senses // ignore: cast_nullable_to_non_nullable
as List<SenseDto>,
  ));
}

/// Create a copy of DictionaryEntryDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DictionaryLanguageDtoCopyWith<$Res>? get language {
    if (_self.language == null) {
    return null;
  }

  return $DictionaryLanguageDtoCopyWith<$Res>(_self.language!, (value) {
    return _then(_self.copyWith(language: value));
  });
}
}


/// @nodoc
mixin _$DictionaryLanguageDto {

 String? get code; String? get name;
/// Create a copy of DictionaryLanguageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryLanguageDtoCopyWith<DictionaryLanguageDto> get copyWith => _$DictionaryLanguageDtoCopyWithImpl<DictionaryLanguageDto>(this as DictionaryLanguageDto, _$identity);

  /// Serializes this DictionaryLanguageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DictionaryLanguageDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryLanguageDto&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DictionaryLanguageDto;
  return Object.hash(runtimeType,_this.code,_this.name);
}

@override
String toString() {
  final _this = this as DictionaryLanguageDto;
  return 'DictionaryLanguageDto(code: ${_this.code}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $DictionaryLanguageDtoCopyWith<$Res>  {
  factory $DictionaryLanguageDtoCopyWith(DictionaryLanguageDto value, $Res Function(DictionaryLanguageDto) _then) = _$DictionaryLanguageDtoCopyWithImpl;
@useResult
$Res call({
 String? code, String? name
});




}
/// @nodoc
class _$DictionaryLanguageDtoCopyWithImpl<$Res>
    implements $DictionaryLanguageDtoCopyWith<$Res> {
  _$DictionaryLanguageDtoCopyWithImpl(this._self, this._then);

  final DictionaryLanguageDto _self;
  final $Res Function(DictionaryLanguageDto) _then;

/// Create a copy of DictionaryLanguageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = freezed,Object? name = freezed,}) {
  return _then(DictionaryLanguageDto(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DictionaryLanguageDto].
extension DictionaryLanguageDtoPatterns on DictionaryLanguageDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryLanguageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryLanguageDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryLanguageDto value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryLanguageDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryLanguageDto value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryLanguageDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? code,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryLanguageDto() when $default != null:
return $default(_that.code,_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? code,  String? name)  $default,) {final _that = this;
switch (_that) {
case _DictionaryLanguageDto():
return $default(_that.code,_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? code,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryLanguageDto() when $default != null:
return $default(_that.code,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionaryLanguageDto implements DictionaryLanguageDto {
  const _DictionaryLanguageDto({this.code, this.name});
  factory _DictionaryLanguageDto.fromJson(Map<String, dynamic> json) => _$DictionaryLanguageDtoFromJson(json);

@override final  String? code;
@override final  String? name;

/// Create a copy of DictionaryLanguageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryLanguageDtoCopyWith<_DictionaryLanguageDto> get copyWith => __$DictionaryLanguageDtoCopyWithImpl<_DictionaryLanguageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionaryLanguageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryLanguageDto&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,name);
}

@override
String toString() {
    return 'DictionaryLanguageDto(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class _$DictionaryLanguageDtoCopyWith<$Res> implements $DictionaryLanguageDtoCopyWith<$Res> {
  factory _$DictionaryLanguageDtoCopyWith(_DictionaryLanguageDto value, $Res Function(_DictionaryLanguageDto) _then) = __$DictionaryLanguageDtoCopyWithImpl;
@override @useResult
$Res call({
 String? code, String? name
});




}
/// @nodoc
class __$DictionaryLanguageDtoCopyWithImpl<$Res>
    implements _$DictionaryLanguageDtoCopyWith<$Res> {
  __$DictionaryLanguageDtoCopyWithImpl(this._self, this._then);

  final _DictionaryLanguageDto _self;
  final $Res Function(_DictionaryLanguageDto) _then;

/// Create a copy of DictionaryLanguageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? name = freezed,}) {
  return _then(_DictionaryLanguageDto(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PronunciationDto {

 String? get type; String? get text; List<String> get tags;
/// Create a copy of PronunciationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PronunciationDtoCopyWith<PronunciationDto> get copyWith => _$PronunciationDtoCopyWithImpl<PronunciationDto>(this as PronunciationDto, _$identity);

  /// Serializes this PronunciationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PronunciationDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PronunciationDto&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.tags, _this.tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PronunciationDto;
  return Object.hash(runtimeType,_this.type,_this.text,const DeepCollectionEquality().hash(_this.tags));
}

@override
String toString() {
  final _this = this as PronunciationDto;
  return 'PronunciationDto(type: ${_this.type}, text: ${_this.text}, tags: ${_this.tags})';
}


}

/// @nodoc
abstract mixin class $PronunciationDtoCopyWith<$Res>  {
  factory $PronunciationDtoCopyWith(PronunciationDto value, $Res Function(PronunciationDto) _then) = _$PronunciationDtoCopyWithImpl;
@useResult
$Res call({
 String? type, String? text, List<String> tags
});




}
/// @nodoc
class _$PronunciationDtoCopyWithImpl<$Res>
    implements $PronunciationDtoCopyWith<$Res> {
  _$PronunciationDtoCopyWithImpl(this._self, this._then);

  final PronunciationDto _self;
  final $Res Function(PronunciationDto) _then;

/// Create a copy of PronunciationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? text = freezed,Object? tags = null,}) {
  return _then(PronunciationDto(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PronunciationDto].
extension PronunciationDtoPatterns on PronunciationDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PronunciationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PronunciationDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PronunciationDto value)  $default,){
final _that = this;
switch (_that) {
case _PronunciationDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PronunciationDto value)?  $default,){
final _that = this;
switch (_that) {
case _PronunciationDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  String? text,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PronunciationDto() when $default != null:
return $default(_that.type,_that.text,_that.tags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  String? text,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _PronunciationDto():
return $default(_that.type,_that.text,_that.tags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  String? text,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _PronunciationDto() when $default != null:
return $default(_that.type,_that.text,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PronunciationDto implements PronunciationDto {
  const _PronunciationDto({this.type, this.text,  List<String> tags = const <String>[]}): _tags = tags;
  factory _PronunciationDto.fromJson(Map<String, dynamic> json) => _$PronunciationDtoFromJson(json);

@override final  String? type;
@override final  String? text;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of PronunciationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PronunciationDtoCopyWith<_PronunciationDto> get copyWith => __$PronunciationDtoCopyWithImpl<_PronunciationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PronunciationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PronunciationDto&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,text,const DeepCollectionEquality().hash(_tags));
}

@override
String toString() {
    return 'PronunciationDto(type: $type, text: $text, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$PronunciationDtoCopyWith<$Res> implements $PronunciationDtoCopyWith<$Res> {
  factory _$PronunciationDtoCopyWith(_PronunciationDto value, $Res Function(_PronunciationDto) _then) = __$PronunciationDtoCopyWithImpl;
@override @useResult
$Res call({
 String? type, String? text, List<String> tags
});




}
/// @nodoc
class __$PronunciationDtoCopyWithImpl<$Res>
    implements _$PronunciationDtoCopyWith<$Res> {
  __$PronunciationDtoCopyWithImpl(this._self, this._then);

  final _PronunciationDto _self;
  final $Res Function(_PronunciationDto) _then;

/// Create a copy of PronunciationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? text = freezed,Object? tags = null,}) {
  return _then(_PronunciationDto(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$SenseDto {

 String? get definition; List<String> get examples; List<String> get tags;
/// Create a copy of SenseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenseDtoCopyWith<SenseDto> get copyWith => _$SenseDtoCopyWithImpl<SenseDto>(this as SenseDto, _$identity);

  /// Serializes this SenseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SenseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SenseDto&&(identical(other.definition, _this.definition) || other.definition == _this.definition)&&const DeepCollectionEquality().equals(other.examples, _this.examples)&&const DeepCollectionEquality().equals(other.tags, _this.tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SenseDto;
  return Object.hash(runtimeType,_this.definition,const DeepCollectionEquality().hash(_this.examples),const DeepCollectionEquality().hash(_this.tags));
}

@override
String toString() {
  final _this = this as SenseDto;
  return 'SenseDto(definition: ${_this.definition}, examples: ${_this.examples}, tags: ${_this.tags})';
}


}

/// @nodoc
abstract mixin class $SenseDtoCopyWith<$Res>  {
  factory $SenseDtoCopyWith(SenseDto value, $Res Function(SenseDto) _then) = _$SenseDtoCopyWithImpl;
@useResult
$Res call({
 String? definition, List<String> examples, List<String> tags
});




}
/// @nodoc
class _$SenseDtoCopyWithImpl<$Res>
    implements $SenseDtoCopyWith<$Res> {
  _$SenseDtoCopyWithImpl(this._self, this._then);

  final SenseDto _self;
  final $Res Function(SenseDto) _then;

/// Create a copy of SenseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? definition = freezed,Object? examples = null,Object? tags = null,}) {
  return _then(SenseDto(
definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SenseDto].
extension SenseDtoPatterns on SenseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SenseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SenseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SenseDto value)  $default,){
final _that = this;
switch (_that) {
case _SenseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SenseDto value)?  $default,){
final _that = this;
switch (_that) {
case _SenseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? definition,  List<String> examples,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SenseDto() when $default != null:
return $default(_that.definition,_that.examples,_that.tags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? definition,  List<String> examples,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _SenseDto():
return $default(_that.definition,_that.examples,_that.tags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? definition,  List<String> examples,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _SenseDto() when $default != null:
return $default(_that.definition,_that.examples,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SenseDto implements SenseDto {
  const _SenseDto({this.definition,  List<String> examples = const <String>[],  List<String> tags = const <String>[]}): _examples = examples,_tags = tags;
  factory _SenseDto.fromJson(Map<String, dynamic> json) => _$SenseDtoFromJson(json);

@override final  String? definition;
 final  List<String> _examples;
@override@JsonKey() List<String> get examples {
  if (_examples is EqualUnmodifiableListView) return _examples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_examples);
}

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of SenseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenseDtoCopyWith<_SenseDto> get copyWith => __$SenseDtoCopyWithImpl<_SenseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SenseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SenseDto&&(identical(other.definition, definition) || other.definition == definition)&&const DeepCollectionEquality().equals(other.examples, _examples)&&const DeepCollectionEquality().equals(other.tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,definition,const DeepCollectionEquality().hash(_examples),const DeepCollectionEquality().hash(_tags));
}

@override
String toString() {
    return 'SenseDto(definition: $definition, examples: $examples, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$SenseDtoCopyWith<$Res> implements $SenseDtoCopyWith<$Res> {
  factory _$SenseDtoCopyWith(_SenseDto value, $Res Function(_SenseDto) _then) = __$SenseDtoCopyWithImpl;
@override @useResult
$Res call({
 String? definition, List<String> examples, List<String> tags
});




}
/// @nodoc
class __$SenseDtoCopyWithImpl<$Res>
    implements _$SenseDtoCopyWith<$Res> {
  __$SenseDtoCopyWithImpl(this._self, this._then);

  final _SenseDto _self;
  final $Res Function(_SenseDto) _then;

/// Create a copy of SenseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? definition = freezed,Object? examples = null,Object? tags = null,}) {
  return _then(_SenseDto(
definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$DictionarySourceDto {

 String? get url; DictionaryLicenseDto? get license;
/// Create a copy of DictionarySourceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionarySourceDtoCopyWith<DictionarySourceDto> get copyWith => _$DictionarySourceDtoCopyWithImpl<DictionarySourceDto>(this as DictionarySourceDto, _$identity);

  /// Serializes this DictionarySourceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DictionarySourceDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionarySourceDto&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.license, _this.license) || other.license == _this.license));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DictionarySourceDto;
  return Object.hash(runtimeType,_this.url,_this.license);
}

@override
String toString() {
  final _this = this as DictionarySourceDto;
  return 'DictionarySourceDto(url: ${_this.url}, license: ${_this.license})';
}


}

/// @nodoc
abstract mixin class $DictionarySourceDtoCopyWith<$Res>  {
  factory $DictionarySourceDtoCopyWith(DictionarySourceDto value, $Res Function(DictionarySourceDto) _then) = _$DictionarySourceDtoCopyWithImpl;
@useResult
$Res call({
 String? url, DictionaryLicenseDto? license
});


$DictionaryLicenseDtoCopyWith<$Res>? get license;

}
/// @nodoc
class _$DictionarySourceDtoCopyWithImpl<$Res>
    implements $DictionarySourceDtoCopyWith<$Res> {
  _$DictionarySourceDtoCopyWithImpl(this._self, this._then);

  final DictionarySourceDto _self;
  final $Res Function(DictionarySourceDto) _then;

/// Create a copy of DictionarySourceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = freezed,Object? license = freezed,}) {
  return _then(DictionarySourceDto(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,license: freezed == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as DictionaryLicenseDto?,
  ));
}
/// Create a copy of DictionarySourceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DictionaryLicenseDtoCopyWith<$Res>? get license {
    if (_self.license == null) {
    return null;
  }

  return $DictionaryLicenseDtoCopyWith<$Res>(_self.license!, (value) {
    return _then(_self.copyWith(license: value));
  });
}
}


/// Adds pattern-matching-related methods to [DictionarySourceDto].
extension DictionarySourceDtoPatterns on DictionarySourceDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionarySourceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionarySourceDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionarySourceDto value)  $default,){
final _that = this;
switch (_that) {
case _DictionarySourceDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionarySourceDto value)?  $default,){
final _that = this;
switch (_that) {
case _DictionarySourceDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? url,  DictionaryLicenseDto? license)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionarySourceDto() when $default != null:
return $default(_that.url,_that.license);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? url,  DictionaryLicenseDto? license)  $default,) {final _that = this;
switch (_that) {
case _DictionarySourceDto():
return $default(_that.url,_that.license);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? url,  DictionaryLicenseDto? license)?  $default,) {final _that = this;
switch (_that) {
case _DictionarySourceDto() when $default != null:
return $default(_that.url,_that.license);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionarySourceDto implements DictionarySourceDto {
  const _DictionarySourceDto({this.url, this.license});
  factory _DictionarySourceDto.fromJson(Map<String, dynamic> json) => _$DictionarySourceDtoFromJson(json);

@override final  String? url;
@override final  DictionaryLicenseDto? license;

/// Create a copy of DictionarySourceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionarySourceDtoCopyWith<_DictionarySourceDto> get copyWith => __$DictionarySourceDtoCopyWithImpl<_DictionarySourceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionarySourceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionarySourceDto&&(identical(other.url, url) || other.url == url)&&(identical(other.license, license) || other.license == license));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,license);
}

@override
String toString() {
    return 'DictionarySourceDto(url: $url, license: $license)';
}


}

/// @nodoc
abstract mixin class _$DictionarySourceDtoCopyWith<$Res> implements $DictionarySourceDtoCopyWith<$Res> {
  factory _$DictionarySourceDtoCopyWith(_DictionarySourceDto value, $Res Function(_DictionarySourceDto) _then) = __$DictionarySourceDtoCopyWithImpl;
@override @useResult
$Res call({
 String? url, DictionaryLicenseDto? license
});


@override $DictionaryLicenseDtoCopyWith<$Res>? get license;

}
/// @nodoc
class __$DictionarySourceDtoCopyWithImpl<$Res>
    implements _$DictionarySourceDtoCopyWith<$Res> {
  __$DictionarySourceDtoCopyWithImpl(this._self, this._then);

  final _DictionarySourceDto _self;
  final $Res Function(_DictionarySourceDto) _then;

/// Create a copy of DictionarySourceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = freezed,Object? license = freezed,}) {
  return _then(_DictionarySourceDto(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,license: freezed == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as DictionaryLicenseDto?,
  ));
}

/// Create a copy of DictionarySourceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DictionaryLicenseDtoCopyWith<$Res>? get license {
    if (_self.license == null) {
    return null;
  }

  return $DictionaryLicenseDtoCopyWith<$Res>(_self.license!, (value) {
    return _then(_self.copyWith(license: value));
  });
}
}


/// @nodoc
mixin _$DictionaryLicenseDto {

 String? get name; String? get url;
/// Create a copy of DictionaryLicenseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DictionaryLicenseDtoCopyWith<DictionaryLicenseDto> get copyWith => _$DictionaryLicenseDtoCopyWithImpl<DictionaryLicenseDto>(this as DictionaryLicenseDto, _$identity);

  /// Serializes this DictionaryLicenseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DictionaryLicenseDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DictionaryLicenseDto&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DictionaryLicenseDto;
  return Object.hash(runtimeType,_this.name,_this.url);
}

@override
String toString() {
  final _this = this as DictionaryLicenseDto;
  return 'DictionaryLicenseDto(name: ${_this.name}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $DictionaryLicenseDtoCopyWith<$Res>  {
  factory $DictionaryLicenseDtoCopyWith(DictionaryLicenseDto value, $Res Function(DictionaryLicenseDto) _then) = _$DictionaryLicenseDtoCopyWithImpl;
@useResult
$Res call({
 String? name, String? url
});




}
/// @nodoc
class _$DictionaryLicenseDtoCopyWithImpl<$Res>
    implements $DictionaryLicenseDtoCopyWith<$Res> {
  _$DictionaryLicenseDtoCopyWithImpl(this._self, this._then);

  final DictionaryLicenseDto _self;
  final $Res Function(DictionaryLicenseDto) _then;

/// Create a copy of DictionaryLicenseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? url = freezed,}) {
  return _then(DictionaryLicenseDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DictionaryLicenseDto].
extension DictionaryLicenseDtoPatterns on DictionaryLicenseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DictionaryLicenseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DictionaryLicenseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DictionaryLicenseDto value)  $default,){
final _that = this;
switch (_that) {
case _DictionaryLicenseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DictionaryLicenseDto value)?  $default,){
final _that = this;
switch (_that) {
case _DictionaryLicenseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DictionaryLicenseDto() when $default != null:
return $default(_that.name,_that.url);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? url)  $default,) {final _that = this;
switch (_that) {
case _DictionaryLicenseDto():
return $default(_that.name,_that.url);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _DictionaryLicenseDto() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DictionaryLicenseDto implements DictionaryLicenseDto {
  const _DictionaryLicenseDto({this.name, this.url});
  factory _DictionaryLicenseDto.fromJson(Map<String, dynamic> json) => _$DictionaryLicenseDtoFromJson(json);

@override final  String? name;
@override final  String? url;

/// Create a copy of DictionaryLicenseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DictionaryLicenseDtoCopyWith<_DictionaryLicenseDto> get copyWith => __$DictionaryLicenseDtoCopyWithImpl<_DictionaryLicenseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DictionaryLicenseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DictionaryLicenseDto&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,url);
}

@override
String toString() {
    return 'DictionaryLicenseDto(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$DictionaryLicenseDtoCopyWith<$Res> implements $DictionaryLicenseDtoCopyWith<$Res> {
  factory _$DictionaryLicenseDtoCopyWith(_DictionaryLicenseDto value, $Res Function(_DictionaryLicenseDto) _then) = __$DictionaryLicenseDtoCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? url
});




}
/// @nodoc
class __$DictionaryLicenseDtoCopyWithImpl<$Res>
    implements _$DictionaryLicenseDtoCopyWith<$Res> {
  __$DictionaryLicenseDtoCopyWithImpl(this._self, this._then);

  final _DictionaryLicenseDto _self;
  final $Res Function(_DictionaryLicenseDto) _then;

/// Create a copy of DictionaryLicenseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? url = freezed,}) {
  return _then(_DictionaryLicenseDto(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
