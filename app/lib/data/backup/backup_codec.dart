/// The `.vnb` backup format (F-073, F-074, `docs/DATABASE.md` §5).
///
/// A ZIP holding `manifest.json` and `data.json`. Rows are keyed by their
/// **SQL column name** with values **as SQLite stores them** - epoch
/// milliseconds, `0`/`1`, the documented enum strings - so the format is the
/// schema DATABASE.md §2 already documents rather than a second vocabulary.
///
/// Pure and held to 100% line coverage (RULES §30).
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/backup.dart';

/// One row, keyed by SQL column name, with values as SQLite stores them.
typedef BackupRow = Map<String, Object?>;

/// Rows by SQL table name.
typedef BackupTables = Map<String, List<BackupRow>>;

/// A `.vnb` read back: what it says about itself, and its rows.
class DecodedBackup {
  /// Creates a decoded backup.
  const new({
    required this.manifest,
    required this.tables,
    this.malformedRows = 0,
  });

  /// What the file says about itself.
  final BackupManifest manifest;

  /// Every table the file holds, known or not; import decides which it reads.
  final BackupTables tables;

  /// Rows, and whole tables, dropped for not being the shape of a row.
  final int malformedRows;
}

/// Writes and reads `.vnb` files.
abstract final class BackupCodec {
  /// The version of this format. Bumped only when a reader of the previous
  /// version could no longer read the known parts (RULES §12).
  static const int formatVersion = 1;

  /// The manifest's name inside the ZIP.
  static const String manifestEntry = 'manifest.json';

  /// The rows' name inside the ZIP.
  static const String dataEntry = 'data.json';

  /// The largest file accepted. 5,000 words compress to well under 1 MB, so
  /// anything near this is not a backup.
  static const int defaultMaxArchiveBytes = 64 * 1024 * 1024;

  /// The largest entry accepted once inflated - the zip-bomb guard, which
  /// `package:archive` does not have (`plan.md`, research note 3).
  static const int defaultMaxEntryBytes = 256 * 1024 * 1024;

  /// The manifest for [tables], exported by this build now.
  static BackupManifest manifestFor({
    required String appVersion,
    required int schemaVersion,
    required DateTime exportedAt,
    required BackupTables tables,
  }) => BackupManifest(
    appVersion: appVersion,
    schemaVersion: schemaVersion,
    formatVersion: formatVersion,
    exportedAt: exportedAt.toUtc(),
    counts: <String, int>{
      for (final MapEntry(:key, :value) in tables.entries) key: value.length,
    },
  );

  /// The `.vnb` bytes for [manifest] and [tables].
  static Uint8List encode(BackupManifest manifest, BackupTables tables) {
    final manifestJson = <String, Object?>{
      'app_version': manifest.appVersion,
      'schema_version': manifest.schemaVersion,
      'export_format_version': manifest.formatVersion,
      'exported_at': manifest.exportedAt?.toUtc().toIso8601String(),
      'counts': manifest.counts,
    };
    final archive = Archive()
      ..addFile(ArchiveFile.bytes(manifestEntry, _jsonBytes(manifestJson)))
      ..addFile(
        ArchiveFile.bytes(
          dataEntry,
          _jsonBytes(<String, Object?>{'tables': tables}),
        ),
      );
    return ZipEncoder().encodeBytes(archive);
  }

  static List<int> _jsonBytes(Object? json) => utf8.encode(jsonEncode(json));

  /// Reads a `.vnb`, or says why it cannot be used.
  ///
  /// Checks everything it can before trusting anything: the size before
  /// unpacking, the ZIP signature before parsing, each entry's declared size
  /// before inflating it. What is merely unfamiliar - a newer format, an
  /// unknown table, a row of the wrong shape - is accepted, skipped or
  /// counted rather than refused, so an older app reads what it can.
  static AppResult<DecodedBackup> decode(
    Uint8List bytes, {
    int maxArchiveBytes = defaultMaxArchiveBytes,
    int maxEntryBytes = defaultMaxEntryBytes,
  }) {
    if (bytes.length > maxArchiveBytes) return _refuse(BackupProblem.tooLarge);
    // Every ZIP starts `PK`. Checked first, so a photo or a PDF picked by
    // mistake is named as "not a backup" rather than as damaged.
    if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4B) {
      return _refuse(BackupProblem.notABackup);
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object catch (error, stackTrace) {
      // Starts like a ZIP and cannot be read as one: most often a backup cut
      // short by an interrupted download or copy. Damaged, not a stranger.
      return _refuse(BackupProblem.damaged, error, stackTrace);
    }

    // No manifest: some other ZIP. No data: one of ours, broken.
    final manifestFile = archive.findFile(manifestEntry);
    if (manifestFile == null) return _refuse(BackupProblem.notABackup);
    final dataFile = archive.findFile(dataEntry);
    if (dataFile == null) return _refuse(BackupProblem.damaged);
    if (manifestFile.size > maxEntryBytes || dataFile.size > maxEntryBytes) {
      return _refuse(BackupProblem.tooLarge);
    }

    final Object? manifestJson;
    final Object? dataJson;
    try {
      manifestJson = jsonDecode(utf8.decode(manifestFile.content));
      dataJson = jsonDecode(utf8.decode(dataFile.content));
    } on Object catch (error, stackTrace) {
      // Not only FormatException: bad JSON or UTF-8 throws that, but corrupt
      // compressed data throws whatever package:archive's inflater hits - a
      // RangeError included - and none of it may escape decode.
      return _refuse(BackupProblem.damaged, error, stackTrace);
    }

    if (manifestJson is! Map<String, Object?> ||
        dataJson is! Map<String, Object?>) {
      return _refuse(BackupProblem.damaged);
    }
    final rawTables = dataJson['tables'];
    if (rawTables is! Map<String, Object?>) {
      return _refuse(BackupProblem.damaged);
    }

    final tables = <String, List<BackupRow>>{};
    var malformed = 0;
    for (final MapEntry(key: name, value: rows) in rawTables.entries) {
      if (rows is! List<Object?>) {
        malformed++;
        continue;
      }
      final kept = <BackupRow>[
        for (final row in rows)
          if (row is BackupRow) row,
      ];
      malformed += rows.length - kept.length;
      tables[name] = kept;
    }

    return Ok<DecodedBackup, AppFailure>(
      DecodedBackup(
        manifest: _readManifest(manifestJson),
        tables: tables,
        malformedRows: malformed,
      ),
    );
  }

  /// A manifest, taking each field only when it is the expected type.
  static BackupManifest _readManifest(Map<String, Object?> json) {
    final counts = json['counts'];
    return BackupManifest(
      appVersion: switch (json['app_version']) {
        final String version => version,
        _ => '',
      },
      schemaVersion: switch (json['schema_version']) {
        final int version => version,
        _ => 0,
      },
      formatVersion: switch (json['export_format_version']) {
        final int version => version,
        _ => formatVersion,
      },
      exportedAt: switch (json['exported_at']) {
        final String stamp => DateTime.tryParse(stamp)?.toUtc(),
        _ => null,
      },
      counts: <String, int>{
        if (counts is Map<String, Object?>)
          for (final MapEntry(:key, :value) in counts.entries)
            if (value is int) key: value,
      },
    );
  }

  static AppResult<DecodedBackup> _refuse(
    BackupProblem problem, [
    Object? cause,
    StackTrace? stackTrace,
  ]) => Err<DecodedBackup, AppFailure>(
    InvalidBackupFailure(
      problem: problem,
      cause: cause,
      stackTrace: stackTrace,
    ),
  );
}
