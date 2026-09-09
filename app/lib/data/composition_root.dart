// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/dictionary/dictionary_cache.dart';
import 'package:vocabnote/data/dictionary/free_dictionary_client.dart';
import 'package:vocabnote/data/dictionary/offline_ipa_source.dart';
import 'package:vocabnote/data/repositories/dictionary_repository_impl.dart';
import 'package:vocabnote/data/repositories/list_repository_impl.dart';
import 'package:vocabnote/data/repositories/practice_repository_impl.dart';
import 'package:vocabnote/data/repositories/settings_repository_impl.dart';
import 'package:vocabnote/data/repositories/word_repository_impl.dart';

/// Wires `data/` implementations into the `application/` DI seam.
///
/// The one place concrete classes are named. `application/repositories.dart`
/// declares each provider against its `domain/` interface and throws by
/// default; this supplies the real thing.
///
/// Kept in `data/` rather than in `bootstrap.dart` so tests can build the same
/// overrides against an in-memory database with one call, instead of
/// duplicating this list and drifting from it.
List<Override> repositoryOverrides(AppDatabase database, {String? appVersion}) {
  final offline = OfflineIpaSource();
  final client = FreeDictionaryClient(
    // Descriptive, as community APIs expect (docs/DATA-SOURCES.md §1).
    userAgent:
        'VocabNote/${appVersion ?? '0.0.0'} '
        '(github.com/hongphuc-pham/VocabNote)',
  );

  return <Override>[
    wordRepositoryProvider.overrideWithValue(WordRepositoryImpl(database)),
    listRepositoryProvider.overrideWithValue(ListRepositoryImpl(database)),
    practiceRepositoryProvider.overrideWithValue(
      PracticeRepositoryImpl(database),
    ),
    settingsRepositoryProvider.overrideWithValue(
      SettingsRepositoryImpl(database),
    ),
    dictionaryRepositoryProvider.overrideWithValue(
      DictionaryRepositoryImpl(
        client: client,
        cache: DictionaryCache(),
        offline: offline,
      ),
    ),
  ];
}

/// Removes words the user deleted more than 30 days ago.
///
/// The only hard delete of user content in the app, and only after the
/// retention window `docs/RULES.md` §10 allows. Run once per launch and
/// deliberately **not awaited** by `bootstrap`: a purge is housekeeping, and
/// making the user wait for it would eat into the 2s cold-start budget (F-092).
///
/// Failures are swallowed. Not purging is harmless - it happens again next
/// launch - whereas surfacing "could not delete your deleted words" would be a
/// confusing thing to greet someone with.
Future<void> purgeExpiredWords(AppDatabase database) async {
  try {
    await WordRepositoryImpl(database).purgeExpired();
  } on Object {
    // Deliberately ignored. See the doc comment.
  }
}

/// Reads the app version for the dictionary `User-Agent`.
///
/// Falls back rather than failing: a look-up must not depend on a platform
/// channel answering.
Future<String> resolveAppVersion() async {
  try {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  } on Object {
    return '0.0.0';
  }
}
