import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/data/speech/flutter_tts_service.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';

class _MockFlutterTts extends Mock implements FlutterTts;

/// Device speech (F-020, F-021, ADR-003).
///
/// The engine is mocked because the thing under test is the *policy* around it
/// — the `en-GB → en-US → device default` fallback (`DATA-SOURCES.md` §4),
/// clamping, and not letting a platform exception cross the layer boundary
/// (RULES §24). Whether Google TTS pronounces "cough" correctly is not
/// something a unit test can or should assert.
void main() {
  late _MockFlutterTts engine;
  late FlutterTtsService service;

  setUp(() {
    engine = _MockFlutterTts();
    // Every call the service makes, answered permissively by default. Tests
    // that care about a specific answer override the one stub they care about.
    when(() => engine.awaitSpeakCompletion(any())).thenAnswer((_) async => 1);
    when(() => engine.setLanguage(any())).thenAnswer((_) async => 1);
    when(() => engine.setSpeechRate(any())).thenAnswer((_) async => 1);
    when(() => engine.setPitch(any())).thenAnswer((_) async => 1);
    when(() => engine.speak(any())).thenAnswer((_) async => 1);
    when(engine.stop).thenAnswer((_) async => 1);
    when(() => engine.isLanguageAvailable(any())).thenAnswer((_) async => true);
    service = FlutterTtsService(engine: engine);
  });

  /// Makes the device claim exactly [tags] and nothing else.
  void deviceHas(Set<String> tags) {
    when(() => engine.isLanguageAvailable(any())).thenAnswer(
      (invocation) async =>
          tags.contains(invocation.positionalArguments.first as String),
    );
  }

  group('voice resolution', () {
    test('uses en-GB when the device has it', () async {
      deviceHas({'en-GB', 'en-US'});

      final result = await service.resolveVoice(TtsLocale.enGb);

      final resolution = result.valueOrNull!;
      expect(resolution.resolved, TtsLocale.enGb);
      expect(resolution.isFallback, isFalse);
    });

    test(
      'falls back to en-US when en-GB is missing, and records that it did',
      () async {
        deviceHas({'en-US'});

        final resolution = (await service.resolveVoice(TtsLocale.enGb))
            .valueOrNull!;

        expect(resolution.resolved, TtsLocale.enUs);
        expect(resolution.isFallback, isTrue);
        expect(resolution.preferred, TtsLocale.enGb);
      },
    );

    test(
      'falls back the other way too - en-US preferred, only en-GB present',
      () async {
        deviceHas({'en-GB'});

        final resolution = (await service.resolveVoice(TtsLocale.enUs))
            .valueOrNull!;

        expect(resolution.resolved, TtsLocale.enGb);
        expect(resolution.isFallback, isTrue);
      },
    );

    test(
      'falls back to the device default when neither voice exists',
      () async {
        deviceHas(<String>{});

        final resolution = (await service.resolveVoice(TtsLocale.enGb))
            .valueOrNull!;

        // Null means "leave the engine language alone" - speech still happens.
        expect(resolution.resolved, isNull);
        expect(resolution.isFallback, isTrue);
        expect(resolution.languageTag, isNull);
      },
    );

    test('is resolved once and cached - it is a platform round trip', () async {
      deviceHas({'en-GB'});

      await service.resolveVoice(TtsLocale.enGb);
      await service.resolveVoice(TtsLocale.enGb);

      verify(() => engine.isLanguageAvailable('en-GB')).called(1);
    });

    test('re-resolves when a different voice is preferred', () async {
      deviceHas({'en-GB', 'en-US'});

      await service.resolveVoice(TtsLocale.enGb);
      final second = (await service.resolveVoice(TtsLocale.enUs)).valueOrNull!;

      expect(second.resolved, TtsLocale.enUs);
    });

    test('a throwing engine becomes a failure, not an exception', () async {
      when(() => engine.isLanguageAvailable(any()))
          .thenThrow(Exception('no engine'));

      final result = await service.resolveVoice(TtsLocale.enGb);

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<UnavailableFailure>());
    });
  });

  group('available locales', () {
    test('reports both when the device has both', () async {
      deviceHas({'en-GB', 'en-US'});

      expect((await service.availableLocales()).valueOrNull, <TtsLocale>{
        TtsLocale.enGb,
        TtsLocale.enUs,
      });
    });

    test(
      'reports an empty set rather than failing when there are none',
      () async {
        deviceHas(<String>{});

        final result = await service.availableLocales();

        expect(result.isOk, isTrue);
        expect(result.valueOrNull, isEmpty);
      },
    );
  });

  group('speaking', () {
    test('applies language, rate and pitch before speaking', () async {
      deviceHas({'en-GB'});

      await service.speak('cough', locale: TtsLocale.enGb, rate: 0.5, pitch: 1);

      verifyInOrder(<Future<dynamic> Function()>[
        () => engine.setLanguage('en-GB'),
        () => engine.setSpeechRate(0.5),
        () => engine.setPitch(1),
        () => engine.speak('cough'),
      ]);
    });

    test(
      'awaits completion, so a caller knows when the word has finished',
      () async {
        await service.speak('cough');

        verify(() => engine.awaitSpeakCompletion(true)).called(1);
      },
    );

    test('configures completion awaiting once, not per utterance', () async {
      await service.speak('cough');
      await service.speak('cough');

      verify(() => engine.awaitSpeakCompletion(true)).called(1);
    });

    test(
      'stops whatever is speaking first - tapping play twice means again',
      () async {
        await service.speak('cough');

        verifyInOrder(<Future<dynamic> Function()>[
          engine.stop,
          () => engine.speak('cough'),
        ]);
      },
    );

    test(
      'clamps a rate above the documented range instead of refusing it',
      () async {
        await service.speak('cough', rate: 4);

        verify(() => engine.setSpeechRate(1)).called(1);
      },
    );

    test('clamps a negative rate to zero', () async {
      await service.speak('cough', rate: -1);

      verify(() => engine.setSpeechRate(0)).called(1);
    });

    test('clamps pitch to the 0.5-2.0 the settings row documents', () async {
      await service.speak('cough', pitch: 9);
      await service.speak('cough', pitch: 0.1);

      verify(() => engine.setPitch(2)).called(1);
      verify(() => engine.setPitch(0.5)).called(1);
    });

    test('slow replay at 0.6x of a normal rate reaches the engine', () async {
      // F-021: long-press plays at AppSettings.slowTtsRate, which is the
      // stored rate already multiplied by 0.6.
      await service.speak('cough', rate: AppSettings.defaults.slowTtsRate);

      verify(() => engine.setSpeechRate(any(that: closeTo(0.3, 0.0001))))
          .called(1);
    });

    test('does not re-send settings the engine already has', () async {
      await service.speak('cough', rate: 0.5, pitch: 1);
      await service.speak('through', rate: 0.5, pitch: 1);

      verify(() => engine.setSpeechRate(0.5)).called(1);
      verify(() => engine.setPitch(1)).called(1);
      verify(() => engine.speak(any())).called(2);
    });

    test('says nothing for blank text, and does not call the engine', () async {
      final result = await service.speak('   ');

      expect(result.isOk, isTrue);
      verifyNever(() => engine.speak(any()));
    });

    test('uses the resolved voice when the caller names none', () async {
      deviceHas({'en-US'});
      await service.resolveVoice(TtsLocale.enGb);

      await service.speak('cough');

      verify(() => engine.setLanguage('en-US')).called(1);
    });

    test('leaves the language alone when nothing has been resolved', () async {
      await service.speak('cough');

      verifyNever(() => engine.setLanguage(any()));
    });

    test('a throwing engine becomes a failure, not an exception', () async {
      when(() => engine.speak(any())).thenThrow(Exception('engine died'));

      final result = await service.speak('cough');

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<UnavailableFailure>());
    });
  });

  group('stopping', () {
    test('stops the engine', () async {
      expect((await service.stop()).isOk, isTrue);
      verify(engine.stop).called(1);
    });

    test('a throwing stop is a failure, not an exception', () async {
      when(engine.stop).thenThrow(Exception('nope'));

      expect((await service.stop()).isErr, isTrue);
    });

    test('dispose stops the engine and never throws', () async {
      when(engine.stop).thenThrow(Exception('nope'));

      await expectLater(service.dispose(), completes);
    });
  });
}
