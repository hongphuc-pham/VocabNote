import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';

/// The bundled offline pronunciation fallback (F-005).
///
/// Reads `assets/data/ipa_fallback.json.gz`, generated from a pinned CMUdict
/// revision by `tool/build_ipa_fallback.dart`.
///
/// **US only, and a broad transcription.** CMUdict has no British entries, so
/// this fills `ipa_us` and deliberately leaves `ipa_uk` empty for the user to
/// type (`docs/DATA-SOURCES.md` §2). Presenting a US transcription as UK would
/// be worse than presenting nothing.
///
/// This is what makes *Look up* work on a plane, which is why it exists at all:
/// `docs/RULES.md` §2 says no feature may require a network.
class OfflineIpaSource {
  /// Creates the source.
  ///
  /// [_bundle] is injectable so tests can supply a small fixture instead of the
  /// real 126,000-entry asset.
  new({this._bundle, String? assetPath})
    : _assetPath = assetPath ?? defaultAssetPath;

  /// Where the generated asset lives.
  static const String defaultAssetPath = 'assets/data/ipa_fallback.json.gz';

  /// The asset layout this build understands.
  static const int supportedFormatVersion = 1;

  final AssetBundle? _bundle;
  final String _assetPath;

  Map<String, String>? _entries;
  Future<Map<String, String>>? _loading;

  /// Whether the dictionary is already in memory.
  bool get isLoaded => _entries != null;

  /// Looks up [word], or null when it is not in the dictionary.
  ///
  /// Matching uses the same normalisation as dedupe and search, so `Cough`,
  /// `cough` and `cough ` all find the same entry.
  Future<String?> ipaFor(String word) async {
    final normalized = Headword.normalize(word);
    if (normalized.isEmpty) return null;

    final entries = await _load();
    return entries[normalized];
  }

  /// Builds an offline suggestion set for [word].
  ///
  /// Returns an empty set - never null - when the word is unknown, so callers
  /// treat "no offline entry" the same as "no API results".
  Future<WordSuggestions> suggestionsFor(String word) async {
    final ipa = await ipaFor(word);

    if (ipa == null) {
      return WordSuggestions(headword: word, source: WordSource.offline);
    }

    return WordSuggestions(
      headword: word,
      source: WordSource.offline,
      // US only. There is deliberately no ipaUk suggestion.
      suggestions: <FieldSuggestion>[
        FieldSuggestion(
          field: SuggestionField.ipaUs,
          value: ipa,
          source: WordSource.offline,
          hint: 'offline',
        ),
      ],
      attribution: WordSuggestions.cmudictAttribution,
      sourceUrl: 'https://github.com/cmusphinx/cmudict',
    );
  }

  /// Drops the dictionary from memory.
  ///
  /// The parsed map is roughly 15 MB. It is loaded lazily - never at startup,
  /// which would blow the 2s cold-start budget in `F-092` - and kept afterwards
  /// because a user filling in words offline will look up several in a row.
  /// This exists so *Delete all data* and low-memory handling can let it go.
  void release() {
    _entries = null;
    _loading = null;
  }

  Future<Map<String, String>> _load() {
    final loaded = _entries;
    if (loaded != null) return Future<Map<String, String>>.value(loaded);

    // Concurrent callers share one load rather than each decompressing 3 MB.
    return _loading ??= _read().then((entries) {
      _entries = entries;
      _loading = null;
      return entries;
    });
  }

  Future<Map<String, String>> _read() async {
    try {
      final bundle = _bundle ?? rootBundle;
      final compressed = await bundle.load(_assetPath);
      final bytes = compressed.buffer.asUint8List(
        compressed.offsetInBytes,
        compressed.lengthInBytes,
      );

      // Decompressing and parsing 3 MB of JSON blocks long enough to drop
      // frames, so it happens off the main thread.
      return await compute(_decodeAsset, bytes);
    } on Object catch (error, stackTrace) {
      // A missing or corrupt asset degrades to "no offline entries". The user
      // can still type the IPA, which is the whole point of F-005 being a
      // fallback rather than a dependency.
      assert(() {
        debugPrint('Offline IPA asset unavailable: $error\n$stackTrace');
        return true;
      }(), 'debugPrint always returns true');
      return <String, String>{};
    }
  }
}

/// Decompresses and parses the asset. Top-level so it can run in an isolate.
Map<String, String> _decodeAsset(Uint8List bytes) {
  final json = jsonDecode(utf8.decode(gzip.decode(bytes)));
  if (json is! Map<String, dynamic>) return <String, String>{};

  // Refuse a layout this build does not understand rather than misreading it.
  final version = json['formatVersion'];
  if (version != OfflineIpaSource.supportedFormatVersion) {
    return <String, String>{};
  }

  final entries = json['entries'];
  if (entries is! Map<String, dynamic>) return <String, String>{};

  return <String, String>{
    for (final entry in entries.entries)
      if (entry.value is String) entry.key: entry.value as String,
  };
}
