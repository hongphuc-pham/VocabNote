// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/repositories/speech_service.dart';
import 'package:vocabnote/domain/value_objects/voice_resolution.dart';

/// One recorded utterance.
typedef SpokenUtterance = ({
  String text,
  TtsLocale? locale,
  double? rate,
  double? pitch,
});

/// Records what would have been spoken instead of speaking it.
///
/// A widget test has no audio device, and every assertion worth making is
/// about *what was asked for* - which accent, at which rate and pitch.
class FakeSpeechService implements SpeechService {
  /// Everything `speak` was asked to say, in order.
  final List<SpokenUtterance> spoken = <SpokenUtterance>[];

  /// How many times `stop` was called.
  int stops = 0;

  /// Makes every `speak` fail, as a device with no voice does.
  bool fail = false;

  @override
  AsyncResult<Set<TtsLocale>> availableLocales() async =>
      const Ok<Set<TtsLocale>, AppFailure>(<TtsLocale>{
        TtsLocale.enGb,
        TtsLocale.enUs,
      });

  @override
  AsyncResult<VoiceResolution> resolveVoice(TtsLocale preferred) async =>
      Ok<VoiceResolution, AppFailure>(
        VoiceResolution(preferred: preferred, resolved: preferred),
      );

  @override
  AsyncResult<void> speak(
    String text, {
    TtsLocale? locale,
    double? rate,
    double? pitch,
  }) async {
    spoken.add((text: text, locale: locale, rate: rate, pitch: pitch));
    if (fail) {
      return const Err<void, AppFailure>(
        UnavailableFailure(capability: 'text-to-speech'),
      );
    }
    return const Ok<void, AppFailure>(null);
  }

  @override
  AsyncResult<void> stop() async {
    stops++;
    return const Ok<void, AppFailure>(null);
  }

  @override
  Future<void> dispose() async {}
}
