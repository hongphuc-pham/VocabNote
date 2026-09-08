// Regenerates the offline IPA fallback asset from CMUdict (F-005).
//
//   dart run tool/build_ipa_fallback.dart
//
// Downloads a **pinned** CMUdict revision, converts ARPAbet to IPA using the
// committed table in `arpabet_to_ipa.dart`, and writes
// `assets/data/ipa_fallback.json.gz`.
//
// The revision, the mapping and this script are all committed, so the asset is
// reproducible: anyone can re-run this and get byte-for-byte the same file.
//
// Licence: CMU Pronouncing Dictionary, Carnegie Mellon University.
// Unrestricted for research and commercial use; CMU asks that its origin be
// acknowledged, which the app does in Settings -> Data sources & licences.
// US English only, and a broad transcription - see docs/DATA-SOURCES.md §2.
import 'dart:convert';
import 'dart:io';

import 'arpabet_to_ipa.dart';

/// The exact CMUdict revision this asset is built from.
///
/// A commit SHA, never `master`: the asset must be reproducible, and a moving
/// branch would mean two people running this script get different files.
const String cmudictCommit = '0f8072f814306c5ee4fbf992ed853601b12c01f9';

/// Where that revision's dictionary file lives.
const String cmudictUrl =
    'https://raw.githubusercontent.com/cmusphinx/cmudict/'
    '$cmudictCommit/cmudict.dict';

/// The asset written by this script.
const String outputPath = 'assets/data/ipa_fallback.json.gz';

/// The format version, so the reader can refuse a file it does not understand
/// rather than misparsing it.
const int assetFormatVersion = 1;

Future<void> main(List<String> args) async {
  final raw = await _fetchCmudict();
  stdout.writeln('Downloaded ${raw.length} bytes from CMUdict $cmudictCommit');

  final entries = _convert(raw);
  stdout.writeln('Converted ${entries.length} entries to IPA');

  final payload = <String, Object?>{
    'formatVersion': assetFormatVersion,
    'source': 'CMU Pronouncing Dictionary',
    'sourceUrl': 'https://github.com/cmusphinx/cmudict',
    'commit': cmudictCommit,
    'licence':
        'Unrestricted for research and commercial use; origin acknowledged.',
    'accent': 'en-US',
    'generatedBy': 'tool/build_ipa_fallback.dart',
    'entries': entries,
  };

  final json = utf8.encode(jsonEncode(payload));
  final gzipped = gzip.encode(json);

  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(gzipped);

  stdout
    ..writeln('Wrote $outputPath')
    ..writeln(
      '  ${(json.length / 1024 / 1024).toStringAsFixed(1)} MB JSON -> '
      '${(gzipped.length / 1024 / 1024).toStringAsFixed(1)} MB gzipped',
    );
}

Future<String> _fetchCmudict() async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(cmudictUrl));
    final response = await request.close();
    if (response.statusCode != 200) {
      stderr.writeln('CMUdict download failed: HTTP ${response.statusCode}');
      exit(1);
    }
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

/// Converts the dictionary text into `{word: ipa}`.
///
/// CMUdict lines look like:
///
///     cough K AO1 F
///     cough(2) K AA1 F
///     ;;; a comment
///
/// Variants are suffixed `(2)`, `(3)` and so on. Only the **first** (the
/// primary) pronunciation is kept: this is a fallback offered to someone with
/// no network, not a pronunciation dictionary, and a single confident answer is
/// more useful in a text field than three.
Map<String, String> _convert(String raw) {
  final entries = <String, String>{};
  var skipped = 0;

  for (final line in const LineSplitter().convert(raw)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith(';;;')) continue;

    // Newer CMUdict revisions put a `#` comment after the pronunciation.
    final withoutComment = trimmed.split('#').first.trim();
    final parts = withoutComment.split(RegExp(r'\s+'));
    if (parts.length < 2) continue;

    final rawWord = parts.first;
    // Skip variants; keep only the primary pronunciation.
    if (rawWord.contains('(')) continue;

    final word = rawWord.toLowerCase();
    // CMUdict includes punctuation entries like `!exclamation-point`.
    if (!RegExp(r"^[a-z][a-z'.\-]*$").hasMatch(word)) continue;

    final ipa = arpabetLineToIpa(parts.sublist(1));
    if (ipa == null) {
      skipped++;
      continue;
    }
    entries[word] = ipa;
  }

  if (skipped > 0) {
    stdout.writeln('  skipped $skipped entries with unmappable phonemes');
  }
  return entries;
}
