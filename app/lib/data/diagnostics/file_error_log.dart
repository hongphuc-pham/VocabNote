import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vocabnote/core/extensions/grapheme.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/repositories/error_log.dart';

/// [ErrorLog] as a small rolling text file (F-079,
/// `docs/ARCHITECTURE.md` §5).
///
/// Each entry is the moment, the error's first line - capped short - and
/// the top of its stack. Only the first line, because later lines are where
/// input tends to be quoted back; capped, because a message can carry what
/// the user typed; the stack, because it names places in the code, not data.
///
/// The file stays under [defaultMaxBytes] by dropping the oldest entries
/// whole. It lives beside the database, so it counts in *Storage used*.
class FileErrorLog implements ErrorLog {
  /// Creates a log written to [_file].
  new(this._file, {DateTime Function()? now, this._maxBytes = defaultMaxBytes})
    : _now = now ?? DateTime.now;

  /// The largest the file may grow: plenty for the last few dozen errors,
  /// small enough never to matter on a phone.
  static const int defaultMaxBytes = 64 * 1024;

  /// The longest message line kept, in grapheme clusters.
  static const int maxMessageLength = 200;

  /// How many stack frames an entry keeps.
  static const int maxFrames = 12;

  final File _file;
  final DateTime Function() _now;
  final int _maxBytes;

  /// The app's log, at `<app support>/vocabnote/errors.log`; or, if that
  /// folder cannot be found, a log that keeps nothing - an error while
  /// opening the error log must not stop the app.
  static Future<ErrorLog> open() async {
    try {
      final support = await getApplicationSupportDirectory();
      return FileErrorLog(
        File(p.join(support.path, 'vocabnote', 'errors.log')),
      );
    } on Object {
      return const DiscardingErrorLog();
    }
  }

  @override
  void record(Object error, StackTrace stackTrace) {
    try {
      _file.parent.createSync(recursive: true);
      _file.writeAsStringSync(
        _entry(error, stackTrace),
        mode: FileMode.append,
        flush: true,
      );
      if (_file.lengthSync() > _maxBytes) _dropOldest();
    } on Object {
      // Deliberately swallowed - and never logged, which is the point: this
      // runs inside the error handlers, where a failure could recurse.
    }
  }

  String _entry(Object error, StackTrace stackTrace) {
    final type = '${error.runtimeType}';
    var line = error.toString().split('\n').first.trim();
    if (!line.startsWith(type)) line = '$type: $line';
    // Grapheme-safe: the message may quote IPA, and a plain cut can split a
    // symbol from its diacritic (RULES §21).
    if (line.graphemeLength > maxMessageLength) {
      line = '${line.truncateGraphemes(maxMessageLength)}…';
    }
    final frames = stackTrace
        .toString()
        .split('\n')
        .where((frame) => frame.trim().isNotEmpty)
        .take(maxFrames);
    return <String>[
      '[${_now().toUtc().toIso8601String()}] $line',
      for (final frame in frames) '  $frame',
      '',
    ].join('\n');
  }

  /// Keeps the newest half of the file, cut at the start of an entry.
  ///
  /// Worked in bytes and cut only after a newline, so a multi-byte character
  /// is never split.
  void _dropOldest() {
    final bytes = _file.readAsBytesSync();
    const newline = 0x0A;
    const bracket = 0x5B;
    for (var i = bytes.length - _maxBytes ~/ 2; i < bytes.length - 1; i++) {
      if (i >= 0 && bytes[i] == newline && bytes[i + 1] == bracket) {
        _file.writeAsBytesSync(bytes.sublist(i + 1), flush: true);
        return;
      }
    }
    // One entry larger than half the cap: start again rather than keep it.
    _file.writeAsStringSync('', flush: true);
  }

  @override
  AsyncResult<String> read() => Results.guard(
    () async => _file.existsSync() ? await _file.readAsString() : '',
    onError: (error, stackTrace) => FileFailure(
      kind: FileFailureKind.io,
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  @override
  AsyncResult<void> clear() => Results.guard(
    () async {
      if (_file.existsSync()) await _file.delete();
    },
    onError: (error, stackTrace) => FileFailure(
      kind: FileFailureKind.io,
      cause: error,
      stackTrace: stackTrace,
    ),
  );
}

/// An [ErrorLog] that keeps nothing.
///
/// What the app uses when the folder for the real log cannot be found at
/// start-up: an app that cannot keep a record of its errors must still run.
class DiscardingErrorLog implements ErrorLog {
  /// Creates the log.
  const new();

  @override
  void record(Object error, StackTrace stackTrace) {}

  @override
  AsyncResult<String> read() async => const Ok<String, AppFailure>('');

  @override
  AsyncResult<void> clear() async => const Ok<void, AppFailure>(null);
}
