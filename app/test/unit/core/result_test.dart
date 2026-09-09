import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';

void main() {
  const failure = ValidationFailure(field: 'headword', reason: 'empty');

  group('Ok', () {
    test('reports success and carries its value', () {
      const result = Ok<int, AppFailure>(7);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrNull, 7);
      expect(result.failureOrNull, isNull);
    });

    test('compares by value, so tests can assert on whole results', () {
      expect(const Ok<int, AppFailure>(7), const Ok<int, AppFailure>(7));
      expect(
        const Ok<int, AppFailure>(7).hashCode,
        const Ok<int, AppFailure>(7).hashCode,
      );
      expect(const Ok<int, AppFailure>(7), isNot(const Ok<int, AppFailure>(8)));
    });
  });

  group('Err', () {
    test('reports failure and carries it', () {
      const result = Err<int, AppFailure>(failure);
      expect(result.isErr, isTrue);
      expect(result.isOk, isFalse);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    test('compares by value', () {
      expect(
        const Err<int, AppFailure>(failure),
        const Err<int, AppFailure>(failure),
      );
    });
  });

  group('fold', () {
    test('takes the success branch for Ok', () {
      const result = Ok<int, AppFailure>(3);
      expect(result.fold((v) => 'ok $v', (f) => 'err'), 'ok 3');
    });

    test('takes the failure branch for Err', () {
      const result = Err<int, AppFailure>(failure);
      expect(
        result.fold((v) => 'ok', (f) => 'err ${f.debugLabel}'),
        'err invalid headword: empty',
      );
    });
  });

  group('map', () {
    test('transforms a success', () {
      expect(const Ok<int, AppFailure>(2).map((v) => v * 5).valueOrNull, 10);
    });

    test('leaves a failure untouched and does not run the transform', () {
      var called = false;
      final result = const Err<int, AppFailure>(failure).map((v) {
        called = true;
        return v;
      });
      expect(called, isFalse);
      expect(result.failureOrNull, same(failure));
    });
  });

  group('mapErr', () {
    test('transforms a failure', () {
      final result = const Err<int, AppFailure>(failure)
          .mapErr((f) => f.debugLabel.length);
      expect(result.failureOrNull, isPositive);
    });

    test('leaves a success untouched', () {
      final result = const Ok<int, AppFailure>(1).mapErr((f) => 0);
      expect(result.valueOrNull, 1);
    });
  });

  group('flatMap', () {
    test('chains a second fallible step', () {
      final result = const Ok<int, AppFailure>(4)
          .flatMap((v) => Ok<String, AppFailure>('v=$v'));
      expect(result.valueOrNull, 'v=4');
    });

    test('short-circuits on the first failure', () {
      var called = false;
      final result = const Err<int, AppFailure>(failure).flatMap((v) {
        called = true;
        return const Ok<String, AppFailure>('unreachable');
      });
      expect(called, isFalse);
      expect(result.failureOrNull, same(failure));
    });
  });

  group('getOrElse', () {
    test('returns the value when Ok', () {
      expect(const Ok<int, AppFailure>(9).getOrElse((_) => 0), 9);
    });

    test('returns the fallback when Err', () {
      expect(const Err<int, AppFailure>(failure).getOrElse((_) => -1), -1);
    });
  });

  group('Results.guard', () {
    test('wraps a returned value in Ok', () async {
      final result = await Results.guard<int>(() async => 42);
      expect(result.valueOrNull, 42);
    });

    test('converts a thrown error into UnexpectedFailure by default', () async {
      final result = await Results.guard<int>(
        () async => throw StateError('boom'),
      );
      expect(result.failureOrNull, isA<UnexpectedFailure>());
      expect(result.failureOrNull?.cause, isA<StateError>());
      expect(result.failureOrNull?.stackTrace, isNotNull);
    });

    test('uses the caller-supplied mapping when given one', () async {
      final result = await Results.guard<int>(
        () async => throw Exception('db is gone'),
        onError: (error, stackTrace) => DatabaseFailure(
          operation: 'insert word',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
      expect(result.failureOrNull, isA<DatabaseFailure>());
      expect(result.failureOrNull?.debugLabel, 'insert word');
    });

    test('catches errors that are not Exceptions', () async {
      // `on Object catch` matters: a bare `throw 'string'` must not escape
      // a layer boundary either (RULES.md section 24). Throwing a
      // non-Error is exactly the case under test, hence the ignore.
      // ignore: only_throw_errors
      final result = await Results.guard<int>(() async => throw 'raw');
      expect(result.isErr, isTrue);
      expect(result.failureOrNull?.cause, 'raw');
    });
  });

  group('Results.guardSync', () {
    test('wraps a returned value in Ok', () {
      expect(Results.guardSync<int>(() => 1).valueOrNull, 1);
    });

    test('converts a throw into an Err', () {
      final result = Results.guardSync<int>(() => throw StateError('no'));
      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<UnexpectedFailure>());
    });
  });

  group('AppFailure', () {
    test('every kind has a readable debug label', () {
      const failures = <AppFailure>[
        DatabaseFailure(operation: 'read'),
        MigrationFailure(fromVersion: 1, toVersion: 2),
        SchemaTooNewFailure(onDiskVersion: 5, supportedVersion: 3),
        NetworkFailure(kind: NetworkFailureKind.timeout),
        NotFoundFailure(what: 'word'),
        ValidationFailure(field: 'headword'),
        FileFailure(kind: FileFailureKind.corrupt),
        PermissionFailure(permission: 'notifications'),
        UnavailableFailure(capability: 'en-GB voice'),
        UnexpectedFailure(),
      ];
      for (final failure in failures) {
        expect(failure.debugLabel, isNotEmpty);
        expect(failure.toString(), failure.debugLabel);
      }
    });

    test('migration failure records whether the backup was restored', () {
      const failure = MigrationFailure(
        fromVersion: 1,
        toVersion: 2,
        backupRestored: true,
      );
      expect(failure.debugLabel, contains('backup restored: true'));
    });
  });
}
