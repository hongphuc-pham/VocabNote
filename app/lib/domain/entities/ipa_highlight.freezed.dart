// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ipa_highlight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IpaHighlight {

/// UUID v4.
 String get id;/// The word this highlight belongs to. Cascades on delete.
 String get wordId;/// Which transcription it marks.
 HighlightTarget get target;/// The run of symbols, in grapheme-cluster offsets.
 GraphemeRange get range;/// One of the five palette tokens - stored by name, never as a hex value,
/// so a theme change repaints existing highlights.
 IpaColorToken get color;/// When it was created.
 DateTime get createdAt;/// The user's note on this run, e.g. "I say /s/ here". Max 40 characters
/// (`UI-UX.md` §4.4).
 String? get label;
/// Create a copy of IpaHighlight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpaHighlightCopyWith<IpaHighlight> get copyWith => _$IpaHighlightCopyWithImpl<IpaHighlight>(this as IpaHighlight, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IpaHighlight;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpaHighlight&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.range, _this.range) || other.range == _this.range)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.label, _this.label) || other.label == _this.label));
}


@override
int get hashCode {
  final _this = this as IpaHighlight;
  return Object.hash(runtimeType,_this.id,_this.wordId,_this.target,_this.range,_this.color,_this.createdAt,_this.label);
}

@override
String toString() {
  final _this = this as IpaHighlight;
  return 'IpaHighlight(id: ${_this.id}, wordId: ${_this.wordId}, target: ${_this.target}, range: ${_this.range}, color: ${_this.color}, createdAt: ${_this.createdAt}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $IpaHighlightCopyWith<$Res>  {
  factory $IpaHighlightCopyWith(IpaHighlight value, $Res Function(IpaHighlight) _then) = _$IpaHighlightCopyWithImpl;
@useResult
$Res call({
 String id, String wordId, HighlightTarget target, GraphemeRange range, IpaColorToken color, DateTime createdAt, String? label
});




}
/// @nodoc
class _$IpaHighlightCopyWithImpl<$Res>
    implements $IpaHighlightCopyWith<$Res> {
  _$IpaHighlightCopyWithImpl(this._self, this._then);

  final IpaHighlight _self;
  final $Res Function(IpaHighlight) _then;

/// Create a copy of IpaHighlight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? wordId = null,Object? target = null,Object? range = null,Object? color = null,Object? createdAt = null,Object? label = freezed,}) {
  return _then(IpaHighlight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as HighlightTarget,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as GraphemeRange,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as IpaColorToken,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IpaHighlight].
extension IpaHighlightPatterns on IpaHighlight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpaHighlight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpaHighlight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpaHighlight value)  $default,){
final _that = this;
switch (_that) {
case _IpaHighlight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpaHighlight value)?  $default,){
final _that = this;
switch (_that) {
case _IpaHighlight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String wordId,  HighlightTarget target,  GraphemeRange range,  IpaColorToken color,  DateTime createdAt,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpaHighlight() when $default != null:
return $default(_that.id,_that.wordId,_that.target,_that.range,_that.color,_that.createdAt,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String wordId,  HighlightTarget target,  GraphemeRange range,  IpaColorToken color,  DateTime createdAt,  String? label)  $default,) {final _that = this;
switch (_that) {
case _IpaHighlight():
return $default(_that.id,_that.wordId,_that.target,_that.range,_that.color,_that.createdAt,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String wordId,  HighlightTarget target,  GraphemeRange range,  IpaColorToken color,  DateTime createdAt,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _IpaHighlight() when $default != null:
return $default(_that.id,_that.wordId,_that.target,_that.range,_that.color,_that.createdAt,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _IpaHighlight extends IpaHighlight {
  const _IpaHighlight({required this.id, required this.wordId, required this.target, required this.range, required this.color, required this.createdAt, this.label}): super._();
  

/// UUID v4.
@override final  String id;
/// The word this highlight belongs to. Cascades on delete.
@override final  String wordId;
/// Which transcription it marks.
@override final  HighlightTarget target;
/// The run of symbols, in grapheme-cluster offsets.
@override final  GraphemeRange range;
/// One of the five palette tokens - stored by name, never as a hex value,
/// so a theme change repaints existing highlights.
@override final  IpaColorToken color;
/// When it was created.
@override final  DateTime createdAt;
/// The user's note on this run, e.g. "I say /s/ here". Max 40 characters
/// (`UI-UX.md` §4.4).
@override final  String? label;

/// Create a copy of IpaHighlight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpaHighlightCopyWith<_IpaHighlight> get copyWith => __$IpaHighlightCopyWithImpl<_IpaHighlight>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpaHighlight&&(identical(other.id, id) || other.id == id)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.target, target) || other.target == target)&&(identical(other.range, range) || other.range == range)&&(identical(other.color, color) || other.color == color)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,wordId,target,range,color,createdAt,label);
}

@override
String toString() {
    return 'IpaHighlight(id: $id, wordId: $wordId, target: $target, range: $range, color: $color, createdAt: $createdAt, label: $label)';
}


}

/// @nodoc
abstract mixin class _$IpaHighlightCopyWith<$Res> implements $IpaHighlightCopyWith<$Res> {
  factory _$IpaHighlightCopyWith(_IpaHighlight value, $Res Function(_IpaHighlight) _then) = __$IpaHighlightCopyWithImpl;
@override @useResult
$Res call({
 String id, String wordId, HighlightTarget target, GraphemeRange range, IpaColorToken color, DateTime createdAt, String? label
});




}
/// @nodoc
class __$IpaHighlightCopyWithImpl<$Res>
    implements _$IpaHighlightCopyWith<$Res> {
  __$IpaHighlightCopyWithImpl(this._self, this._then);

  final _IpaHighlight _self;
  final $Res Function(_IpaHighlight) _then;

/// Create a copy of IpaHighlight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? wordId = null,Object? target = null,Object? range = null,Object? color = null,Object? createdAt = null,Object? label = freezed,}) {
  return _then(_IpaHighlight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as HighlightTarget,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as GraphemeRange,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as IpaColorToken,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
