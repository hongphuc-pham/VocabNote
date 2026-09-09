// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FieldSuggestion {

/// Which field this fills.
 SuggestionField get field;/// The value that would be written.
 String get value;/// Where it came from - decides whether attribution is owed.
 WordSource get source;/// A short note shown on the chip, e.g. the accent tag the API gave.
 String? get hint;
/// Create a copy of FieldSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldSuggestionCopyWith<FieldSuggestion> get copyWith => _$FieldSuggestionCopyWithImpl<FieldSuggestion>(this as FieldSuggestion, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FieldSuggestion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldSuggestion&&(identical(other.field, _this.field) || other.field == _this.field)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.hint, _this.hint) || other.hint == _this.hint));
}


@override
int get hashCode {
  final _this = this as FieldSuggestion;
  return Object.hash(runtimeType,_this.field,_this.value,_this.source,_this.hint);
}

@override
String toString() {
  final _this = this as FieldSuggestion;
  return 'FieldSuggestion(field: ${_this.field}, value: ${_this.value}, source: ${_this.source}, hint: ${_this.hint})';
}


}

/// @nodoc
abstract mixin class $FieldSuggestionCopyWith<$Res>  {
  factory $FieldSuggestionCopyWith(FieldSuggestion value, $Res Function(FieldSuggestion) _then) = _$FieldSuggestionCopyWithImpl;
@useResult
$Res call({
 SuggestionField field, String value, WordSource source, String? hint
});




}
/// @nodoc
class _$FieldSuggestionCopyWithImpl<$Res>
    implements $FieldSuggestionCopyWith<$Res> {
  _$FieldSuggestionCopyWithImpl(this._self, this._then);

  final FieldSuggestion _self;
  final $Res Function(FieldSuggestion) _then;

/// Create a copy of FieldSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = null,Object? value = null,Object? source = null,Object? hint = freezed,}) {
  return _then(FieldSuggestion(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as SuggestionField,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WordSource,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldSuggestion].
extension FieldSuggestionPatterns on FieldSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _FieldSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _FieldSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SuggestionField field,  String value,  WordSource source,  String? hint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldSuggestion() when $default != null:
return $default(_that.field,_that.value,_that.source,_that.hint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SuggestionField field,  String value,  WordSource source,  String? hint)  $default,) {final _that = this;
switch (_that) {
case _FieldSuggestion():
return $default(_that.field,_that.value,_that.source,_that.hint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SuggestionField field,  String value,  WordSource source,  String? hint)?  $default,) {final _that = this;
switch (_that) {
case _FieldSuggestion() when $default != null:
return $default(_that.field,_that.value,_that.source,_that.hint);case _:
  return null;

}
}

}

/// @nodoc


class _FieldSuggestion extends FieldSuggestion {
  const _FieldSuggestion({required this.field, required this.value, required this.source, this.hint}): super._();
  

/// Which field this fills.
@override final  SuggestionField field;
/// The value that would be written.
@override final  String value;
/// Where it came from - decides whether attribution is owed.
@override final  WordSource source;
/// A short note shown on the chip, e.g. the accent tag the API gave.
@override final  String? hint;

/// Create a copy of FieldSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldSuggestionCopyWith<_FieldSuggestion> get copyWith => __$FieldSuggestionCopyWithImpl<_FieldSuggestion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldSuggestion&&(identical(other.field, field) || other.field == field)&&(identical(other.value, value) || other.value == value)&&(identical(other.source, source) || other.source == source)&&(identical(other.hint, hint) || other.hint == hint));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field,value,source,hint);
}

@override
String toString() {
    return 'FieldSuggestion(field: $field, value: $value, source: $source, hint: $hint)';
}


}

/// @nodoc
abstract mixin class _$FieldSuggestionCopyWith<$Res> implements $FieldSuggestionCopyWith<$Res> {
  factory _$FieldSuggestionCopyWith(_FieldSuggestion value, $Res Function(_FieldSuggestion) _then) = __$FieldSuggestionCopyWithImpl;
@override @useResult
$Res call({
 SuggestionField field, String value, WordSource source, String? hint
});




}
/// @nodoc
class __$FieldSuggestionCopyWithImpl<$Res>
    implements _$FieldSuggestionCopyWith<$Res> {
  __$FieldSuggestionCopyWithImpl(this._self, this._then);

  final _FieldSuggestion _self;
  final $Res Function(_FieldSuggestion) _then;

/// Create a copy of FieldSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? value = null,Object? source = null,Object? hint = freezed,}) {
  return _then(_FieldSuggestion(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as SuggestionField,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WordSource,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$WordSuggestions {

/// The word that was looked up, as the user typed it.
 String get headword;/// Where these came from.
 WordSource get source;/// The per-field chips, in the order they should be offered.
 List<FieldSuggestion> get suggestions;/// The credit line stored on any field the user accepts.
///
/// Null for [WordSource.manual], because the user's own writing is theirs
/// and owes nobody a credit.
 String? get attribution;/// The source page, linked from the results card as *View source*.
 String? get sourceUrl;/// The licence name shown in the results card, e.g. `CC BY-SA 4.0`.
 String? get licenseName;/// Where the licence text lives.
 String? get licenseUrl;
/// Create a copy of WordSuggestions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordSuggestionsCopyWith<WordSuggestions> get copyWith => _$WordSuggestionsCopyWithImpl<WordSuggestions>(this as WordSuggestions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WordSuggestions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordSuggestions&&(identical(other.headword, _this.headword) || other.headword == _this.headword)&&(identical(other.source, _this.source) || other.source == _this.source)&&const DeepCollectionEquality().equals(other.suggestions, _this.suggestions)&&(identical(other.attribution, _this.attribution) || other.attribution == _this.attribution)&&(identical(other.sourceUrl, _this.sourceUrl) || other.sourceUrl == _this.sourceUrl)&&(identical(other.licenseName, _this.licenseName) || other.licenseName == _this.licenseName)&&(identical(other.licenseUrl, _this.licenseUrl) || other.licenseUrl == _this.licenseUrl));
}


@override
int get hashCode {
  final _this = this as WordSuggestions;
  return Object.hash(runtimeType,_this.headword,_this.source,const DeepCollectionEquality().hash(_this.suggestions),_this.attribution,_this.sourceUrl,_this.licenseName,_this.licenseUrl);
}

@override
String toString() {
  final _this = this as WordSuggestions;
  return 'WordSuggestions(headword: ${_this.headword}, source: ${_this.source}, suggestions: ${_this.suggestions}, attribution: ${_this.attribution}, sourceUrl: ${_this.sourceUrl}, licenseName: ${_this.licenseName}, licenseUrl: ${_this.licenseUrl})';
}


}

/// @nodoc
abstract mixin class $WordSuggestionsCopyWith<$Res>  {
  factory $WordSuggestionsCopyWith(WordSuggestions value, $Res Function(WordSuggestions) _then) = _$WordSuggestionsCopyWithImpl;
@useResult
$Res call({
 String headword, WordSource source, List<FieldSuggestion> suggestions, String? attribution, String? sourceUrl, String? licenseName, String? licenseUrl
});




}
/// @nodoc
class _$WordSuggestionsCopyWithImpl<$Res>
    implements $WordSuggestionsCopyWith<$Res> {
  _$WordSuggestionsCopyWithImpl(this._self, this._then);

  final WordSuggestions _self;
  final $Res Function(WordSuggestions) _then;

/// Create a copy of WordSuggestions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headword = null,Object? source = null,Object? suggestions = null,Object? attribution = freezed,Object? sourceUrl = freezed,Object? licenseName = freezed,Object? licenseUrl = freezed,}) {
  return _then(WordSuggestions(
headword: null == headword ? _self.headword : headword // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WordSource,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<FieldSuggestion>,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,licenseName: freezed == licenseName ? _self.licenseName : licenseName // ignore: cast_nullable_to_non_nullable
as String?,licenseUrl: freezed == licenseUrl ? _self.licenseUrl : licenseUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WordSuggestions].
extension WordSuggestionsPatterns on WordSuggestions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordSuggestions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordSuggestions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordSuggestions value)  $default,){
final _that = this;
switch (_that) {
case _WordSuggestions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordSuggestions value)?  $default,){
final _that = this;
switch (_that) {
case _WordSuggestions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String headword,  WordSource source,  List<FieldSuggestion> suggestions,  String? attribution,  String? sourceUrl,  String? licenseName,  String? licenseUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordSuggestions() when $default != null:
return $default(_that.headword,_that.source,_that.suggestions,_that.attribution,_that.sourceUrl,_that.licenseName,_that.licenseUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String headword,  WordSource source,  List<FieldSuggestion> suggestions,  String? attribution,  String? sourceUrl,  String? licenseName,  String? licenseUrl)  $default,) {final _that = this;
switch (_that) {
case _WordSuggestions():
return $default(_that.headword,_that.source,_that.suggestions,_that.attribution,_that.sourceUrl,_that.licenseName,_that.licenseUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String headword,  WordSource source,  List<FieldSuggestion> suggestions,  String? attribution,  String? sourceUrl,  String? licenseName,  String? licenseUrl)?  $default,) {final _that = this;
switch (_that) {
case _WordSuggestions() when $default != null:
return $default(_that.headword,_that.source,_that.suggestions,_that.attribution,_that.sourceUrl,_that.licenseName,_that.licenseUrl);case _:
  return null;

}
}

}

/// @nodoc


class _WordSuggestions extends WordSuggestions {
  const _WordSuggestions({required this.headword, required this.source,  List<FieldSuggestion> suggestions = const <FieldSuggestion>[], this.attribution, this.sourceUrl, this.licenseName, this.licenseUrl}): _suggestions = suggestions,super._();
  

/// The word that was looked up, as the user typed it.
@override final  String headword;
/// Where these came from.
@override final  WordSource source;
/// The per-field chips, in the order they should be offered.
 final  List<FieldSuggestion> _suggestions;
/// The per-field chips, in the order they should be offered.
@override@JsonKey() List<FieldSuggestion> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}

/// The credit line stored on any field the user accepts.
///
/// Null for [WordSource.manual], because the user's own writing is theirs
/// and owes nobody a credit.
@override final  String? attribution;
/// The source page, linked from the results card as *View source*.
@override final  String? sourceUrl;
/// The licence name shown in the results card, e.g. `CC BY-SA 4.0`.
@override final  String? licenseName;
/// Where the licence text lives.
@override final  String? licenseUrl;

/// Create a copy of WordSuggestions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordSuggestionsCopyWith<_WordSuggestions> get copyWith => __$WordSuggestionsCopyWithImpl<_WordSuggestions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordSuggestions&&(identical(other.headword, headword) || other.headword == headword)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.suggestions, _suggestions)&&(identical(other.attribution, attribution) || other.attribution == attribution)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.licenseName, licenseName) || other.licenseName == licenseName)&&(identical(other.licenseUrl, licenseUrl) || other.licenseUrl == licenseUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,headword,source,const DeepCollectionEquality().hash(_suggestions),attribution,sourceUrl,licenseName,licenseUrl);
}

@override
String toString() {
    return 'WordSuggestions(headword: $headword, source: $source, suggestions: $suggestions, attribution: $attribution, sourceUrl: $sourceUrl, licenseName: $licenseName, licenseUrl: $licenseUrl)';
}


}

/// @nodoc
abstract mixin class _$WordSuggestionsCopyWith<$Res> implements $WordSuggestionsCopyWith<$Res> {
  factory _$WordSuggestionsCopyWith(_WordSuggestions value, $Res Function(_WordSuggestions) _then) = __$WordSuggestionsCopyWithImpl;
@override @useResult
$Res call({
 String headword, WordSource source, List<FieldSuggestion> suggestions, String? attribution, String? sourceUrl, String? licenseName, String? licenseUrl
});




}
/// @nodoc
class __$WordSuggestionsCopyWithImpl<$Res>
    implements _$WordSuggestionsCopyWith<$Res> {
  __$WordSuggestionsCopyWithImpl(this._self, this._then);

  final _WordSuggestions _self;
  final $Res Function(_WordSuggestions) _then;

/// Create a copy of WordSuggestions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headword = null,Object? source = null,Object? suggestions = null,Object? attribution = freezed,Object? sourceUrl = freezed,Object? licenseName = freezed,Object? licenseUrl = freezed,}) {
  return _then(_WordSuggestions(
headword: null == headword ? _self.headword : headword // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WordSource,suggestions: null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<FieldSuggestion>,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,licenseName: freezed == licenseName ? _self.licenseName : licenseName // ignore: cast_nullable_to_non_nullable
as String?,licenseUrl: freezed == licenseUrl ? _self.licenseUrl : licenseUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
