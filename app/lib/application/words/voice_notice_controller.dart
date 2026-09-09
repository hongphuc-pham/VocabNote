/// The one-time "no British voice on this device" notice.
///
/// `docs/DATA-SOURCES.md` §4: if no `en-GB` voice exists, fall back to `en-US`
/// and **say so once**, with a pointer to the OS voice settings.
library;

// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';

part 'voice_notice_controller.g.dart';

/// Whether the voice-fallback notice should be on screen right now.
///
/// True only when all three hold: the device really did fall back, the user has
/// not already been told, and this session has not just dismissed it.
///
/// Resolving the voice is a platform round trip, so this is a provider rather
/// than something the screen works out for itself on every build.
@riverpod
class VoiceNotice extends _$VoiceNotice {
  @override
  Future<bool> build() async {
    final shown = await ref
        .read(settingsRepositoryProvider)
        .isVoiceNoticeShown();

    // Already told once. Nothing else needs checking, and in particular the
    // speech engine does not need waking to answer a question we will not ask.
    if (shown.valueOrNull ?? true) return false;

    final settings = ref.watch(appSettingsOrDefaultsProvider);
    final resolved = await ref
        .read(speechServiceProvider)
        .resolveVoice(settings.ttsLocale);

    // A failure here is not a reason to nag: if the engine could not be asked,
    // the honest answer is "we do not know", and silence beats a wrong warning.
    return resolved.valueOrNull?.isFallback ?? false;
  }

  /// Dismisses the notice permanently.
  Future<void> dismiss() async {
    state = const AsyncValue<bool>.data(false);
    await ref.read(settingsRepositoryProvider).markVoiceNoticeShown();
  }
}
