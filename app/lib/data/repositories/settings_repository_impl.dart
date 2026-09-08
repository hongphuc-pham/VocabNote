import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/app_meta.dart';
import 'package:vocabnote/data/repositories/mappers.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/repositories/settings_repository.dart';

/// Drift-backed [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates the repository over the given database.
  new(this._db);

  final AppDatabase _db;

  AppFailure _dbFailure(String operation) =>
      DatabaseFailure(operation: operation);

  @override
  ResultStream<AppSettings> watchSettings() => _db.settingsDao
      .watchSettings()
      .map((row) => row.toEntity())
      .guarded(onError: (_, _) => _dbFailure('watch settings'));

  @override
  AsyncResult<AppSettings> getSettings() => Results.guard(
    () async => (await _db.settingsDao.getSettings()).toEntity(),
    onError: (_, _) => _dbFailure('read settings'),
  );

  @override
  AsyncResult<void> save(AppSettings settings) => Results.guard(
    () => _db.settingsDao.updateSettings(settings.toCompanion()),
    onError: (_, _) => _dbFailure('save settings'),
  );

  @override
  AsyncResult<void> resetToDefaults() => Results.guard(
    () => _db.settingsDao.resetToDefaults(),
    onError: (_, _) => _dbFailure('reset settings'),
  );

  @override
  AsyncResult<bool> isOnboardingComplete() => Results.guard(
    () => _db.metaDao.getBool(AppMetaKeys.onboardingCompleted),
    onError: (_, _) => _dbFailure('read onboarding state'),
  );

  @override
  AsyncResult<void> completeOnboarding() => Results.guard(
    () => _db.metaDao.setBool(AppMetaKeys.onboardingCompleted, value: true),
    onError: (_, _) => _dbFailure('complete onboarding'),
  );

  @override
  AsyncResult<String?> installId() => Results.guard(
    // Random, local-only, and never transmitted (DATA-SOURCES.md §7).
    () => _db.metaDao.get(AppMetaKeys.installId),
    onError: (_, _) => _dbFailure('read install id'),
  );

  @override
  AsyncResult<DateTime?> lastBackupAt() => Results.guard(
    () => _db.metaDao.getTimestamp(AppMetaKeys.lastBackupAt),
    onError: (_, _) => _dbFailure('read last backup time'),
  );

  @override
  AsyncResult<void> recordBackup(DateTime at) => Results.guard(
    () => _db.metaDao.setTimestamp(AppMetaKeys.lastBackupAt, at),
    onError: (_, _) => _dbFailure('record backup'),
  );
}
