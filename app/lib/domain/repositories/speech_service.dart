/// The audio layer, as an interface (ADR-003).
///
/// v1 speaks through the device engine: offline, no storage cost, no licence
/// obligation, and every word works including names and rare terms
/// (`docs/DATA-SOURCES.md` §4). The trade-off is that it is a synthesised
/// reference rather than a native speaker, which the *How to use* guide says
/// in one plain sentence.
///
/// It is an interface so that F-028 (Wikimedia recordings) and F-027 (record
/// yourself) can arrive later as another implementation, without a single
/// screen changing. That is the whole point of ADR-003, so nothing above
/// `data/` may name a speech plugin.
library;

import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/value_objects/voice_resolution.dart';

/// Speaks text aloud.
abstract interface class SpeechService {
  /// Which of the app's two English voices this device actually has.
  ///
  /// Empty means neither — speech still works, on the device default.
  AsyncResult<Set<TtsLocale>> availableLocales();

  /// Resolves [preferred] against the device, `en-GB → en-US → device default`.
  ///
  /// Implementations cache the answer: this is a platform-channel round trip
  /// and the result cannot change while the app is in the foreground.
  AsyncResult<VoiceResolution> resolveVoice(TtsLocale preferred);

  /// Speaks [text], and completes when the utterance finishes.
  ///
  /// Completing at the *end* rather than the start is what lets a play button
  /// show a speaking state without a second callback channel. Any utterance
  /// already in progress is replaced, not queued: tapping play twice means
  /// "say it again", never "say it twice".
  ///
  /// [locale] falls back to the resolved voice, [rate] and [pitch] to the
  /// settings row. [rate] is 0.0–1.0 and [pitch] 0.5–2.0, matching
  /// [AppSettings]; both are clamped rather than rejected, because a rate out
  /// of range is a caller bug that should still make a sound.
  AsyncResult<void> speak(
    String text, {
    TtsLocale? locale,
    double? rate,
    double? pitch,
  });

  /// Stops any utterance in progress. Safe to call when nothing is speaking.
  AsyncResult<void> stop();

  /// Releases the engine. Called when the app is torn down.
  Future<void> dispose();
}
