// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Word {

/// UUID v4, so exports from two devices can be merged without collisions.
 String get id;/// What the user typed, plus the normalised form used for dedupe.
 Headword get headword;/// When the row was first written.
 DateTime get createdAt;/// When it last changed. Import merge resolves conflicts on this
/// (`DATABASE.md` §5: newer `updated_at` wins).
 DateTime get updatedAt;/// Free text: noun, verb, adjective, or whatever the user prefers.
 String? get partOfSpeech;/// British transcription, without slashes.
 Ipa? get ipaUk;/// American transcription, without slashes.
 Ipa? get ipaUs;/// What the word means.
 String? get definition;/// A sentence using it.
 String? get example;/// Where the content came from.
 WordSource get source;/// The credit line and source URL, when one is owed.
 String? get sourceAttribution;/// Starred by the user (F-044).
 bool get isFavourite;/// Hidden from lists but kept in stats (F-045).
 bool get isArchived;/// Set when soft-deleted; purged 30 days later (F-008, RULES §10).
 DateTime? get deletedAt;
/// Create a copy of Word
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordCopyWith<Word> get copyWith => _$WordCopyWithImpl<Word>(this as Word, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Word;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Word&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.headword, _this.headword) || other.headword == _this.headword)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.partOfSpeech, _this.partOfSpeech) || other.partOfSpeech == _this.partOfSpeech)&&(identical(other.ipaUk, _this.ipaUk) || other.ipaUk == _this.ipaUk)&&(identical(other.ipaUs, _this.ipaUs) || other.ipaUs == _this.ipaUs)&&(identical(other.definition, _this.definition) || other.definition == _this.definition)&&(identical(other.example, _this.example) || other.example == _this.example)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.sourceAttribution, _this.sourceAttribution) || other.sourceAttribution == _this.sourceAttribution)&&(identical(other.isFavourite, _this.isFavourite) || other.isFavourite == _this.isFavourite)&&(identical(other.isArchived, _this.isArchived) || other.isArchived == _this.isArchived)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}


@override
int get hashCode {
  final _this = this as Word;
  return Object.hash(runtimeType,_this.id,_this.headword,_this.createdAt,_this.updatedAt,_this.partOfSpeech,_this.ipaUk,_this.ipaUs,_this.definition,_this.example,_this.source,_this.sourceAttribution,_this.isFavourite,_this.isArchived,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Word;
  return 'Word(id: ${_this.id}, headword: ${_this.headword}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, partOfSpeech: ${_this.partOfSpeech}, ipaUk: ${_this.ipaUk}, ipaUs: ${_this.ipaUs}, definition: ${_this.definition}, example: ${_this.example}, source: ${_this.source}, sourceAttribution: ${_this.sourceAttribution}, isFavourite: ${_this.isFavourite}, isArchived: ${_this.isArchived}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $WordCopyWith<$Res>  {
  factory $WordCopyWith(Word value, $Res Function(Word) _then) = _$WordCopyWithImpl;
@useResult
$Res call({
 String id, Headword headword, DateTime createdAt, DateTime updatedAt, String? partOfSpeech, Ipa? ipaUk, Ipa? ipaUs, String? definition, String? example, WordSource source, String? sourceAttribution, bool isFavourite, bool isArchived, DateTime? deletedAt
});




}
/// @nodoc
class _$WordCopyWithImpl<$Res>
    implements $WordCopyWith<$Res> {
  _$WordCopyWithImpl(this._self, this._then);

  final Word _self;
  final $Res Function(Word) _then;

/// Create a copy of Word
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? headword = null,Object? createdAt = null,Object? updatedAt = null,Object? partOfSpeech = freezed,Object? ipaUk = freezed,Object? ipaUs = freezed,Object? definition = freezed,Object? example = freezed,Object? source = null,Object? sourceAttribution = freezed,Object? isFavourite = null,Object? isArchived = null,Object? deletedAt = freezed,}) {
  return _then(Word(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,headword: null == headword ? _self.headword : headword // ignore: cast_nullable_to_non_nullable
as Headword,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,partOfSpeech: freezed == partOfSpeech ? _self.partOfSpeech : partOfSpeech // ignore: cast_nullable_to_non_nullable
as String?,ipaUk: freezed == ipaUk ? _self.ipaUk : ipaUk // ignore: cast_nullable_to_non_nullable
as Ipa?,ipaUs: freezed == ipaUs ? _self.ipaUs : ipaUs // ignore: cast_nullable_to_non_nullable
as Ipa?,definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,example: freezed == example ? _self.example : example // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WordSource,sourceAttribution: freezed == sourceAttribution ? _self.sourceAttribution : sourceAttribution // ignore: cast_nullable_to_non_nullable
as String?,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Word].
extension WordPatterns on Word {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Word value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Word() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Word value)  $default,){
final _that = this;
switch (_that) {
case _Word():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Word value)?  $default,){
final _that = this;
switch (_that) {
case _Word() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Headword headword,  DateTime createdAt,  DateTime updatedAt,  String? partOfSpeech,  Ipa? ipaUk,  Ipa? ipaUs,  String? definition,  String? example,  WordSource source,  String? sourceAttribution,  bool isFavourite,  bool isArchived,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Word() when $default != null:
return $default(_that.id,_that.headword,_that.createdAt,_that.updatedAt,_that.partOfSpeech,_that.ipaUk,_that.ipaUs,_that.definition,_that.example,_that.source,_that.sourceAttribution,_that.isFavourite,_that.isArchived,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Headword headword,  DateTime createdAt,  DateTime updatedAt,  String? partOfSpeech,  Ipa? ipaUk,  Ipa? ipaUs,  String? definition,  String? example,  WordSource source,  String? sourceAttribution,  bool isFavourite,  bool isArchived,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Word():
return $default(_that.id,_that.headword,_that.createdAt,_that.updatedAt,_that.partOfSpeech,_that.ipaUk,_that.ipaUs,_that.definition,_that.example,_that.source,_that.sourceAttribution,_that.isFavourite,_that.isArchived,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Headword headword,  DateTime createdAt,  DateTime updatedAt,  String? partOfSpeech,  Ipa? ipaUk,  Ipa? ipaUs,  String? definition,  String? example,  WordSource source,  String? sourceAttribution,  bool isFavourite,  bool isArchived,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Word() when $default != null:
return $default(_that.id,_that.headword,_that.createdAt,_that.updatedAt,_that.partOfSpeech,_that.ipaUk,_that.ipaUs,_that.definition,_that.example,_that.source,_that.sourceAttribution,_that.isFavourite,_that.isArchived,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Word extends Word {
  const _Word({required this.id, required this.headword, required this.createdAt, required this.updatedAt, this.partOfSpeech, this.ipaUk, this.ipaUs, this.definition, this.example, this.source = WordSource.manual, this.sourceAttribution, this.isFavourite = false, this.isArchived = false, this.deletedAt}): super._();
  

/// UUID v4, so exports from two devices can be merged without collisions.
@override final  String id;
/// What the user typed, plus the normalised form used for dedupe.
@override final  Headword headword;
/// When the row was first written.
@override final  DateTime createdAt;
/// When it last changed. Import merge resolves conflicts on this
/// (`DATABASE.md` §5: newer `updated_at` wins).
@override final  DateTime updatedAt;
/// Free text: noun, verb, adjective, or whatever the user prefers.
@override final  String? partOfSpeech;
/// British transcription, without slashes.
@override final  Ipa? ipaUk;
/// American transcription, without slashes.
@override final  Ipa? ipaUs;
/// What the word means.
@override final  String? definition;
/// A sentence using it.
@override final  String? example;
/// Where the content came from.
@override@JsonKey() final  WordSource source;
/// The credit line and source URL, when one is owed.
@override final  String? sourceAttribution;
/// Starred by the user (F-044).
@override@JsonKey() final  bool isFavourite;
/// Hidden from lists but kept in stats (F-045).
@override@JsonKey() final  bool isArchived;
/// Set when soft-deleted; purged 30 days later (F-008, RULES §10).
@override final  DateTime? deletedAt;

/// Create a copy of Word
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordCopyWith<_Word> get copyWith => __$WordCopyWithImpl<_Word>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Word&&(identical(other.id, id) || other.id == id)&&(identical(other.headword, headword) || other.headword == headword)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.partOfSpeech, partOfSpeech) || other.partOfSpeech == partOfSpeech)&&(identical(other.ipaUk, ipaUk) || other.ipaUk == ipaUk)&&(identical(other.ipaUs, ipaUs) || other.ipaUs == ipaUs)&&(identical(other.definition, definition) || other.definition == definition)&&(identical(other.example, example) || other.example == example)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceAttribution, sourceAttribution) || other.sourceAttribution == sourceAttribution)&&(identical(other.isFavourite, isFavourite) || other.isFavourite == isFavourite)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,headword,createdAt,updatedAt,partOfSpeech,ipaUk,ipaUs,definition,example,source,sourceAttribution,isFavourite,isArchived,deletedAt);
}

@override
String toString() {
    return 'Word(id: $id, headword: $headword, createdAt: $createdAt, updatedAt: $updatedAt, partOfSpeech: $partOfSpeech, ipaUk: $ipaUk, ipaUs: $ipaUs, definition: $definition, example: $example, source: $source, sourceAttribution: $sourceAttribution, isFavourite: $isFavourite, isArchived: $isArchived, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$WordCopyWith<$Res> implements $WordCopyWith<$Res> {
  factory _$WordCopyWith(_Word value, $Res Function(_Word) _then) = __$WordCopyWithImpl;
@override @useResult
$Res call({
 String id, Headword headword, DateTime createdAt, DateTime updatedAt, String? partOfSpeech, Ipa? ipaUk, Ipa? ipaUs, String? definition, String? example, WordSource source, String? sourceAttribution, bool isFavourite, bool isArchived, DateTime? deletedAt
});




}
/// @nodoc
class __$WordCopyWithImpl<$Res>
    implements _$WordCopyWith<$Res> {
  __$WordCopyWithImpl(this._self, this._then);

  final _Word _self;
  final $Res Function(_Word) _then;

/// Create a copy of Word
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? headword = null,Object? createdAt = null,Object? updatedAt = null,Object? partOfSpeech = freezed,Object? ipaUk = freezed,Object? ipaUs = freezed,Object? definition = freezed,Object? example = freezed,Object? source = null,Object? sourceAttribution = freezed,Object? isFavourite = null,Object? isArchived = null,Object? deletedAt = freezed,}) {
  return _then(_Word(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,headword: null == headword ? _self.headword : headword // ignore: cast_nullable_to_non_nullable
as Headword,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,partOfSpeech: freezed == partOfSpeech ? _self.partOfSpeech : partOfSpeech // ignore: cast_nullable_to_non_nullable
as String?,ipaUk: freezed == ipaUk ? _self.ipaUk : ipaUk // ignore: cast_nullable_to_non_nullable
as Ipa?,ipaUs: freezed == ipaUs ? _self.ipaUs : ipaUs // ignore: cast_nullable_to_non_nullable
as Ipa?,definition: freezed == definition ? _self.definition : definition // ignore: cast_nullable_to_non_nullable
as String?,example: freezed == example ? _self.example : example // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as WordSource,sourceAttribution: freezed == sourceAttribution ? _self.sourceAttribution : sourceAttribution // ignore: cast_nullable_to_non_nullable
as String?,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
