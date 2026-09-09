import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';

/// Reads and writes the user's settings (F-070).
///
/// Every write takes effect immediately: the UI watches [watchSettings] rather
/// than reading once at startup, so a change to speech rate or theme is visible
/// without a restart.
abstract interface class SettingsRepository {
  /// Watches the settings row.
  ResultStream<AppSettings> watchSettings();

  /// Reads the settings row once.
  AsyncResult<AppSettings> getSettings();

  /// Saves settings.
  AsyncResult<void> save(AppSettings settings);

  /// Restores every setting to its documented default.
  AsyncResult<void> resetToDefaults();

  /// Whether onboarding has been completed or skipped (F-077).
  AsyncResult<bool> isOnboardingComplete();

  /// Records that onboarding is done, so it is never shown again.
  AsyncResult<void> completeOnboarding();

  /// The local-only install identifier. Never transmitted.
  AsyncResult<String?> installId();

  /// When the last backup export succeeded, or null if never.
  AsyncResult<DateTime?> lastBackupAt();

  /// Records a successful backup export.
  AsyncResult<void> recordBackup(DateTime at);
}
