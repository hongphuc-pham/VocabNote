import 'package:drift/drift.dart';

/// `app_meta` - loose key/value state that has no business being a column.
///
/// Holds `schema_version_mirror`, `onboarding_completed`, `last_backup_at` and
/// `install_id`. The install id is random, local-only and **never
/// transmitted** - there is no backend to transmit it to
/// (`docs/DATA-SOURCES.md` section 7).
///
/// Typed settings live in `settings`, not here: this table is for values whose
/// shape may change, and a string is the honest type for that.
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  /// The key.
  TextColumn get key => text()();

  /// The value, always a string. Callers parse.
  TextColumn get value => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// The keys `app_meta` is known to hold.
///
/// Named constants rather than string literals scattered across the app, so a
/// typo is a compile error instead of a silently missing setting.
abstract final class AppMetaKeys {
  /// Mirrors `schemaVersion`, so a future bootstrap can read the on-disk
  /// version without going through Drift (`docs/DATABASE.md` section 3.10).
  static const String schemaVersionMirror = 'schema_version_mirror';

  /// `true` once the user has finished or skipped onboarding (F-077).
  static const String onboardingCompleted = 'onboarding_completed';

  /// Epoch milliseconds of the last successful backup export.
  static const String lastBackupAt = 'last_backup_at';

  /// A random, local-only identifier. Never leaves the device.
  static const String installId = 'install_id';

  /// Whether the "this device has no en-GB voice" notice has been shown.
  ///
  /// Shown once and then never again (`docs/DATA-SOURCES.md` §4). A key rather
  /// than a settings column because it is a one-off acknowledgement, not
  /// something the user configures — and `app_meta` is where loose state goes.
  static const String voiceFallbackNoticeShown = 'voice_fallback_notice_shown';
}
