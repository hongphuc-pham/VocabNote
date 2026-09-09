// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'practice_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PracticeSession {

/// UUID v4.
 String get id;/// Which game ran, e.g. `flashcard`. Stable across releases.
 String get gameId;/// Daily review or quick test.
 PracticeMode get mode;/// Where the cards came from.
 CardSourceKind get sourceKind;/// The full `GameConfig` as JSON. Readers must tolerate unknown keys, so a
/// session recorded by a newer build stays readable.
 String get configJson;/// When the session started.
 DateTime get startedAt;/// Whether this session applied the review schedule.
///
/// Stored rather than recomputed from [mode]: if the rule ever changes,
/// history must still say what actually happened.
 bool get affectsScheduling;/// The list id, when [sourceKind] is [CardSourceKind.list].
 String? get sourceId;/// When the session finished. Null while it is still running, or if the
/// user abandoned it.
 DateTime? get endedAt;/// How many rounds were played.
 int get totalRounds;/// How many were answered `good` or `easy`.
 int get correctRounds;
/// Create a copy of PracticeSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PracticeSessionCopyWith<PracticeSession> get copyWith => _$PracticeSessionCopyWithImpl<PracticeSession>(this as PracticeSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PracticeSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PracticeSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.gameId, _this.gameId) || other.gameId == _this.gameId)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.sourceKind, _this.sourceKind) || other.sourceKind == _this.sourceKind)&&(identical(other.configJson, _this.configJson) || other.configJson == _this.configJson)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.affectsScheduling, _this.affectsScheduling) || other.affectsScheduling == _this.affectsScheduling)&&(identical(other.sourceId, _this.sourceId) || other.sourceId == _this.sourceId)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.totalRounds, _this.totalRounds) || other.totalRounds == _this.totalRounds)&&(identical(other.correctRounds, _this.correctRounds) || other.correctRounds == _this.correctRounds));
}


@override
int get hashCode {
  final _this = this as PracticeSession;
  return Object.hash(runtimeType,_this.id,_this.gameId,_this.mode,_this.sourceKind,_this.configJson,_this.startedAt,_this.affectsScheduling,_this.sourceId,_this.endedAt,_this.totalRounds,_this.correctRounds);
}

@override
String toString() {
  final _this = this as PracticeSession;
  return 'PracticeSession(id: ${_this.id}, gameId: ${_this.gameId}, mode: ${_this.mode}, sourceKind: ${_this.sourceKind}, configJson: ${_this.configJson}, startedAt: ${_this.startedAt}, affectsScheduling: ${_this.affectsScheduling}, sourceId: ${_this.sourceId}, endedAt: ${_this.endedAt}, totalRounds: ${_this.totalRounds}, correctRounds: ${_this.correctRounds})';
}


}

/// @nodoc
abstract mixin class $PracticeSessionCopyWith<$Res>  {
  factory $PracticeSessionCopyWith(PracticeSession value, $Res Function(PracticeSession) _then) = _$PracticeSessionCopyWithImpl;
@useResult
$Res call({
 String id, String gameId, PracticeMode mode, CardSourceKind sourceKind, String configJson, DateTime startedAt, bool affectsScheduling, String? sourceId, DateTime? endedAt, int totalRounds, int correctRounds
});




}
/// @nodoc
class _$PracticeSessionCopyWithImpl<$Res>
    implements $PracticeSessionCopyWith<$Res> {
  _$PracticeSessionCopyWithImpl(this._self, this._then);

  final PracticeSession _self;
  final $Res Function(PracticeSession) _then;

/// Create a copy of PracticeSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gameId = null,Object? mode = null,Object? sourceKind = null,Object? configJson = null,Object? startedAt = null,Object? affectsScheduling = null,Object? sourceId = freezed,Object? endedAt = freezed,Object? totalRounds = null,Object? correctRounds = null,}) {
  return _then(PracticeSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PracticeMode,sourceKind: null == sourceKind ? _self.sourceKind : sourceKind // ignore: cast_nullable_to_non_nullable
as CardSourceKind,configJson: null == configJson ? _self.configJson : configJson // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,affectsScheduling: null == affectsScheduling ? _self.affectsScheduling : affectsScheduling // ignore: cast_nullable_to_non_nullable
as bool,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalRounds: null == totalRounds ? _self.totalRounds : totalRounds // ignore: cast_nullable_to_non_nullable
as int,correctRounds: null == correctRounds ? _self.correctRounds : correctRounds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PracticeSession].
extension PracticeSessionPatterns on PracticeSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PracticeSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PracticeSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PracticeSession value)  $default,){
final _that = this;
switch (_that) {
case _PracticeSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PracticeSession value)?  $default,){
final _that = this;
switch (_that) {
case _PracticeSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gameId,  PracticeMode mode,  CardSourceKind sourceKind,  String configJson,  DateTime startedAt,  bool affectsScheduling,  String? sourceId,  DateTime? endedAt,  int totalRounds,  int correctRounds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PracticeSession() when $default != null:
return $default(_that.id,_that.gameId,_that.mode,_that.sourceKind,_that.configJson,_that.startedAt,_that.affectsScheduling,_that.sourceId,_that.endedAt,_that.totalRounds,_that.correctRounds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gameId,  PracticeMode mode,  CardSourceKind sourceKind,  String configJson,  DateTime startedAt,  bool affectsScheduling,  String? sourceId,  DateTime? endedAt,  int totalRounds,  int correctRounds)  $default,) {final _that = this;
switch (_that) {
case _PracticeSession():
return $default(_that.id,_that.gameId,_that.mode,_that.sourceKind,_that.configJson,_that.startedAt,_that.affectsScheduling,_that.sourceId,_that.endedAt,_that.totalRounds,_that.correctRounds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gameId,  PracticeMode mode,  CardSourceKind sourceKind,  String configJson,  DateTime startedAt,  bool affectsScheduling,  String? sourceId,  DateTime? endedAt,  int totalRounds,  int correctRounds)?  $default,) {final _that = this;
switch (_that) {
case _PracticeSession() when $default != null:
return $default(_that.id,_that.gameId,_that.mode,_that.sourceKind,_that.configJson,_that.startedAt,_that.affectsScheduling,_that.sourceId,_that.endedAt,_that.totalRounds,_that.correctRounds);case _:
  return null;

}
}

}

/// @nodoc


class _PracticeSession extends PracticeSession {
  const _PracticeSession({required this.id, required this.gameId, required this.mode, required this.sourceKind, required this.configJson, required this.startedAt, required this.affectsScheduling, this.sourceId, this.endedAt, this.totalRounds = 0, this.correctRounds = 0}): super._();
  

/// UUID v4.
@override final  String id;
/// Which game ran, e.g. `flashcard`. Stable across releases.
@override final  String gameId;
/// Daily review or quick test.
@override final  PracticeMode mode;
/// Where the cards came from.
@override final  CardSourceKind sourceKind;
/// The full `GameConfig` as JSON. Readers must tolerate unknown keys, so a
/// session recorded by a newer build stays readable.
@override final  String configJson;
/// When the session started.
@override final  DateTime startedAt;
/// Whether this session applied the review schedule.
///
/// Stored rather than recomputed from [mode]: if the rule ever changes,
/// history must still say what actually happened.
@override final  bool affectsScheduling;
/// The list id, when [sourceKind] is [CardSourceKind.list].
@override final  String? sourceId;
/// When the session finished. Null while it is still running, or if the
/// user abandoned it.
@override final  DateTime? endedAt;
/// How many rounds were played.
@override@JsonKey() final  int totalRounds;
/// How many were answered `good` or `easy`.
@override@JsonKey() final  int correctRounds;

/// Create a copy of PracticeSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PracticeSessionCopyWith<_PracticeSession> get copyWith => __$PracticeSessionCopyWithImpl<_PracticeSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PracticeSession&&(identical(other.id, id) || other.id == id)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.sourceKind, sourceKind) || other.sourceKind == sourceKind)&&(identical(other.configJson, configJson) || other.configJson == configJson)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.affectsScheduling, affectsScheduling) || other.affectsScheduling == affectsScheduling)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.totalRounds, totalRounds) || other.totalRounds == totalRounds)&&(identical(other.correctRounds, correctRounds) || other.correctRounds == correctRounds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,gameId,mode,sourceKind,configJson,startedAt,affectsScheduling,sourceId,endedAt,totalRounds,correctRounds);
}

@override
String toString() {
    return 'PracticeSession(id: $id, gameId: $gameId, mode: $mode, sourceKind: $sourceKind, configJson: $configJson, startedAt: $startedAt, affectsScheduling: $affectsScheduling, sourceId: $sourceId, endedAt: $endedAt, totalRounds: $totalRounds, correctRounds: $correctRounds)';
}


}

/// @nodoc
abstract mixin class _$PracticeSessionCopyWith<$Res> implements $PracticeSessionCopyWith<$Res> {
  factory _$PracticeSessionCopyWith(_PracticeSession value, $Res Function(_PracticeSession) _then) = __$PracticeSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String gameId, PracticeMode mode, CardSourceKind sourceKind, String configJson, DateTime startedAt, bool affectsScheduling, String? sourceId, DateTime? endedAt, int totalRounds, int correctRounds
});




}
/// @nodoc
class __$PracticeSessionCopyWithImpl<$Res>
    implements _$PracticeSessionCopyWith<$Res> {
  __$PracticeSessionCopyWithImpl(this._self, this._then);

  final _PracticeSession _self;
  final $Res Function(_PracticeSession) _then;

/// Create a copy of PracticeSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gameId = null,Object? mode = null,Object? sourceKind = null,Object? configJson = null,Object? startedAt = null,Object? affectsScheduling = null,Object? sourceId = freezed,Object? endedAt = freezed,Object? totalRounds = null,Object? correctRounds = null,}) {
  return _then(_PracticeSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PracticeMode,sourceKind: null == sourceKind ? _self.sourceKind : sourceKind // ignore: cast_nullable_to_non_nullable
as CardSourceKind,configJson: null == configJson ? _self.configJson : configJson // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,affectsScheduling: null == affectsScheduling ? _self.affectsScheduling : affectsScheduling // ignore: cast_nullable_to_non_nullable
as bool,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalRounds: null == totalRounds ? _self.totalRounds : totalRounds // ignore: cast_nullable_to_non_nullable
as int,correctRounds: null == correctRounds ? _self.correctRounds : correctRounds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PracticeAnswer {

/// UUID v4.
 String get id;/// The session this answer belongs to. Cascades on delete.
 String get sessionId;/// The word that was asked. Cascades on delete.
 String get wordId;/// Zero-based position within the session.
 int get roundIndex;/// How the user graded it.
 ReviewOutcome get result;/// When it was answered.
 DateTime get answeredAt;/// How long the user took, in milliseconds.
 int? get responseMs;
/// Create a copy of PracticeAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PracticeAnswerCopyWith<PracticeAnswer> get copyWith => _$PracticeAnswerCopyWithImpl<PracticeAnswer>(this as PracticeAnswer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PracticeAnswer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PracticeAnswer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.wordId, _this.wordId) || other.wordId == _this.wordId)&&(identical(other.roundIndex, _this.roundIndex) || other.roundIndex == _this.roundIndex)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.answeredAt, _this.answeredAt) || other.answeredAt == _this.answeredAt)&&(identical(other.responseMs, _this.responseMs) || other.responseMs == _this.responseMs));
}


@override
int get hashCode {
  final _this = this as PracticeAnswer;
  return Object.hash(runtimeType,_this.id,_this.sessionId,_this.wordId,_this.roundIndex,_this.result,_this.answeredAt,_this.responseMs);
}

@override
String toString() {
  final _this = this as PracticeAnswer;
  return 'PracticeAnswer(id: ${_this.id}, sessionId: ${_this.sessionId}, wordId: ${_this.wordId}, roundIndex: ${_this.roundIndex}, result: ${_this.result}, answeredAt: ${_this.answeredAt}, responseMs: ${_this.responseMs})';
}


}

/// @nodoc
abstract mixin class $PracticeAnswerCopyWith<$Res>  {
  factory $PracticeAnswerCopyWith(PracticeAnswer value, $Res Function(PracticeAnswer) _then) = _$PracticeAnswerCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, String wordId, int roundIndex, ReviewOutcome result, DateTime answeredAt, int? responseMs
});




}
/// @nodoc
class _$PracticeAnswerCopyWithImpl<$Res>
    implements $PracticeAnswerCopyWith<$Res> {
  _$PracticeAnswerCopyWithImpl(this._self, this._then);

  final PracticeAnswer _self;
  final $Res Function(PracticeAnswer) _then;

/// Create a copy of PracticeAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? wordId = null,Object? roundIndex = null,Object? result = null,Object? answeredAt = null,Object? responseMs = freezed,}) {
  return _then(PracticeAnswer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,roundIndex: null == roundIndex ? _self.roundIndex : roundIndex // ignore: cast_nullable_to_non_nullable
as int,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ReviewOutcome,answeredAt: null == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,responseMs: freezed == responseMs ? _self.responseMs : responseMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PracticeAnswer].
extension PracticeAnswerPatterns on PracticeAnswer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PracticeAnswer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PracticeAnswer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PracticeAnswer value)  $default,){
final _that = this;
switch (_that) {
case _PracticeAnswer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PracticeAnswer value)?  $default,){
final _that = this;
switch (_that) {
case _PracticeAnswer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  String wordId,  int roundIndex,  ReviewOutcome result,  DateTime answeredAt,  int? responseMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PracticeAnswer() when $default != null:
return $default(_that.id,_that.sessionId,_that.wordId,_that.roundIndex,_that.result,_that.answeredAt,_that.responseMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  String wordId,  int roundIndex,  ReviewOutcome result,  DateTime answeredAt,  int? responseMs)  $default,) {final _that = this;
switch (_that) {
case _PracticeAnswer():
return $default(_that.id,_that.sessionId,_that.wordId,_that.roundIndex,_that.result,_that.answeredAt,_that.responseMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  String wordId,  int roundIndex,  ReviewOutcome result,  DateTime answeredAt,  int? responseMs)?  $default,) {final _that = this;
switch (_that) {
case _PracticeAnswer() when $default != null:
return $default(_that.id,_that.sessionId,_that.wordId,_that.roundIndex,_that.result,_that.answeredAt,_that.responseMs);case _:
  return null;

}
}

}

/// @nodoc


class _PracticeAnswer extends PracticeAnswer {
  const _PracticeAnswer({required this.id, required this.sessionId, required this.wordId, required this.roundIndex, required this.result, required this.answeredAt, this.responseMs}): super._();
  

/// UUID v4.
@override final  String id;
/// The session this answer belongs to. Cascades on delete.
@override final  String sessionId;
/// The word that was asked. Cascades on delete.
@override final  String wordId;
/// Zero-based position within the session.
@override final  int roundIndex;
/// How the user graded it.
@override final  ReviewOutcome result;
/// When it was answered.
@override final  DateTime answeredAt;
/// How long the user took, in milliseconds.
@override final  int? responseMs;

/// Create a copy of PracticeAnswer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PracticeAnswerCopyWith<_PracticeAnswer> get copyWith => __$PracticeAnswerCopyWithImpl<_PracticeAnswer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PracticeAnswer&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.roundIndex, roundIndex) || other.roundIndex == roundIndex)&&(identical(other.result, result) || other.result == result)&&(identical(other.answeredAt, answeredAt) || other.answeredAt == answeredAt)&&(identical(other.responseMs, responseMs) || other.responseMs == responseMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,sessionId,wordId,roundIndex,result,answeredAt,responseMs);
}

@override
String toString() {
    return 'PracticeAnswer(id: $id, sessionId: $sessionId, wordId: $wordId, roundIndex: $roundIndex, result: $result, answeredAt: $answeredAt, responseMs: $responseMs)';
}


}

/// @nodoc
abstract mixin class _$PracticeAnswerCopyWith<$Res> implements $PracticeAnswerCopyWith<$Res> {
  factory _$PracticeAnswerCopyWith(_PracticeAnswer value, $Res Function(_PracticeAnswer) _then) = __$PracticeAnswerCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, String wordId, int roundIndex, ReviewOutcome result, DateTime answeredAt, int? responseMs
});




}
/// @nodoc
class __$PracticeAnswerCopyWithImpl<$Res>
    implements _$PracticeAnswerCopyWith<$Res> {
  __$PracticeAnswerCopyWithImpl(this._self, this._then);

  final _PracticeAnswer _self;
  final $Res Function(_PracticeAnswer) _then;

/// Create a copy of PracticeAnswer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? wordId = null,Object? roundIndex = null,Object? result = null,Object? answeredAt = null,Object? responseMs = freezed,}) {
  return _then(_PracticeAnswer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,roundIndex: null == roundIndex ? _self.roundIndex : roundIndex // ignore: cast_nullable_to_non_nullable
as int,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as ReviewOutcome,answeredAt: null == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,responseMs: freezed == responseMs ? _self.responseMs : responseMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
