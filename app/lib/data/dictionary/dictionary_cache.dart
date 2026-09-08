import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vocabnote/data/dictionary/dto/dictionary_dto.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';

/// A 24-hour on-disk cache of look-up responses (`docs/DATA-SOURCES.md` §1).
///
/// Two reasons it exists, and only the first is about speed:
///
/// * the API allows 1,000 requests/hour/IP, and a user editing the same word
///   twice should not spend two of them;
/// * a cached response makes *Look up* work on a plane for any word already
///   seen, which is the spirit of "works offline" even though look-up is the
///   one optional online feature.
///
/// Keyed by the **normalised** headword, so `Cough` and `cough ` hit the same
/// entry - the same rule dedupe uses.
class DictionaryCache {
  /// Creates a cache.
  ///
  /// [resolveDirectory] and [now] are injectable for tests.
  new({
    Future<Directory> Function()? resolveDirectory,
    DateTime Function()? now,
    this.ttl = const Duration(hours: 24),
  }) : _resolveDirectory = resolveDirectory ?? getApplicationSupportDirectory,
       _now = now ?? DateTime.now;

  /// How long an entry stays fresh.
  final Duration ttl;

  final Future<Directory> Function() _resolveDirectory;
  final DateTime Function() _now;

  Directory? _directory;

  /// The cache folder, created on first use.
  Future<Directory> directory() async {
    final existing = _directory;
    if (existing != null) return existing;

    final support = await _resolveDirectory();
    final dir = Directory(p.join(support.path, 'vocabnote', 'dictionary'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return _directory = dir;
  }

  /// The file backing [word].
  ///
  /// The normalised headword is percent-encoded, so a word containing a slash
  /// or a colon cannot escape the cache folder or collide with another entry.
  Future<File> fileFor(String word) async {
    final dir = await directory();
    final key = Uri.encodeComponent(Headword.normalize(word));
    return File(p.join(dir.path, '$key.json'));
  }

  /// Reads a cached response, or null when there is none or it has expired.
  ///
  /// Never throws. A cache is a convenience; a corrupt one is a cache miss,
  /// not an error the user should ever hear about.
  Future<DictionaryResponseDto?> read(String word) async {
    try {
      final file = await fileFor(word);
      if (!file.existsSync()) return null;

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;

      final storedAt = decoded['cachedAt'];
      if (storedAt is! int) return null;

      final age = _now().difference(
        DateTime.fromMillisecondsSinceEpoch(storedAt, isUtc: true),
      );
      if (age.isNegative || age > ttl) return null;

      final payload = decoded['response'];
      if (payload is! Map<String, dynamic>) return null;

      return DictionaryResponseDto.fromJson(payload);
    } on Object {
      return null;
    }
  }

  /// Stores a response against [word].
  ///
  /// Never throws: a cache write that fails must not turn a successful look-up
  /// into a failed one.
  Future<void> write(String word, DictionaryResponseDto response) async {
    try {
      final file = await fileFor(word);
      await file.writeAsString(
        jsonEncode(<String, Object?>{
          'cachedAt': _now().toUtc().millisecondsSinceEpoch,
          'response': response.toJson(),
        }),
      );
    } on Object {
      // Deliberately swallowed. See the doc comment.
    }
  }

  /// Removes every cached response.
  ///
  /// Used by *Delete all data* (F-078). Safe to call when nothing is cached.
  Future<void> clear() async {
    try {
      final dir = await directory();
      if (dir.existsSync()) await dir.delete(recursive: true);
      _directory = null;
    } on Object {
      // Nothing here is user data; failing to clear it is not worth an error.
    }
  }
}
