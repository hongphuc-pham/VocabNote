/// What the device actually offered when the app asked for a speech voice.
///
/// `docs/DATA-SOURCES.md` §4: voice selection is limited to what the user's
/// device has installed, and if no `en-GB` voice exists the app falls back to
/// `en-US` — and says so once, with a link to the OS voice settings. Saying so
/// requires knowing that a fallback happened, which is what this records.
///
/// Pure Dart — `domain/` imports nothing but Dart and freezed
/// (`docs/RULES.md` §20).
library;

import 'package:meta/meta.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';

/// The outcome of resolving a preferred voice against the device.
///
/// Resolved once at startup rather than per utterance: `getLanguages` is a
/// platform-channel round trip, and the answer cannot change while the app is
/// in the foreground without the user visiting OS settings.
@immutable
final class VoiceResolution {
  /// Records that [preferred] resolved to [resolved].
  ///
  /// Omitting [resolved] records that the device had no English voice at all.
  /// Speech still goes ahead on whatever the device defaults to: a synthesised
  /// approximation is more use than silence, and refusing to speak would make
  /// the feature depend on a voice pack the user may not know how to install.
  const new({required this.preferred, this.resolved});

  /// What the settings row asked for.
  final TtsLocale preferred;

  /// What will actually be spoken, or null when neither English voice exists
  /// and the device default is being used.
  final TtsLocale? resolved;

  /// Whether the user got something other than what they chose.
  ///
  /// The one-time notice (`DATA-SOURCES.md` §4) is shown exactly when this is
  /// true.
  bool get isFallback => resolved != preferred;

  /// The BCP-47 tag to hand the engine, or null to leave its language alone.
  String? get languageTag => resolved?.storageValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceResolution &&
          other.preferred == preferred &&
          other.resolved == resolved);

  @override
  int get hashCode => Object.hash(preferred, resolved);

  @override
  String toString() =>
      'VoiceResolution(preferred: ${preferred.storageValue}, '
      'resolved: ${resolved?.storageValue ?? 'device default'})';
}
