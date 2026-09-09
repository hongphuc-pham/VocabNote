import 'dart:async';

// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncResult;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/repositories/speech_service.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';
import 'package:vocabnote/domain/value_objects/voice_resolution.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';

/// One recorded utterance.
typedef _Utterance = ({String text, TtsLocale? locale, double? rate});

/// Records what was spoken instead of speaking it.
///
/// A recording fake rather than a mock: every assertion here is about *what
/// the screen asked for* — which accent, at which rate — which reads more
/// directly as a recorded list than as a stack of `verify` calls.
class _FakeSpeech implements SpeechService {
  final List<_Utterance> spoken = <_Utterance>[];
  int stops = 0;

  /// Makes the next `speak` fail, as a device with no voice does.
  bool failNext = false;

  /// Makes voice resolution report a fallback, as a device with no en-GB voice
  /// does (`DATA-SOURCES.md` §4).
  bool forceFallback = false;

  @override
  AsyncResult<Set<TtsLocale>> availableLocales() async =>
      const Ok<Set<TtsLocale>, AppFailure>(<TtsLocale>{TtsLocale.enGb});

  @override
  AsyncResult<VoiceResolution> resolveVoice(TtsLocale preferred) async =>
      Ok<VoiceResolution, AppFailure>(
        VoiceResolution(
          preferred: preferred,
          resolved: forceFallback ? null : preferred,
        ),
      );

  @override
  AsyncResult<void> speak(
    String text, {
    TtsLocale? locale,
    double? rate,
    double? pitch,
  }) async {
    spoken.add((text: text, locale: locale, rate: rate));
    if (failNext) {
      failNext = false;
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

/// The word detail screen (F-020, F-021, `docs/UI-UX.md` §4.3).
///
/// Driven against a real in-memory database exactly as `words_screen_test.dart`
/// is, and navigated through the real router so the route wiring is covered
/// too. Only the speech engine is faked: a widget test has no audio device.
void main() {
  late AppDatabase db;
  late _FakeSpeech speech;
  late ProviderContainer container;

  /// Seeds one word and returns its id.
  Future<String> seedWord({
    String? ipaUk = 'kɒf',
    String? ipaUs = 'kɔːf',
    String? definition,
    String? partOfSpeech,
  }) async {
    final now = DateTime.now();
    final result = await container
        .read(wordRepositoryProvider)
        .createWord(
          word: Word(
            id: 'word-1',
            headword: Headword('cough'),
            createdAt: now,
            updatedAt: now,
            ipaUk: ipaUk == null ? null : Ipa.fromStorage(ipaUk),
            ipaUs: ipaUs == null ? null : Ipa.fromStorage(ipaUs),
            definition: definition,
            partOfSpeech: partOfSpeech,
          ),
        );
    expect(result.isOk, isTrue, reason: 'seeding must succeed');
    return result.valueOrNull!.id;
  }

  Future<void> pumpDetail(WidgetTester tester, String id) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(container.read(appRouterProvider).push('/words/$id'));
    await tester.pumpAndSettle();
  }

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    speech = _FakeSpeech();
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db, speechService: speech),
      ],
    );
    // Container first, then the database: closing Drift while a provider still
    // holds a live watch deadlocks the test after its body has finished.
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  group('layout', () {
    testWidgets('shows the headword, both accents and the definition', (
      tester,
    ) async {
      final id = await seedWord(
        definition: 'To expel air from the lungs',
        partOfSpeech: 'verb',
      );
      await pumpDetail(tester, id);

      expect(find.text('cough'), findsWidgets);
      expect(find.text('verb'), findsOneWidget);
      expect(find.text('UK'), findsOneWidget);
      expect(find.text('US'), findsOneWidget);
      expect(find.text('To expel air from the lungs'), findsOneWidget);
    });

    testWidgets('shows only the accent the word actually has', (tester) async {
      final id = await seedWord(ipaUk: null);
      await pumpDetail(tester, id);

      expect(find.text('US'), findsOneWidget);
      expect(find.text('UK'), findsNothing);
    });

    testWidgets('invites a transcription when the word has none', (
      tester,
    ) async {
      final id = await seedWord(ipaUk: null, ipaUs: null);
      await pumpDetail(tester, id);

      expect(find.text('No pronunciation yet'), findsOneWidget);
      expect(find.text('UK'), findsNothing);
    });

    testWidgets('says so when the word has been deleted', (tester) async {
      final id = await seedWord();
      await container.read(wordRepositoryProvider).softDelete(id);

      await pumpDetail(tester, id);

      expect(find.text('This word is gone'), findsOneWidget);
    });
  });

  group('playback', () {
    testWidgets('tapping play speaks the word in that row accent', (
      tester,
    ) async {
      final id = await seedWord();
      await pumpDetail(tester, id);

      await tester.tap(find.bySemanticsLabel('Play cough in UK'));
      await tester.pumpAndSettle();

      expect(speech.spoken, hasLength(1));
      expect(speech.spoken.single.text, 'cough');
      expect(speech.spoken.single.locale, TtsLocale.enGb);
      expect(speech.spoken.single.rate, AppSettings.defaults.ttsRate);
    });

    testWidgets('the US row speaks American English', (tester) async {
      final id = await seedWord();
      await pumpDetail(tester, id);

      await tester.tap(find.bySemanticsLabel('Play cough in US'));
      await tester.pumpAndSettle();

      expect(speech.spoken.single.locale, TtsLocale.enUs);
    });

    testWidgets('long-pressing play replays at 0.6x (F-021)', (tester) async {
      final id = await seedWord();
      await pumpDetail(tester, id);

      await tester.longPress(find.bySemanticsLabel('Play cough in UK'));
      await tester.pumpAndSettle();

      expect(speech.spoken.single.rate, AppSettings.defaults.slowTtsRate);
      expect(
        speech.spoken.single.rate,
        lessThan(AppSettings.defaults.ttsRate),
        reason: 'slow replay must actually be slower than a normal one',
      );
    });

    testWidgets('a device with no voice says so rather than failing silently', (
      tester,
    ) async {
      final id = await seedWord();
      await pumpDetail(tester, id);
      speech.failNext = true;

      await tester.tap(find.bySemanticsLabel('Play cough in UK'));
      await tester.pumpAndSettle();

      expect(
        find.text('This device has no speech voice available.'),
        findsOneWidget,
      );
    });

    testWidgets('stays quiet on open unless the setting asks for autoplay', (
      tester,
    ) async {
      final id = await seedWord();
      await pumpDetail(tester, id);

      expect(
        AppSettings.defaults.autoplayOnOpen,
        isFalse,
        reason: 'the default this test relies on',
      );
      expect(speech.spoken, isEmpty);
    });

    testWidgets('speaks on open when autoplay is on', (tester) async {
      final id = await seedWord();
      final settings = container.read(settingsRepositoryProvider);
      await settings.save(
        AppSettings.defaults.copyWith(
          autoplayOnOpen: true,
          ttsLocale: TtsLocale.enUs,
        ),
      );

      await pumpDetail(tester, id);

      expect(speech.spoken, hasLength(1));
      expect(speech.spoken.single.locale, TtsLocale.enUs);
    });
  });

  group('highlights', () {
    testWidgets('paints a saved highlight on its own transcription only', (
      tester,
    ) async {
      final id = await seedWord();
      await container
          .read(wordRepositoryProvider)
          .replaceHighlights(
            wordId: id,
            target: HighlightTarget.ipaUk,
            highlights: <IpaHighlight>[
              IpaHighlight(
                id: 'h1',
                wordId: id,
                target: HighlightTarget.ipaUk,
                // The "ɒ" in /kɒf/ — one grapheme, deliberately not the first.
                range: GraphemeRange(1, 2),
                color: IpaColorToken.amber,
                createdAt: DateTime.now(),
              ),
            ],
          );

      await pumpDetail(tester, id);

      final rows = tester.widgetList<IpaText>(find.byType(IpaText)).toList();
      expect(rows, hasLength(2), reason: 'one row per accent');

      final uk = rows.firstWhere((row) => row.ipa == 'kɒf');
      final us = rows.firstWhere((row) => row.ipa == 'kɔːf');

      expect(uk.highlights, hasLength(1));
      expect(uk.highlights.single.range, GraphemeRange(1, 2));
      expect(
        us.highlights,
        isEmpty,
        reason: 'a UK highlight must never leak onto the US transcription',
      );
    });
  });

  group('the voice notice (DATA-SOURCES §4)', () {
    testWidgets('stays hidden when the preferred voice exists', (tester) async {
      final id = await seedWord();
      await pumpDetail(tester, id);

      expect(find.text('Got it'), findsNothing);
    });

    testWidgets('says so once when the device fell back to another voice', (
      tester,
    ) async {
      speech.forceFallback = true;
      final id = await seedWord();
      await pumpDetail(tester, id);

      expect(find.text('Got it'), findsOneWidget);
    });

    testWidgets('dismissing it records the fact, so it never returns', (
      tester,
    ) async {
      speech.forceFallback = true;
      final id = await seedWord();
      await pumpDetail(tester, id);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('Got it'), findsNothing);

      final recorded = await container
          .read(settingsRepositoryProvider)
          .isVoiceNoticeShown();
      expect(
        recorded.valueOrNull,
        isTrue,
        reason: 'a notice shown again after dismissal is nagging',
      );
    });
  });
}
