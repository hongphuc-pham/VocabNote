import 'package:meta/meta.dart';

/// What a `.vnb` backup says about itself: its `manifest.json`
/// (`docs/DATABASE.md` §5).
///
/// Every field has a default, because a reader must accept a sparse or newer
/// manifest and use what it recognises (RULES §12).
@immutable
class BackupManifest {
  /// Creates a manifest.
  const new({
    required this.appVersion,
    required this.schemaVersion,
    required this.formatVersion,
    this.exportedAt,
    this.counts = const <String, int>{},
  });

  /// The version of VocabNote that wrote the file, e.g. `1.0.0`.
  final String appVersion;

  /// The database schema version of the app that wrote it.
  final int schemaVersion;

  /// The version of the file format itself, bumped separately from the
  /// schema (RULES §12).
  final int formatVersion;

  /// When the backup was made, in UTC. Null if the file does not say.
  final DateTime? exportedAt;

  /// Rows per table, keyed by SQL table name.
  final Map<String, int> counts;

  /// How many words the backup holds, counting deleted ones.
  int get wordCount => counts['words'] ?? 0;
}

/// A backup written to a file, ready to be handed on.
@immutable
class ExportedBackup {
  /// Creates the description of a written backup.
  const new({
    required this.path,
    required this.fileName,
    required this.manifest,
  });

  /// Where the file is.
  final String path;

  /// Its name, `vocabnote-backup-YYYYMMDD-HHmm.vnb`.
  final String fileName;

  /// What it says about itself.
  final BackupManifest manifest;
}
