/// Everything that can go wrong, named.
///
/// `docs/RULES.md` §24: no bare exception crosses a layer boundary. Data and
/// application code catch what they know about and return one of these inside
/// a `Result` instead, so presentation always has something it can render.
library;

import 'package:meta/meta.dart';

/// Base class for every expected failure in the app.
///
/// Sealed, so a `switch` over a failure is exhaustive and adding a new kind
/// makes every handler that ignores it a compile error.
/// Implements [Exception] so the application layer can rethrow a failure into
/// Riverpod's error capture, where it becomes `AsyncValue.error` for the UI.
/// That is not a bare exception crossing a layer boundary - the boundary
/// already converted it; this is the presentation layer's own error channel.
@immutable
sealed class AppFailure implements Exception {
  /// Creates a failure.
  const new({this.cause, this.stackTrace});

  /// The original error, kept for the local log — never shown to the user.
  final Object? cause;

  /// Where it came from, kept for the local log.
  final StackTrace? stackTrace;

  /// A short, non-localised description for logs and tests.
  ///
  /// User-facing text is chosen by the presentation layer from l10n
  /// (`docs/RULES.md` §22); this string must never reach a screen.
  String get debugLabel;

  @override
  String toString() => debugLabel;
}

/// The local database could not be read or written.
final class DatabaseFailure extends AppFailure {
  /// Creates a database failure.
  const new({this.operation, super.cause, super.stackTrace});

  /// What was being attempted, e.g. `'insert word'`.
  final String? operation;

  @override
  String get debugLabel => operation ?? 'database error';
}

/// A migration could not be applied.
///
/// Distinct from [DatabaseFailure] because it triggers the non-destructive
/// recovery path in `bootstrap.dart` (`docs/DATABASE.md` §3): restore the
/// pre-migration backup, keep the old schema, offer *Export my data*. The
/// database is never deleted.
final class MigrationFailure extends AppFailure {
  /// Creates a migration failure.
  const new({
    required this.fromVersion,
    required this.toVersion,
    this.backupRestored = false,
    super.cause,
    super.stackTrace,
  });

  /// The schema version found on disk.
  final int fromVersion;

  /// The schema version this build wanted.
  final int toVersion;

  /// Whether the pre-migration backup was successfully put back.
  final bool backupRestored;

  @override
  String get debugLabel =>
      'migration $fromVersion -> $toVersion failed '
      '(backup restored: $backupRestored)';
}

/// The database on disk was written by a newer build than this one.
///
/// `docs/DATABASE.md` §3.10: refuse to open, never migrate downwards, and offer
/// export.
final class SchemaTooNewFailure extends AppFailure {
  /// Creates a "data is from the future" failure.
  const new({
    required this.onDiskVersion,
    required this.supportedVersion,
    super.cause,
    super.stackTrace,
  });

  /// The version found in the file.
  final int onDiskVersion;

  /// The highest version this binary understands.
  final int supportedVersion;

  @override
  String get debugLabel =>
      'on-disk schema $onDiskVersion is newer than $supportedVersion';
}

/// A network call failed. Only ever produced by dictionary look-up, which is
/// optional by design — no core action may depend on it (`docs/RULES.md` §2).
final class NetworkFailure extends AppFailure {
  /// Creates a network failure.
  const new({
    required this.kind,
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  /// What sort of network problem this was.
  final NetworkFailureKind kind;

  /// The HTTP status, when there was a response.
  final int? statusCode;

  @override
  String get debugLabel =>
      'network ${kind.name}'
      '${statusCode == null ? '' : ' ($statusCode)'}';
}

/// The kinds of network failure the dictionary client distinguishes.
enum NetworkFailureKind {
  /// No usable connection.
  offline,

  /// The request exceeded its 6s budget.
  timeout,

  /// Rate limited — back off exponentially (`docs/DATA-SOURCES.md` §1).
  rateLimited,

  /// The server answered, but with an error status.
  server,

  /// The response arrived but could not be parsed.
  malformedResponse,
}

/// A look-up returned no entry for the word. Not an error the user caused.
final class NotFoundFailure extends AppFailure {
  /// Creates a not-found failure.
  const new({this.what, super.cause, super.stackTrace});

  /// What was being looked for.
  final String? what;

  @override
  String get debugLabel => 'not found: ${what ?? 'resource'}';
}

/// User input did not pass a domain rule.
final class ValidationFailure extends AppFailure {
  /// Creates a validation failure.
  const new({required this.field, this.reason, super.cause, super.stackTrace});

  /// The field at fault, e.g. `'headword'`.
  final String field;

  /// A non-localised reason, for tests and logs.
  final String? reason;

  @override
  String get debugLabel => 'invalid $field${reason == null ? '' : ': $reason'}';
}

/// Reading or writing a file failed — backup export and import.
final class FileFailure extends AppFailure {
  /// Creates a file failure.
  const new({required this.kind, this.path, super.cause, super.stackTrace});

  /// What sort of file problem this was.
  final FileFailureKind kind;

  /// The path involved, when there is one.
  final String? path;

  @override
  String get debugLabel => 'file ${kind.name}${path == null ? '' : ' ($path)'}';
}

/// The kinds of file failure backup handles.
enum FileFailureKind {
  /// The file was not where it was expected.
  missing,

  /// The archive or its JSON could not be read.
  corrupt,

  /// The file is a backup, but from an export format this build cannot read.
  unsupportedFormat,

  /// The OS refused access.
  permissionDenied,

  /// Anything else the platform reported.
  io,
}

/// The user, or the OS, declined something we asked for.
///
/// Notification permission is the only one v1 requests, and only at the moment
/// the user turns the reminder on (`F-066`).
final class PermissionFailure extends AppFailure {
  /// Creates a permission failure.
  const new({required this.permission, super.cause, super.stackTrace});

  /// What was denied, e.g. `'notifications'`.
  final String permission;

  @override
  String get debugLabel => 'permission denied: $permission';
}

/// A device capability is missing — chiefly a text-to-speech voice.
final class UnavailableFailure extends AppFailure {
  /// Creates an unavailable-capability failure.
  const new({required this.capability, super.cause, super.stackTrace});

  /// What is missing, e.g. `'en-GB voice'`.
  final String capability;

  @override
  String get debugLabel => 'unavailable: $capability';
}

/// Something we did not anticipate. Always logged; never silently swallowed.
final class UnexpectedFailure extends AppFailure {
  /// Creates an unexpected failure.
  const new({super.cause, super.stackTrace});

  @override
  String get debugLabel => 'unexpected: ${cause ?? 'unknown'}';
}
