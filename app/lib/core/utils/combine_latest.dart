/// Combining streams without pulling in a reactive-extensions package.
///
/// Only `combineLatest3` is needed (the words list joins words, note counts and
/// highlights), and `docs/RULES.md` §18 prefers a short helper to a dependency
/// that does one small thing.
library;

import 'dart:async';

/// Emits whenever any source emits, once all three have produced a value.
///
/// Semantics worth being explicit about:
///
/// * nothing is emitted until **every** source has produced at least one value,
///   so a subscriber never sees a half-populated row;
/// * an error on any source is forwarded and does **not** close the result, so
///   a transient database error cannot permanently kill a watch;
/// * the result closes only when every source has closed;
/// * cancelling the subscription cancels all three.
Stream<R> combineLatest3<A, B, C, R>(
  Stream<A> a,
  Stream<B> b,
  Stream<C> c,
  R Function(A a, B b, C c) combine,
) {
  late StreamController<R> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  StreamSubscription<C>? subC;

  A? latestA;
  B? latestB;
  C? latestC;
  var hasA = false;
  var hasB = false;
  var hasC = false;
  var closed = 0;

  void emit() {
    if (hasA && hasB && hasC && !controller.isClosed) {
      controller.add(combine(latestA as A, latestB as B, latestC as C));
    }
  }

  void onDone() {
    closed++;
    // Nothing waits on the close; the subscriber learns of it through the
    // stream itself.
    if (closed == 3 && !controller.isClosed) unawaited(controller.close());
  }

  void onError(Object error, StackTrace stackTrace) {
    if (!controller.isClosed) controller.addError(error, stackTrace);
  }

  controller = StreamController<R>(
    onListen: () {
      subA = a.listen(
        (value) {
          latestA = value;
          hasA = true;
          emit();
        },
        onError: onError,
        onDone: onDone,
      );
      subB = b.listen(
        (value) {
          latestB = value;
          hasB = true;
          emit();
        },
        onError: onError,
        onDone: onDone,
      );
      subC = c.listen(
        (value) {
          latestC = value;
          hasC = true;
          emit();
        },
        onError: onError,
        onDone: onDone,
      );
    },
    onCancel: () async {
      await Future.wait<void>(<Future<void>>[
        if (subA != null) subA!.cancel(),
        if (subB != null) subB!.cancel(),
        if (subC != null) subC!.cancel(),
      ]);
    },
  );

  return controller.stream;
}
