// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WordNote {

/// UUID v4.
 String get id;/// The word this note belongs to. Cascades on delete.
 String get wordId;/// What the user wrote.
 String get body;/// When it was written - shown as "3 Sep" on the detail screen.
 DateTime get createdAt;/// When it was last edited.
 DateTime get updatedAt;/// Pinned notes sort above the rest (M4).
 bool get pinned;
/// Create a copy of WordNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordNoteCopyWith<WordNote> get copyWith => _$WordNoteCopyWithImpl<WordNote>(this as WordNote, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WordNote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordNote&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.pinned, _this.pinned) || other.pinned == _this.pinned));
}


@override
int get hashCode {
  final _this = this as WordNote;
  return Object.hash(runtimeType,_this.id,_this.wordId,_this.body,_this.createdAt,_this.updatedAt,_this.pinned);
}

@override
String toString() {
  final _this = this as WordNote;
  return 'WordNote(id: ${_this.id}, wordId: ${_this.wordId}, body: ${_this.body}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, pinned: ${_this.pinned})';
}


}

/// @nodoc
abstract mixin class $WordNoteCopyWith<$Res>  {
  factory $WordNoteCopyWith(WordNote value, $Res Function(WordNote) _then) = _$WordNoteCopyWithImpl;
@useResult
$Res call({
 String id, String wordId, String body, DateTime createdAt, DateTime updatedAt, bool pinned
});




}
/// @nodoc
class _$WordNoteCopyWithImpl<$Res>
    implements $WordNoteCopyWith<$Res> {
  _$WordNoteCopyWithImpl(this._self, this._then);

  final WordNote _self;
  final $Res Function(WordNote) _then;

/// Create a copy of WordNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? wordId = null,Object? body = null,Object? createdAt = null,Object? updatedAt = null,Object? pinned = null,}) {
  return _then(WordNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WordNote].
extension WordNotePatterns on WordNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordNote value)  $default,){
final _that = this;
switch (_that) {
case _WordNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordNote value)?  $default,){
final _that = this;
switch (_that) {
case _WordNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String wordId,  String body,  DateTime createdAt,  DateTime updatedAt,  bool pinned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordNote() when $default != null:
return $default(_that.id,_that.wordId,_that.body,_that.createdAt,_that.updatedAt,_that.pinned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String wordId,  String body,  DateTime createdAt,  DateTime updatedAt,  bool pinned)  $default,) {final _that = this;
switch (_that) {
case _WordNote():
return $default(_that.id,_that.wordId,_that.body,_that.createdAt,_that.updatedAt,_that.pinned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String wordId,  String body,  DateTime createdAt,  DateTime updatedAt,  bool pinned)?  $default,) {final _that = this;
switch (_that) {
case _WordNote() when $default != null:
return $default(_that.id,_that.wordId,_that.body,_that.createdAt,_that.updatedAt,_that.pinned);case _:
  return null;

}
}

}

/// @nodoc


class _WordNote extends WordNote {
  const _WordNote({required this.id, required this.wordId, required this.body, required this.createdAt, required this.updatedAt, this.pinned = false}): super._();
  

/// UUID v4.
@override final  String id;
/// The word this note belongs to. Cascades on delete.
@override final  String wordId;
/// What the user wrote.
@override final  String body;
/// When it was written - shown as "3 Sep" on the detail screen.
@override final  DateTime createdAt;
/// When it was last edited.
@override final  DateTime updatedAt;
/// Pinned notes sort above the rest (M4).
@override@JsonKey() final  bool pinned;

/// Create a copy of WordNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordNoteCopyWith<_WordNote> get copyWith => __$WordNoteCopyWithImpl<_WordNote>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordNote&&(identical(other.id, id) || other.id == id)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.pinned, pinned) || other.pinned == pinned));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,wordId,body,createdAt,updatedAt,pinned);
}

@override
String toString() {
    return 'WordNote(id: $id, wordId: $wordId, body: $body, createdAt: $createdAt, updatedAt: $updatedAt, pinned: $pinned)';
}


}

/// @nodoc
abstract mixin class _$WordNoteCopyWith<$Res> implements $WordNoteCopyWith<$Res> {
  factory _$WordNoteCopyWith(_WordNote value, $Res Function(_WordNote) _then) = __$WordNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String wordId, String body, DateTime createdAt, DateTime updatedAt, bool pinned
});




}
/// @nodoc
class __$WordNoteCopyWithImpl<$Res>
    implements _$WordNoteCopyWith<$Res> {
  __$WordNoteCopyWithImpl(this._self, this._then);

  final _WordNote _self;
  final $Res Function(_WordNote) _then;

/// Create a copy of WordNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? wordId = null,Object? body = null,Object? createdAt = null,Object? updatedAt = null,Object? pinned = null,}) {
  return _then(_WordNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pinned: null == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
