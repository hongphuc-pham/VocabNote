// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StudyCard {

/// The word this card is for. Also the primary key.
 String get wordId;/// When the card next comes up for review.
 DateTime get dueAt;/// Leitner box, 0-6 (`docs/GAMES.md` §5).
 int get box;/// The interval that produced [dueAt], in days. 0 means same-day.
 int get intervalDays;/// SM-2 ease. Present but unused in v1; do not read it into any v1 logic.
 double get easeFactor;/// How many times the card has been reviewed.
 int get repetitions;/// How many times the user has answered `again` on it.
 int get lapses;/// When it was last reviewed.
 DateTime? get lastReviewedAt;/// How it was last graded.
 ReviewOutcome? get lastResult;/// Suspended cards never appear in a due pool.
 bool get suspended;
/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudyCardCopyWith<StudyCard> get copyWith => _$StudyCardCopyWithImpl<StudyCard>(this as StudyCard, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StudyCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudyCard&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.dueAt, _this.dueAt) || other.dueAt == _this.dueAt)&&(identical(other.box, _this.box) || other.box == _this.box)&&(identical(other.intervalDays, _this.intervalDays) || other.intervalDays == _this.intervalDays)&&(identical(other.easeFactor, _this.easeFactor) || other.easeFactor == _this.easeFactor)&&(identical(other.repetitions, _this.repetitions) || other.repetitions == _this.repetitions)&&(identical(other.lapses, _this.lapses) || other.lapses == _this.lapses)&&(identical(other.lastReviewedAt, _this.lastReviewedAt) || other.lastReviewedAt == _this.lastReviewedAt)&&(identical(other.lastResult, _this.lastResult) || other.lastResult == _this.lastResult)&&(identical(other.suspended, _this.suspended) || other.suspended == _this.suspended));
}


@override
int get hashCode {
  final _this = this as StudyCard;
  return Object.hash(runtimeType,_this.wordId,_this.dueAt,_this.box,_this.intervalDays,_this.easeFactor,_this.repetitions,_this.lapses,_this.lastReviewedAt,_this.lastResult,_this.suspended);
}

@override
String toString() {
  final _this = this as StudyCard;
  return 'StudyCard(wordId: ${_this.wordId}, dueAt: ${_this.dueAt}, box: ${_this.box}, intervalDays: ${_this.intervalDays}, easeFactor: ${_this.easeFactor}, repetitions: ${_this.repetitions}, lapses: ${_this.lapses}, lastReviewedAt: ${_this.lastReviewedAt}, lastResult: ${_this.lastResult}, suspended: ${_this.suspended})';
}


}

/// @nodoc
abstract mixin class $StudyCardCopyWith<$Res>  {
  factory $StudyCardCopyWith(StudyCard value, $Res Function(StudyCard) _then) = _$StudyCardCopyWithImpl;
@useResult
$Res call({
 String wordId, DateTime dueAt, int box, int intervalDays, double easeFactor, int repetitions, int lapses, DateTime? lastReviewedAt, ReviewOutcome? lastResult, bool suspended
});




}
/// @nodoc
class _$StudyCardCopyWithImpl<$Res>
    implements $StudyCardCopyWith<$Res> {
  _$StudyCardCopyWithImpl(this._self, this._then);

  final StudyCard _self;
  final $Res Function(StudyCard) _then;

/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wordId = null,Object? dueAt = null,Object? box = null,Object? intervalDays = null,Object? easeFactor = null,Object? repetitions = null,Object? lapses = null,Object? lastReviewedAt = freezed,Object? lastResult = freezed,Object? suspended = null,}) {
  return _then(StudyCard(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as int,intervalDays: null == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int,easeFactor: null == easeFactor ? _self.easeFactor : easeFactor // ignore: cast_nullable_to_non_nullable
as double,repetitions: null == repetitions ? _self.repetitions : repetitions // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,lastReviewedAt: freezed == lastReviewedAt ? _self.lastReviewedAt : lastReviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as ReviewOutcome?,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StudyCard].
extension StudyCardPatterns on StudyCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudyCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudyCard value)  $default,){
final _that = this;
switch (_that) {
case _StudyCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudyCard value)?  $default,){
final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String wordId,  DateTime dueAt,  int box,  int intervalDays,  double easeFactor,  int repetitions,  int lapses,  DateTime? lastReviewedAt,  ReviewOutcome? lastResult,  bool suspended)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
return $default(_that.wordId,_that.dueAt,_that.box,_that.intervalDays,_that.easeFactor,_that.repetitions,_that.lapses,_that.lastReviewedAt,_that.lastResult,_that.suspended);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String wordId,  DateTime dueAt,  int box,  int intervalDays,  double easeFactor,  int repetitions,  int lapses,  DateTime? lastReviewedAt,  ReviewOutcome? lastResult,  bool suspended)  $default,) {final _that = this;
switch (_that) {
case _StudyCard():
return $default(_that.wordId,_that.dueAt,_that.box,_that.intervalDays,_that.easeFactor,_that.repetitions,_that.lapses,_that.lastReviewedAt,_that.lastResult,_that.suspended);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String wordId,  DateTime dueAt,  int box,  int intervalDays,  double easeFactor,  int repetitions,  int lapses,  DateTime? lastReviewedAt,  ReviewOutcome? lastResult,  bool suspended)?  $default,) {final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
return $default(_that.wordId,_that.dueAt,_that.box,_that.intervalDays,_that.easeFactor,_that.repetitions,_that.lapses,_that.lastReviewedAt,_that.lastResult,_that.suspended);case _:
  return null;

}
}

}

/// @nodoc


class _StudyCard extends StudyCard {
  const _StudyCard({required this.wordId, required this.dueAt, this.box = 0, this.intervalDays = 0, this.easeFactor = 2.5, this.repetitions = 0, this.lapses = 0, this.lastReviewedAt, this.lastResult, this.suspended = false}): super._();
  

/// The word this card is for. Also the primary key.
@override final  String wordId;
/// When the card next comes up for review.
@override final  DateTime dueAt;
/// Leitner box, 0-6 (`docs/GAMES.md` §5).
@override@JsonKey() final  int box;
/// The interval that produced [dueAt], in days. 0 means same-day.
@override@JsonKey() final  int intervalDays;
/// SM-2 ease. Present but unused in v1; do not read it into any v1 logic.
@override@JsonKey() final  double easeFactor;
/// How many times the card has been reviewed.
@override@JsonKey() final  int repetitions;
/// How many times the user has answered `again` on it.
@override@JsonKey() final  int lapses;
/// When it was last reviewed.
@override final  DateTime? lastReviewedAt;
/// How it was last graded.
@override final  ReviewOutcome? lastResult;
/// Suspended cards never appear in a due pool.
@override@JsonKey() final  bool suspended;

/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudyCardCopyWith<_StudyCard> get copyWith => __$StudyCardCopyWithImpl<_StudyCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudyCard&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.box, box) || other.box == box)&&(identical(other.intervalDays, intervalDays) || other.intervalDays == intervalDays)&&(identical(other.easeFactor, easeFactor) || other.easeFactor == easeFactor)&&(identical(other.repetitions, repetitions) || other.repetitions == repetitions)&&(identical(other.lapses, lapses) || other.lapses == lapses)&&(identical(other.lastReviewedAt, lastReviewedAt) || other.lastReviewedAt == lastReviewedAt)&&(identical(other.lastResult, lastResult) || other.lastResult == lastResult)&&(identical(other.suspended, suspended) || other.suspended == suspended));
}


@override
int get hashCode {
    return Object.hash(runtimeType,wordId,dueAt,box,intervalDays,easeFactor,repetitions,lapses,lastReviewedAt,lastResult,suspended);
}

@override
String toString() {
    return 'StudyCard(wordId: $wordId, dueAt: $dueAt, box: $box, intervalDays: $intervalDays, easeFactor: $easeFactor, repetitions: $repetitions, lapses: $lapses, lastReviewedAt: $lastReviewedAt, lastResult: $lastResult, suspended: $suspended)';
}


}

/// @nodoc
abstract mixin class _$StudyCardCopyWith<$Res> implements $StudyCardCopyWith<$Res> {
  factory _$StudyCardCopyWith(_StudyCard value, $Res Function(_StudyCard) _then) = __$StudyCardCopyWithImpl;
@override @useResult
$Res call({
 String wordId, DateTime dueAt, int box, int intervalDays, double easeFactor, int repetitions, int lapses, DateTime? lastReviewedAt, ReviewOutcome? lastResult, bool suspended
});




}
/// @nodoc
class __$StudyCardCopyWithImpl<$Res>
    implements _$StudyCardCopyWith<$Res> {
  __$StudyCardCopyWithImpl(this._self, this._then);

  final _StudyCard _self;
  final $Res Function(_StudyCard) _then;

/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wordId = null,Object? dueAt = null,Object? box = null,Object? intervalDays = null,Object? easeFactor = null,Object? repetitions = null,Object? lapses = null,Object? lastReviewedAt = freezed,Object? lastResult = freezed,Object? suspended = null,}) {
  return _then(_StudyCard(
wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,dueAt: null == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as int,intervalDays: null == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int,easeFactor: null == easeFactor ? _self.easeFactor : easeFactor // ignore: cast_nullable_to_non_nullable
as double,repetitions: null == repetitions ? _self.repetitions : repetitions // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,lastReviewedAt: freezed == lastReviewedAt ? _self.lastReviewedAt : lastReviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as ReviewOutcome?,suspended: null == suspended ? _self.suspended : suspended // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
