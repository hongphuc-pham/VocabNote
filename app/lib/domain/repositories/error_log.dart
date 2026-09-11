import 'package:vocabnote/core/result.dart';

/// A record of uncaught errors, kept on this phone (F-079).
///
/// There is no crash reporter and never will be (RULES §1). This is the only
/// record of what went wrong, and it leaves the phone only inside a feedback
/// email the user has chosen to send, having read exactly what is in it.
abstract interface class ErrorLog {
  /// Records one uncaught error.
  ///
  /// Synchronous and never throws: it is called from inside the error
  /// handlers, where a second failure would be worse than a lost entry, and
  /// where a handler that throws can recurse.
  void record(Object error, StackTrace stackTrace);

  /// The log as text, oldest entry first; empty when nothing went wrong.
  AsyncResult<String> read();

  /// Removes every entry.
  AsyncResult<void> clear();
}
