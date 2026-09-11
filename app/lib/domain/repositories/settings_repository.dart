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

  /// Reads the row, applies [change], and writes the result, as one step.
  ///
  /// What a single control should use. Two changes made at the same moment -
  /// a slider released while a switch flips - would otherwise each read the
  /// row, and the later write would put back the earlier one's stale copy.
  AsyncResult<void> update(AppSettings Function(AppSettings current) change);

  /// Restores every setting to its documented default.
  AsyncResult<void> resetToDefaults();

  /// Whether onboarding has been completed or skipped (F-077).
  AsyncResult<bool> isOnboardingComplete();

  /// Records that onboarding is done, so it is never shown again.
  AsyncResult<void> completeOnboarding();

  /// Whether the voice-fallback notice has already been shown.
  ///
  /// `docs/DATA-SOURCES.md` §4 says to tell the user **once** that their device
  /// has no en-GB voice. Repeating it every time they open a word would be
  /// nagging about something they may not be able to change.
  AsyncResult<bool> isVoiceNoticeShown();

  /// Records that the voice-fallback notice has been shown.
  AsyncResult<void> markVoiceNoticeShown();

  /// The local-only install identifier. Never transmitted.
  AsyncResult<String?> installId();

  /// When the last backup export succeeded, or null if never.
  AsyncResult<DateTime?> lastBackupAt();

  /// Records a successful backup export.
  AsyncResult<void> recordBackup(DateTime at);
}
