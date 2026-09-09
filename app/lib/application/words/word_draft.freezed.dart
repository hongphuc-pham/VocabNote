// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WordDraft {

/// The word being edited, or null when adding a new one.
 String? get id;/// As typed. Required, trimmed on save.
 String get headword;/// British transcription, without slashes.
 String get ipaUk;/// American transcription, without slashes.
 String get ipaUs;/// Free text.
 String get partOfSpeech;/// What it means.
 String get definition;/// A sentence using it.
 String get example;/// The first note, offered only when adding.
 String get firstNote;/// Which lists it goes into.
 List<String> get listIds;/// Starred.
 bool get isFavourite;/// Which fields were accepted from a look-up, and from where.
///
/// Drives both the attribution stored on the word and the "this came from
/// the dictionary" affordance in the form.
 Map<SuggestionField, WordSource> get acceptedFields;/// The credit line for whatever was accepted.
 String? get attribution;/// The source page, stored alongside the attribution.
 String? get sourceUrl;/// When the word was first created. Null for a new one.
 DateTime? get createdAt;
/// Create a copy of WordDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordDraftCopyWith<WordDraft> get copyWith => _$WordDraftCopyWithImpl<WordDraft>(this as WordDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WordDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordDraft&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.headword, _this.headword) || other.headword == _this.headword)&&(identical(other.ipaUk, _this.ipaUk) || other.ipaUk == _this.ipaUk)&&(identical(other.ipaUs, _this.ipaUs) || other.ipaUs == _this.ipaUs)&&(identical(other.partOfSpeech, _this.partOfSpeech) || other.partOfSpeech == _this.partOfSpeech)&&(identical(other.definition, _this.definition) || other.definition == _this.definition)&&(identical(other.example, _this.example) || other.example == _this.example)&&(identical(other.firstNote, _this.firstNote) || other.firstNote == _this.firstNote)&&const DeepCollectionEquality().equals(other.listIds, _this.listIds)&&(identical(other.isFavourite, _this.isFavourite) || other.isFavourite == _this.isFavourite)&&const DeepCollectionEquality().equals(other.acceptedFields, _this.acceptedFields)&&(identical(other.attribution, _this.attribution) || other.attribution == _this.attribution)&&(identical(other.sourceUrl, _this.sourceUrl) || other.sourceUrl == _this.sourceUrl)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as WordDraft;
  return Object.hash(runtimeType,_this.id,_this.headword,_this.ipaUk,_this.ipaUs,_this.partOfSpeech,_this.definition,_this.example,_this.firstNote,const DeepCollectionEquality().hash(_this.listIds),_this.isFavourite,const DeepCollectionEquality().hash(_this.acceptedFields),_this.attribution,_this.sourceUrl,_this.createdAt);
}

@override
String toString() {
  final _this = this as WordDraft;
  return 'WordDraft(id: ${_this.id}, headword: ${_this.headword}, ipaUk: ${_this.ipaUk}, ipaUs: ${_this.ipaUs}, partOfSpeech: ${_this.partOfSpeech}, definition: ${_this.definition}, example: ${_this.example}, firstNote: ${_this.firstNote}, listIds: ${_this.listIds}, isFavourite: ${_this.isFavourite}, acceptedFields: ${_this.acceptedFields}, attribution: ${_this.attribution}, sourceUrl: ${_this.sourceUrl}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $WordDraftCopyWith<$Res>  {
  factory $WordDraftCopyWith(WordDraft value, $Res Function(WordDraft) _then) = _$WordDraftCopyWithImpl;
@useResult
$Res call({
 String? id, String headword, String ipaUk, String ipaUs, String partOfSpeech, String definition, String example, String firstNote, List<String> listIds, bool isFavourite, Map<SuggestionField, WordSource> acceptedFields, String? attribution, String? sourceUrl, DateTime? createdAt
});




}
/// @nodoc
class _$WordDraftCopyWithImpl<$Res>
    implements $WordDraftCopyWith<$Res> {
  _$WordDraftCopyWithImpl(this._self, this._then);

  final WordDraft _self;
  final $Res Function(WordDraft) _then;

/// Create a copy of WordDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? headword = null,Object? ipaUk = null,Object? ipaUs = null,Object? partOfSpeech = null,Object? definition = null,Object? example = null,Object? firstNote = null,Object? listIds = null,Object? isFavourite = null,Object? acceptedFields = null,Object? attribution = freezed,Object? sourceUrl = freezed,Object? createdAt = freezed,}) {
  return _then(WordDraft(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,headword: null == headword ? _self.headword : headword // ignore: cast_nullable_to_non_nullable
as String,ipaUk: null == ipaUk ? _self.ipaUk : ipaUk // ignore: cast_nullable_to_non_nullable
as String,ipaUs: null == ipaUs ? _self.ipaUs : ipaUs // ignore: cast_nullable_to_non_nullable
as String,partOfSpeech: null == partOfSpeech ? _self.partOfSpeech : partOfSpeech // ignore: cast_nullable_to_non_nullable
as String,definition: null == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String,example: null == example ? _self.example : example // ignore: cast_nullable_to_non_nullable
as String,firstNote: null == firstNote ? _self.firstNote : firstNote // ignore: cast_nullable_to_non_nullable
as String,listIds: null == listIds ? _self.listIds : listIds // ignore: cast_nullable_to_non_nullable
as List<String>,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,acceptedFields: null == acceptedFields ? _self.acceptedFields : acceptedFields // ignore: cast_nullable_to_non_nullable
as Map<SuggestionField, WordSource>,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WordDraft].
extension WordDraftPatterns on WordDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordDraft value)  $default,){
final _that = this;
switch (_that) {
case _WordDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordDraft value)?  $default,){
final _that = this;
switch (_that) {
case _WordDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String headword,  String ipaUk,  String ipaUs,  String partOfSpeech,  String definition,  String example,  String firstNote,  List<String> listIds,  bool isFavourite,  Map<SuggestionField, WordSource> acceptedFields,  String? attribution,  String? sourceUrl,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordDraft() when $default != null:
return $default(_that.id,_that.headword,_that.ipaUk,_that.ipaUs,_that.partOfSpeech,_that.definition,_that.example,_that.firstNote,_that.listIds,_that.isFavourite,_that.acceptedFields,_that.attribution,_that.sourceUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String headword,  String ipaUk,  String ipaUs,  String partOfSpeech,  String definition,  String example,  String firstNote,  List<String> listIds,  bool isFavourite,  Map<SuggestionField, WordSource> acceptedFields,  String? attribution,  String? sourceUrl,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _WordDraft():
return $default(_that.id,_that.headword,_that.ipaUk,_that.ipaUs,_that.partOfSpeech,_that.definition,_that.example,_that.firstNote,_that.listIds,_that.isFavourite,_that.acceptedFields,_that.attribution,_that.sourceUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String headword,  String ipaUk,  String ipaUs,  String partOfSpeech,  String definition,  String example,  String firstNote,  List<String> listIds,  bool isFavourite,  Map<SuggestionField, WordSource> acceptedFields,  String? attribution,  String? sourceUrl,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WordDraft() when $default != null:
return $default(_that.id,_that.headword,_that.ipaUk,_that.ipaUs,_that.partOfSpeech,_that.definition,_that.example,_that.firstNote,_that.listIds,_that.isFavourite,_that.acceptedFields,_that.attribution,_that.sourceUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _WordDraft extends WordDraft {
  const _WordDraft({this.id, this.headword = '', this.ipaUk = '', this.ipaUs = '', this.partOfSpeech = '', this.definition = '', this.example = '', this.firstNote = '',  List<String> listIds = const <String>[], this.isFavourite = false,  Map<SuggestionField, WordSource> acceptedFields = const <SuggestionField, WordSource>{}, this.attribution, this.sourceUrl, this.createdAt}): _listIds = listIds,_acceptedFields = acceptedFields,super._();
  

/// The word being edited, or null when adding a new one.
@override final  String? id;
/// As typed. Required, trimmed on save.
@override@JsonKey() final  String headword;
/// British transcription, without slashes.
@override@JsonKey() final  String ipaUk;
/// American transcription, without slashes.
@override@JsonKey() final  String ipaUs;
/// Free text.
@override@JsonKey() final  String partOfSpeech;
/// What it means.
@override@JsonKey() final  String definition;
/// A sentence using it.
@override@JsonKey() final  String example;
/// The first note, offered only when adding.
@override@JsonKey() final  String firstNote;
/// Which lists it goes into.
 final  List<String> _listIds;
/// Which lists it goes into.
@override@JsonKey() List<String> get listIds {
  if (_listIds is EqualUnmodifiableListView) return _listIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_listIds);
}

/// Starred.
@override@JsonKey() final  bool isFavourite;
/// Which fields were accepted from a look-up, and from where.
///
/// Drives both the attribution stored on the word and the "this came from
/// the dictionary" affordance in the form.
 final  Map<SuggestionField, WordSource> _acceptedFields;
/// Which fields were accepted from a look-up, and from where.
///
/// Drives both the attribution stored on the word and the "this came from
/// the dictionary" affordance in the form.
@override@JsonKey() Map<SuggestionField, WordSource> get acceptedFields {
  if (_acceptedFields is EqualUnmodifiableMapView) return _acceptedFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_acceptedFields);
}

/// The credit line for whatever was accepted.
@override final  String? attribution;
/// The source page, stored alongside the attribution.
@override final  String? sourceUrl;
/// When the word was first created. Null for a new one.
@override final  DateTime? createdAt;

/// Create a copy of WordDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordDraftCopyWith<_WordDraft> get copyWith => __$WordDraftCopyWithImpl<_WordDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.headword, headword) || other.headword == headword)&&(identical(other.ipaUk, ipaUk) || other.ipaUk == ipaUk)&&(identical(other.ipaUs, ipaUs) || other.ipaUs == ipaUs)&&(identical(other.partOfSpeech, partOfSpeech) || other.partOfSpeech == partOfSpeech)&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.example, example) || other.example == example)&&(identical(other.firstNote, firstNote) || other.firstNote == firstNote)&&const DeepCollectionEquality().equals(other.listIds, _listIds)&&(identical(other.isFavourite, isFavourite) || other.isFavourite == isFavourite)&&const DeepCollectionEquality().equals(other.acceptedFields, _acceptedFields)&&(identical(other.attribution, attribution) || other.attribution == attribution)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,headword,ipaUk,ipaUs,partOfSpeech,definition,example,firstNote,const DeepCollectionEquality().hash(_listIds),isFavourite,const DeepCollectionEquality().hash(_acceptedFields),attribution,sourceUrl,createdAt);
}

@override
String toString() {
    return 'WordDraft(id: $id, headword: $headword, ipaUk: $ipaUk, ipaUs: $ipaUs, partOfSpeech: $partOfSpeech, definition: $definition, example: $example, firstNote: $firstNote, listIds: $listIds, isFavourite: $isFavourite, acceptedFields: $acceptedFields, attribution: $attribution, sourceUrl: $sourceUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WordDraftCopyWith<$Res> implements $WordDraftCopyWith<$Res> {
  factory _$WordDraftCopyWith(_WordDraft value, $Res Function(_WordDraft) _then) = __$WordDraftCopyWithImpl;
@override @useResult
$Res call({
 String? id, String headword, String ipaUk, String ipaUs, String partOfSpeech, String definition, String example, String firstNote, List<String> listIds, bool isFavourite, Map<SuggestionField, WordSource> acceptedFields, String? attribution, String? sourceUrl, DateTime? createdAt
});




}
/// @nodoc
class __$WordDraftCopyWithImpl<$Res>
    implements _$WordDraftCopyWith<$Res> {
  __$WordDraftCopyWithImpl(this._self, this._then);

  final _WordDraft _self;
  final $Res Function(_WordDraft) _then;

/// Create a copy of WordDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? headword = null,Object? ipaUk = null,Object? ipaUs = null,Object? partOfSpeech = null,Object? definition = null,Object? example = null,Object? firstNote = null,Object? listIds = null,Object? isFavourite = null,Object? acceptedFields = null,Object? attribution = freezed,Object? sourceUrl = freezed,Object? createdAt = freezed,}) {
  return _then(_WordDraft(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,headword: null == headword ? _self.headword : headword // ignore: cast_nullable_to_non_nullable
as String,ipaUk: null == ipaUk ? _self.ipaUk : ipaUk // ignore: cast_nullable_to_non_nullable
as String,ipaUs: null == ipaUs ? _self.ipaUs : ipaUs // ignore: cast_nullable_to_non_nullable
as String,partOfSpeech: null == partOfSpeech ? _self.partOfSpeech : partOfSpeech // ignore: cast_nullable_to_non_nullable
as String,definition: null == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String,example: null == example ? _self.example : example // ignore: cast_nullable_to_non_nullable
as String,firstNote: null == firstNote ? _self.firstNote : firstNote // ignore: cast_nullable_to_non_nullable
as String,listIds: null == listIds ? _self._listIds : listIds // ignore: cast_nullable_to_non_nullable
as List<String>,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,acceptedFields: null == acceptedFields ? _self._acceptedFields : acceptedFields // ignore: cast_nullable_to_non_nullable
as Map<SuggestionField, WordSource>,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
