// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lookup_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LookupState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LookupState()';
}


}

/// @nodoc
class $LookupStateCopyWith<$Res>  {
$LookupStateCopyWith(LookupState _, $Res Function(LookupState) __);
}


/// Adds pattern-matching-related methods to [LookupState].
extension LookupStatePatterns on LookupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LookupIdle value)?  idle,TResult Function( LookupLoading value)?  loading,TResult Function( LookupResults value)?  results,TResult Function( LookupFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LookupIdle() when idle != null:
return idle(_that);case LookupLoading() when loading != null:
return loading(_that);case LookupResults() when results != null:
return results(_that);case LookupFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LookupIdle value)  idle,required TResult Function( LookupLoading value)  loading,required TResult Function( LookupResults value)  results,required TResult Function( LookupFailed value)  failed,}){
final _that = this;
switch (_that) {
case LookupIdle():
return idle(_that);case LookupLoading():
return loading(_that);case LookupResults():
return results(_that);case LookupFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LookupIdle value)?  idle,TResult? Function( LookupLoading value)?  loading,TResult? Function( LookupResults value)?  results,TResult? Function( LookupFailed value)?  failed,}){
final _that = this;
switch (_that) {
case LookupIdle() when idle != null:
return idle(_that);case LookupLoading() when loading != null:
return loading(_that);case LookupResults() when results != null:
return results(_that);case LookupFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( String headword)?  loading,TResult Function( WordSuggestions suggestions)?  results,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LookupIdle() when idle != null:
return idle();case LookupLoading() when loading != null:
return loading(_that.headword);case LookupResults() when results != null:
return results(_that.suggestions);case LookupFailed() when failed != null:
return failed(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( String headword)  loading,required TResult Function( WordSuggestions suggestions)  results,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case LookupIdle():
return idle();case LookupLoading():
return loading(_that.headword);case LookupResults():
return results(_that.suggestions);case LookupFailed():
return failed(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( String headword)?  loading,TResult? Function( WordSuggestions suggestions)?  results,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case LookupIdle() when idle != null:
return idle();case LookupLoading() when loading != null:
return loading(_that.headword);case LookupResults() when results != null:
return results(_that.suggestions);case LookupFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class LookupIdle implements LookupState {
  const LookupIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LookupState.idle()';
}


}




/// @nodoc


class LookupLoading implements LookupState {
  const LookupLoading(this.headword);
  

 final  String headword;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LookupLoadingCopyWith<LookupLoading> get copyWith => _$LookupLoadingCopyWithImpl<LookupLoading>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupLoading&&(identical(other.headword, headword) || other.headword == headword));
}


@override
int get hashCode {
    return Object.hash(runtimeType,headword);
}

@override
String toString() {
    return 'LookupState.loading(headword: $headword)';
}


}

/// @nodoc
abstract mixin class $LookupLoadingCopyWith<$Res> implements $LookupStateCopyWith<$Res> {
  factory $LookupLoadingCopyWith(LookupLoading value, $Res Function(LookupLoading) _then) = _$LookupLoadingCopyWithImpl;
@useResult
$Res call({
 String headword
});




}
/// @nodoc
class _$LookupLoadingCopyWithImpl<$Res>
    implements $LookupLoadingCopyWith<$Res> {
  _$LookupLoadingCopyWithImpl(this._self, this._then);

  final LookupLoading _self;
  final $Res Function(LookupLoading) _then;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? headword = null,}) {
  return _then(LookupLoading(
null == headword ? _self.headword : headword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LookupResults implements LookupState {
  const LookupResults(this.suggestions);
  

 final  WordSuggestions suggestions;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LookupResultsCopyWith<LookupResults> get copyWith => _$LookupResultsCopyWithImpl<LookupResults>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupResults&&(identical(other.suggestions, suggestions) || other.suggestions == suggestions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,suggestions);
}

@override
String toString() {
    return 'LookupState.results(suggestions: $suggestions)';
}


}

/// @nodoc
abstract mixin class $LookupResultsCopyWith<$Res> implements $LookupStateCopyWith<$Res> {
  factory $LookupResultsCopyWith(LookupResults value, $Res Function(LookupResults) _then) = _$LookupResultsCopyWithImpl;
@useResult
$Res call({
 WordSuggestions suggestions
});


$WordSuggestionsCopyWith<$Res> get suggestions;

}
/// @nodoc
class _$LookupResultsCopyWithImpl<$Res>
    implements $LookupResultsCopyWith<$Res> {
  _$LookupResultsCopyWithImpl(this._self, this._then);

  final LookupResults _self;
  final $Res Function(LookupResults) _then;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? suggestions = null,}) {
  return _then(LookupResults(
null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as WordSuggestions,
  ));
}

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordSuggestionsCopyWith<$Res> get suggestions {
  
  return $WordSuggestionsCopyWith<$Res>(_self.suggestions, (value) {
    return _then(_self.copyWith(suggestions: value));
  });
}
}

/// @nodoc


class LookupFailed implements LookupState {
  const LookupFailed(this.failure);
  

 final  AppFailure failure;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LookupFailedCopyWith<LookupFailed> get copyWith => _$LookupFailedCopyWithImpl<LookupFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure);
}

@override
String toString() {
    return 'LookupState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $LookupFailedCopyWith<$Res> implements $LookupStateCopyWith<$Res> {
  factory $LookupFailedCopyWith(LookupFailed value, $Res Function(LookupFailed) _then) = _$LookupFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$LookupFailedCopyWithImpl<$Res>
    implements $LookupFailedCopyWith<$Res> {
  _$LookupFailedCopyWithImpl(this._self, this._then);

  final LookupFailed _self;
  final $Res Function(LookupFailed) _then;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(LookupFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
