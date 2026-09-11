/// Playing a word aloud (F-020, F-021).
library;

import 'dart:async';

import 'package:meta/meta.dart';
// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';

part 'pronunciation_controller.g.dart';

/// What, if anything, is being spoken right now.
@immutable
class PlaybackState {
  /// Creates a playback state. The default is silence.
  const new({this.speaking, this.slow = false});

  /// The accent currently being spoken, or null when nothing is.
  final TtsLocale? speaking;

  /// Whether this is the 0.6× slow replay (F-021).
  final bool slow;

  /// Whether [locale] is the one being spoken.
  bool isSpeaking(TtsLocale locale) => speaking == locale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackState &&
          other.speaking == speaking &&
          other.slow == slow);

  @override
  int get hashCode => Object.hash(speaking, slow);
}

/// Speaks transcriptions on demand.
///
/// Auto-disposed on purpose: leaving the screen disposes this, which stops the
/// engine. An app that carries on pronouncing a word the user has navigated
/// away from is the kind of thing people turn sound off over.
@riverpod
class Pronunciation extends _$Pronunciation {
  /// Distinguishes utterances so a finishing one cannot clear the state of the
  /// one that replaced it. Tapping play twice quickly is ordinary, and
  /// `speak()` deliberately replaces rather than queues.
  int _utterance = 0;

  bool _disposed = false;

  @override
  PlaybackState build() {
    // Captured now rather than read in the callback: Riverpod 3 forbids
    // touching `ref` from inside a life-cycle, and by the time dispose runs
    // there is no container left to read from anyway.
    final speech = ref.read(speechServiceProvider);

    ref.onDispose(() {
      _disposed = true;
      // Not awaited: dispose is synchronous, and the engine stopping a moment
      // later is fine. Failures are irrelevant at teardown.
      unawaited(speech.stop());
    });
    return const PlaybackState();
  }

  /// Speaks [text] in [locale], at the settings rate or [slow] at 0.6× of it.
  ///
  /// Returns the result so the screen can say something went wrong — most
  /// often that the device has no speech engine, which is a thing the user can
  /// fix and should therefore hear about.
  AsyncResult<void> play(
    String text, {
    required TtsLocale locale,
    bool slow = false,
  }) async {
    final settings = ref.read(appSettingsOrDefaultsProvider);
    final token = ++_utterance;

    state = PlaybackState(speaking: locale, slow: slow);

    final result = await ref
        .read(speechServiceProvider)
        .speak(
          text,
          locale: locale,
          rate: slow ? settings.slowTtsRate : settings.ttsRate,
          pitch: settings.ttsPitch,
        );

    // Only the newest utterance may clear the state, and only if the screen is
    // still there to see it.
    if (!_disposed && token == _utterance) state = const PlaybackState();
    return result;
  }

  /// Stops whatever is speaking.
  AsyncResult<void> stop() {
    _utterance++;
    if (!_disposed) state = const PlaybackState();
    return ref.read(speechServiceProvider).stop();
  }
}
