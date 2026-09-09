import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/repositories/speech_service.dart';
import 'package:vocabnote/domain/value_objects/voice_resolution.dart';

/// [SpeechService] over the device engine (ADR-003).
///
/// The only file in the app that names `flutter_tts`. Everything above `data/`
/// talks to [SpeechService], which is what lets F-027 (record yourself) and
/// F-028 (Wikimedia recordings) arrive later without a screen changing.
///
/// **Nothing touches a platform channel until the first call.** Construction
/// happens in `repositoryOverrides`, which widget tests also run, and a plugin
/// call during `ProviderContainer` set-up would fail there for no good reason.
class FlutterTtsService implements SpeechService {
  /// Creates the service.
  ///
  /// [engine] is injectable so tests can assert the policy — fallback order,
  /// clamping, error mapping — against a mock instead of a real speech engine.
  new({FlutterTts? engine}) : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;

  /// Whether [FlutterTts.awaitSpeakCompletion] has been switched on.
  ///
  /// Set once. Without it `speak` returns as soon as the utterance *starts*,
  /// and a play button would drop back to its idle state immediately.
  bool _awaitsCompletion = false;

  /// The resolved voice, cached — see [resolveVoice].
  VoiceResolution? _resolution;

  // What the engine was last told. Re-sending an unchanged value is a wasted
  // platform round trip on every tap of the play button.
  String? _appliedLanguage;
  double? _appliedRate;
  double? _appliedPitch;

  /// The order [resolveVoice] tries, per `docs/DATA-SOURCES.md` §4:
  /// the preferred voice, then the other English one, then the device default.
  static List<TtsLocale> _fallbackOrder(TtsLocale preferred) => <TtsLocale>[
    preferred,
    ...TtsLocale.values.where((locale) => locale != preferred),
  ];

  /// Maps anything the plugin throws onto a named failure.
  ///
  /// [UnavailableFailure] rather than [UnexpectedFailure]: when a speech engine
  /// throws it is almost always because the device has no usable one, which is
  /// a capability the user can install, not a bug they should see a crash for.
  AppFailure _speechFailure(Object error, StackTrace stackTrace) =>
      UnavailableFailure(
        capability: 'text-to-speech',
        cause: error,
        stackTrace: stackTrace,
      );

  @override
  AsyncResult<Set<TtsLocale>> availableLocales() => Results.guard(() async {
    final available = <TtsLocale>{};
    for (final locale in TtsLocale.values) {
      if (await _hasVoice(locale)) available.add(locale);
    }
    return available;
  }, onError: _speechFailure);

  @override
  AsyncResult<VoiceResolution> resolveVoice(TtsLocale preferred) {
    final cached = _resolution;
    if (cached != null && cached.preferred == preferred) {
      return Future<AppResult<VoiceResolution>>.value(
        Ok<VoiceResolution, AppFailure>(cached),
      );
    }

    return Results.guard(() async {
      for (final candidate in _fallbackOrder(preferred)) {
        if (await _hasVoice(candidate)) {
          return _resolution = VoiceResolution(
            preferred: preferred,
            resolved: candidate,
          );
        }
      }
      // No English voice at all. Speech still goes ahead on whatever the device
      // defaults to — a rough approximation beats silence, and refusing would
      // make the feature depend on a voice pack the user may not know to
      // install.
      return _resolution = VoiceResolution(preferred: preferred);
    }, onError: _speechFailure);
  }

  @override
  AsyncResult<void> speak(
    String text, {
    TtsLocale? locale,
    double? rate,
    double? pitch,
  }) {
    final utterance = text.trim();
    // Not an error: an empty transcription field is ordinary, and a play button
    // that reports a failure for one would be noise.
    if (utterance.isEmpty) {
      return Future<AppResult<void>>.value(const Ok<void, AppFailure>(null));
    }

    return Results.guard(() async {
      if (!_awaitsCompletion) {
        await _engine.awaitSpeakCompletion(true);
        _awaitsCompletion = true;
      }

      // Replace rather than queue: tapping play twice means "say it again".
      await _engine.stop();

      final language = locale?.storageValue ?? _resolution?.languageTag;
      if (language != null && language != _appliedLanguage) {
        await _engine.setLanguage(language);
        _appliedLanguage = language;
      }

      if (rate != null) {
        final clamped = rate.clamp(_minRate, _maxRate);
        if (clamped != _appliedRate) {
          await _engine.setSpeechRate(clamped);
          _appliedRate = clamped;
        }
      }

      if (pitch != null) {
        final clamped = pitch.clamp(_minPitch, _maxPitch);
        if (clamped != _appliedPitch) {
          await _engine.setPitch(clamped);
          _appliedPitch = clamped;
        }
      }

      await _engine.speak(utterance);
    }, onError: _speechFailure);
  }

  @override
  AsyncResult<void> stop() => Results.guard(() async {
    await _engine.stop();
  }, onError: _speechFailure);

  @override
  Future<void> dispose() async {
    // Swallowed on purpose: tearing the app down is not a moment at which a
    // speech engine complaint is worth surfacing, or can be acted on.
    try {
      await _engine.stop();
    } on Object {
      // See above.
    }
  }

  /// Whether the device can speak [locale].
  ///
  /// `isLanguageAvailable` answers `dynamic`, and a null means "the platform
  /// did not say", which is treated as absent so the fallback keeps looking.
  Future<bool> _hasVoice(TtsLocale locale) async {
    final answer = await _engine.isLanguageAvailable(locale.storageValue);
    return answer is bool && answer;
  }

  // The ranges `AppSettings` documents: rate 0.0-1.0, pitch 0.5-2.0. Clamped
  // rather than rejected — a value out of range is a caller bug, and refusing
  // to make a sound is a worse outcome than speaking slightly wrong.
  static const double _minRate = 0;
  static const double _maxRate = 1;
  static const double _minPitch = 0.5;
  static const double _maxPitch = 2;
}
