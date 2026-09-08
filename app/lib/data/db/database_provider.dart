import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/repositories/list_repository_impl.dart';
import 'package:vocabnote/data/repositories/practice_repository_impl.dart';
import 'package:vocabnote/data/repositories/settings_repository_impl.dart';
import 'package:vocabnote/data/repositories/word_repository_impl.dart';
import 'package:vocabnote/domain/repositories/list_repository.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/domain/repositories/settings_repository.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';

part 'database_provider.g.dart';

/// The open database.
///
/// Has no default: `bootstrap.dart` opens the database (taking a backup and
/// running migrations first) and overrides this provider with the result.
/// Reading it without that override is a programming error, and throwing says
/// so immediately rather than quietly opening a second, unmigrated database
/// somewhere unexpected.
///
/// Tests override it with `AppDatabase.memory()`.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in bootstrap() or in a test.',
  );
}

/// Words, notes and highlights.
@Riverpod(keepAlive: true)
WordRepository wordRepository(Ref ref) =>
    WordRepositoryImpl(ref.watch(appDatabaseProvider));

/// Lists (decks) and membership.
@Riverpod(keepAlive: true)
ListRepository listRepository(Ref ref) =>
    ListRepositoryImpl(ref.watch(appDatabaseProvider));

/// Study cards, sessions and answers.
@Riverpod(keepAlive: true)
PracticeRepository practiceRepository(Ref ref) =>
    PracticeRepositoryImpl(ref.watch(appDatabaseProvider));

/// The settings row and `app_meta`.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepositoryImpl(ref.watch(appDatabaseProvider));
