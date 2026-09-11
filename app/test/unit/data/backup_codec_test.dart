import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/backup/backup_codec.dart';
import 'package:vocabnote/domain/entities/backup.dart';

/// The `.vnb` format (F-073/F-074, `docs/DATABASE.md` §5).
///
/// Held to 100% line coverage (RULES §30): this is the one file a user moves
/// between phones, and an older app must be able to read a newer file's known
/// parts. Every refusal is a case here, because a refusal is the only thing
/// that stands between a stranger's ZIP and the database.
void main() {
  final exportedAt = DateTime.utc(2026, 9, 11, 2, 30);
  final tables = <String, List<BackupRow>>{
    'words': <BackupRow>[
      <String, Object?>{
        'id': 'w1',
        'headword': 'church',
        // Combining marks and multi-codepoint symbols must survive exactly.
        'ipa_uk': 'ˈtʃɜːtʃ',
        'is_favourite': 1,
        'created_at': 1757557800000,
        'deleted_at': null,
      },
    ],
    'word_notes': <BackupRow>[],
    'settings': <BackupRow>[
      <String, Object?>{'id': 1, 'tts_rate': 0.5},
    ],
  };

  BackupManifest manifest() => BackupCodec.manifestFor(
    appVersion: '1.0.0',
    schemaVersion: 2,
    exportedAt: exportedAt,
    tables: tables,
  );

  Uint8List zip(Map<String, List<int>> files) {
    final archive = Archive();
    for (final MapEntry(:key, :value) in files.entries) {
      archive.addFile(ArchiveFile.bytes(key, value));
    }
    return ZipEncoder().encodeBytes(archive);
  }

  Uint8List zipText(Map<String, String> files) => zip(<String, List<int>>{
    for (final MapEntry(:key, :value) in files.entries) key: utf8.encode(value),
  });

  const validManifest = '{"export_format_version": 1}';
  const validData = '{"tables": {}}';

  Object? entryJson(Uint8List bytes, String name) {
    final file = ZipDecoder().decodeBytes(bytes).findFile(name)!;
    return jsonDecode(utf8.decode(file.readBytes()!));
  }

  BackupProblem? problemOf(AppResult<DecodedBackup> result) => switch (result) {
    Err(failure: InvalidBackupFailure(:final problem)) => problem,
    _ => null,
  };

  DecodedBackup decoded(Uint8List bytes) => BackupCodec.decode(bytes).fold(
    (backup) => backup,
    (failure) => fail('expected a backup, got $failure'),
  );

  group('encoding', () {
    test('writes exactly manifest.json and data.json', () {
      final bytes = BackupCodec.encode(manifest(), tables);

      final names = ZipDecoder().decodeBytes(bytes).files.map((f) => f.name);
      expect(names, unorderedEquals(<String>['manifest.json', 'data.json']));
    });

    test('the manifest carries every field DATABASE.md §5 names', () {
      final bytes = BackupCodec.encode(manifest(), tables);

      expect(entryJson(bytes, 'manifest.json'), <String, Object?>{
        'app_version': '1.0.0',
        'schema_version': 2,
        'export_format_version': 1,
        'exported_at': '2026-09-11T02:30:00.000Z',
        'counts': <String, Object?>{'words': 1, 'word_notes': 0, 'settings': 1},
      });
    });

    test('data.json holds the rows as given, keyed by table', () {
      final bytes = BackupCodec.encode(manifest(), tables);

      expect(entryJson(bytes, 'data.json'), <String, Object?>{
        'tables': tables,
      });
    });
  });

  group('decoding', () {
    test('reads back exactly what was written', () {
      final backup = decoded(BackupCodec.encode(manifest(), tables));

      expect(backup.tables, tables);
      expect(backup.malformedRows, 0);
      expect(backup.manifest.appVersion, '1.0.0');
      expect(backup.manifest.schemaVersion, 2);
      expect(backup.manifest.formatVersion, BackupCodec.formatVersion);
      expect(backup.manifest.exportedAt, exportedAt);
      expect(backup.manifest.counts, <String, int>{
        'words': 1,
        'word_notes': 0,
        'settings': 1,
      });
      expect(backup.manifest.wordCount, 1);
    });

    test('reads a newer format for the parts it knows', () {
      // DATABASE.md §5: an older app must read a newer file's known parts.
      final backup = decoded(
        zipText(<String, String>{
          'manifest.json':
              '{"export_format_version": 99, "schema_version": 40, '
              '"encrypted": false, "exported_at": "2031-01-01T00:00:00Z"}',
          'data.json':
              '{"tables": {"words": [{"id": "w1", "future": true}], '
              '"recordings": [{"id": "r1"}]}, "signature": "abc"}',
          'extra/readme.txt': 'hello',
        }),
      );

      expect(backup.manifest.formatVersion, 99);
      expect(backup.manifest.schemaVersion, 40);
      expect(backup.tables['words'], <BackupRow>[
        <String, Object?>{'id': 'w1', 'future': true},
      ]);
      expect(
        backup.tables.keys,
        contains('recordings'),
        reason: 'unknown tables are passed on; import decides what it knows',
      );
    });

    test('defaults what a sparse manifest leaves out', () {
      final backup = decoded(
        zipText(<String, String>{
          'manifest.json': '{}',
          'data.json': validData,
        }),
      );

      expect(backup.manifest.appVersion, '');
      expect(backup.manifest.schemaVersion, 0);
      expect(backup.manifest.formatVersion, 1);
      expect(backup.manifest.exportedAt, isNull);
      expect(backup.manifest.counts, isEmpty);
      expect(backup.manifest.wordCount, 0);
    });

    test('ignores manifest values of the wrong type', () {
      final backup = decoded(
        zipText(<String, String>{
          'manifest.json':
              '{"app_version": 7, "schema_version": "two", '
              '"exported_at": "not a date", '
              '"counts": {"words": "many", "word_lists": 2}}',
          'data.json': validData,
        }),
      );

      expect(backup.manifest.appVersion, '');
      expect(backup.manifest.schemaVersion, 0);
      expect(backup.manifest.exportedAt, isNull);
      expect(backup.manifest.counts, <String, int>{'word_lists': 2});
    });

    test('drops rows and tables of the wrong shape, and counts them', () {
      final backup = decoded(
        zipText(<String, String>{
          'manifest.json': validManifest,
          'data.json':
              '{"tables": {"words": [{"id": "w1"}, 3, "x", null], '
              '"word_notes": {"id": "n1"}}}',
        }),
      );

      expect(backup.tables['words'], <BackupRow>[
        <String, Object?>{'id': 'w1'},
      ]);
      expect(backup.tables.containsKey('word_notes'), isFalse);
      expect(backup.malformedRows, 4, reason: 'three rows and one table');
    });
  });

  group('refusing what is not a backup', () {
    test('an empty file', () {
      expect(
        problemOf(BackupCodec.decode(Uint8List(0))),
        BackupProblem.notABackup,
      );
    });

    test('a file that is not a ZIP at all', () {
      final text = Uint8List.fromList(utf8.encode('just some notes'));
      expect(problemOf(BackupCodec.decode(text)), BackupProblem.notABackup);
    });

    test('bytes that start like a ZIP and are not one', () {
      final fake = Uint8List.fromList(<int>[0x50, 0x4B, 1, 2, 3, 4, 5]);
      expect(problemOf(BackupCodec.decode(fake)), BackupProblem.notABackup);
    });

    test('a ZIP with no manifest - some other archive', () {
      final other = zipText(<String, String>{'photo.txt': 'not ours'});
      expect(problemOf(BackupCodec.decode(other)), BackupProblem.notABackup);
    });

    test('a file over the size cap, refused before it is unpacked', () {
      final bytes = BackupCodec.encode(manifest(), tables);
      expect(
        problemOf(BackupCodec.decode(bytes, maxArchiveBytes: 10)),
        BackupProblem.tooLarge,
      );
    });

    test('an entry that would inflate past the cap', () {
      // A few hundred bytes of ZIP that expand to far more: the shape of a
      // zip bomb, refused on its declared size.
      final bomb = zipText(<String, String>{
        'manifest.json': validManifest,
        'data.json': '{"tables": {}, "pad": "${'a' * 5000}"}',
      });
      expect(
        problemOf(BackupCodec.decode(bomb, maxEntryBytes: 1000)),
        BackupProblem.tooLarge,
      );
    });
  });

  group('refusing a damaged backup', () {
    test('a manifest that is not JSON', () {
      final bytes = zipText(<String, String>{
        'manifest.json': '{not json',
        'data.json': validData,
      });
      expect(problemOf(BackupCodec.decode(bytes)), BackupProblem.damaged);
    });

    test('a manifest that is not an object', () {
      final bytes = zipText(<String, String>{
        'manifest.json': '[1, 2]',
        'data.json': validData,
      });
      expect(problemOf(BackupCodec.decode(bytes)), BackupProblem.damaged);
    });

    test('a missing data.json', () {
      final bytes = zipText(<String, String>{'manifest.json': validManifest});
      expect(problemOf(BackupCodec.decode(bytes)), BackupProblem.damaged);
    });

    test('data.json with no tables', () {
      final bytes = zipText(<String, String>{
        'manifest.json': validManifest,
        'data.json': '{"rows": []}',
      });
      expect(problemOf(BackupCodec.decode(bytes)), BackupProblem.damaged);
    });

    test('data.json that is not an object', () {
      final bytes = zipText(<String, String>{
        'manifest.json': validManifest,
        'data.json': '"tables"',
      });
      expect(problemOf(BackupCodec.decode(bytes)), BackupProblem.damaged);
    });

    test('text that is not UTF-8', () {
      final bytes = zip(<String, List<int>>{
        'manifest.json': utf8.encode(validManifest),
        'data.json': <int>[0xFF, 0xFE, 0xFD],
      });
      expect(problemOf(BackupCodec.decode(bytes)), BackupProblem.damaged);
    });

    test('a backup cut short, as by an interrupted download', () {
      final whole = BackupCodec.encode(manifest(), tables);
      final cut = Uint8List.sublistView(whole, 0, whole.length - 5);

      expect(problemOf(BackupCodec.decode(cut)), BackupProblem.damaged);
    });

    test('a backup whose data is corrupt inside the ZIP', () {
      // The archive opens and lists its entries; reading data.json is what
      // fails, and it must fail as "damaged" rather than escape as a throw.
      final bytes = Uint8List.fromList(BackupCodec.encode(manifest(), tables));
      final name = utf8.encode(BackupCodec.dataEntry);
      var at = -1;
      for (var i = 0; i + name.length <= bytes.length; i++) {
        if (listEquals(bytes.sublist(i, i + name.length), name)) {
          at = i + name.length;
          break;
        }
      }
      expect(at, greaterThan(0), reason: 'the local header names the entry');
      bytes.fillRange(at, at + 32, 0);

      expect(problemOf(BackupCodec.decode(bytes)), BackupProblem.damaged);
    });
  });
}
