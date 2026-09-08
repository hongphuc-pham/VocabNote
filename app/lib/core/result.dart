/// A success-or-failure value.
///
/// `docs/RULES.md` §24: async work returns a [Result] rather than throwing, so
/// a caller cannot forget that something might fail — the type will not let a
/// value out without handling the other case.
library;

import 'package:meta/meta.dart';
import 'package:vocabnote/core/failure.dart';

/// The shape used almost everywhere: a value, or an [AppFailure].
typedef AppResult<T> = Result<T, AppFailure>;

/// A future returning an [AppResult].
typedef AsyncResult<T> = Future<Result<T, AppFailure>>;

/// Either a [Ok] holding a value or an [Err] holding a failure.
///
/// Sealed, so `switch` over it is exhaustive.
@immutable
sealed class Result<T, F> {
  /// Creates a result.
  const new();

  /// Wraps a success value.
  const factory ok(T value) = Ok<T, F>;

  /// Wraps a failure.
  const factory err(F failure) = Err<T, F>;

  /// True when this is an [Ok].
  bool get isOk => this is Ok<T, F>;

  /// True when this is an [Err].
  bool get isErr => this is Err<T, F>;

  /// The value, or null when this is an [Err].
  T? get valueOrNull => switch (this) {
    Ok<T, F>(:final value) => value,
    Err<T, F>() => null,
  };

  /// The failure, or null when this is an [Ok].
  F? get failureOrNull => switch (this) {
    Ok<T, F>() => null,
    Err<T, F>(:final failure) => failure,
  };

  /// Collapses both cases into one value.
  R fold<R>(R Function(T value) onOk, R Function(F failure) onErr) {
    return switch (this) {
      Ok<T, F>(:final value) => onOk(value),
      Err<T, F>(:final failure) => onErr(failure),
    };
  }

  /// The value, or [fallback] when this is an [Err].
  T getOrElse(T Function(F failure) fallback) {
    return switch (this) {
      Ok<T, F>(:final value) => value,
      Err<T, F>(:final failure) => fallback(failure),
    };
  }

  /// Transforms a success value, leaving a failure untouched.
  Result<R, F> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok<T, F>(:final value) => Ok<R, F>(transform(value)),
      Err<T, F>(:final failure) => Err<R, F>(failure),
    };
  }

  /// Transforms a failure, leaving a success untouched.
  Result<T, G> mapErr<G>(G Function(F failure) transform) {
    return switch (this) {
      Ok<T, F>(:final value) => Ok<T, G>(value),
      Err<T, F>(:final failure) => Err<T, G>(transform(failure)),
    };
  }

  /// Chains another fallible step onto a success.
  Result<R, F> flatMap<R>(Result<R, F> Function(T value) transform) {
    return switch (this) {
      Ok<T, F>(:final value) => transform(value),
      Err<T, F>(:final failure) => Err<R, F>(failure),
    };
  }
}

/// A successful [Result].
@immutable
final class Ok<T, F> extends Result<T, F> {
  /// Wraps [value].
  const new(this.value);

  /// The value.
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T, F> && other.value == value);

  @override
  int get hashCode => Object.hash(Ok<T, F>, value);

  @override
  String toString() => 'Ok($value)';
}

/// A failed [Result].
@immutable
final class Err<T, F> extends Result<T, F> {
  /// Wraps [failure].
  const new(this.failure);

  /// The failure.
  final F failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Err<T, F> && other.failure == failure);

  @override
  int get hashCode => Object.hash(Err<T, F>, failure);

  @override
  String toString() => 'Err($failure)';
}

/// Helpers for running code that still throws — a plugin, or `dart:io`.
abstract final class Results {
  /// Runs [body] and converts anything it throws into an [Err].
  ///
  /// [onError] maps the caught object to a failure. Pass it so each call site
  /// names the failure it actually means; the default is [UnexpectedFailure],
  /// which should be rare enough to notice in the log.
  static AsyncResult<T> guard<T>(
    Future<T> Function() body, {
    AppFailure Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return Ok<T, AppFailure>(await body());
    } on Object catch (error, stackTrace) {
      final failure =
          onError?.call(error, stackTrace) ??
          UnexpectedFailure(cause: error, stackTrace: stackTrace);
      return Err<T, AppFailure>(failure);
    }
  }

  /// The synchronous twin of [guard].
  static AppResult<T> guardSync<T>(
    T Function() body, {
    AppFailure Function(Object error, StackTrace stackTrace)? onError,
  }) {
    try {
      return Ok<T, AppFailure>(body());
    } on Object catch (error, stackTrace) {
      final failure =
          onError?.call(error, stackTrace) ??
          UnexpectedFailure(cause: error, stackTrace: stackTrace);
      return Err<T, AppFailure>(failure);
    }
  }
}
