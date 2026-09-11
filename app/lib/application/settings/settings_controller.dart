/// Reading the settings row.
///
/// The settings *screen* is M6 (F-070). This is only the read side, which M3
/// needs first: speech rate, pitch, preferred voice and autoplay all live in
/// that row, and the word detail screen cannot speak without them.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';

part 'settings_controller.g.dart';

/// The user's settings, kept current.
///
/// Watched rather than read once so that changing the speech rate in Settings
/// takes effect on a detail screen that is already open, without the screen
/// knowing anything happened.
///
/// Kept alive because almost every screen ends up wanting it, and re-reading
/// the same single row each time a screen is pushed is pure waste.
@Riverpod(keepAlive: true)
Stream<AppSettings> appSettings(Ref ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watchSettings()
      .map(
        (result) => result.fold(
          (settings) => settings,
          // Rethrown into Riverpod's error capture, which surfaces it to the
          // widget as AsyncValue.error (`docs/RULES.md` §24).
          (failure) => throw failure,
        ),
      );
}

/// The settings, or the documented defaults while they are still loading.
///
/// Speech is the reason this exists: a play button that is disabled for the
/// first frame because a single-row query has not come back yet would be a
/// worse experience than one that briefly uses the default rate. Reading a
/// wrong-but-sane rate for one frame costs nothing; refusing to speak does.
@Riverpod(keepAlive: true)
AppSettings appSettingsOrDefaults(Ref ref) =>
    ref.watch(appSettingsProvider).value ?? AppSettings.defaults;
