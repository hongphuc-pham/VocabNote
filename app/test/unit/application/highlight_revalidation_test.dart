import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncResult;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/words/highlight_revalidation.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

/// Highlights surviving an IPA edit (F-023).
///
/// The rule the acceptance criterion states: *ranges that still fit are kept;
/// ranges that don't are listed in a confirm dialog before being dropped.* So
/// the split has to be exactly right — keeping one that no longer fits would
/// paint a colour on symbols the user never chose, and dropping one that does
/// fit silently destroys their work.
void main() {
  IpaHighlight highlight({
    required String id,
    required int start,
    required int end,
    HighlightTarget target = HighlightTarget.ipaUk,
  }) => IpaHighlight(
    id: id,
    wordId: 'word-1',
    target: target,
    range: GraphemeRange(start, end),
    color: IpaColorToken.amber,
    createdAt: DateTime(2026, 9, 9),
  );

  group('the split', () {
    test('keeps everything when the transcription is unchanged', () {
      final result = revalidateHighlights(
        highlights: <IpaHighlight>[highlight(id: 'a', start: 0, end: 2)],
        ipaUk: 'kɒf',
        ipaUs: null,
      );

      expect(result.kept, hasLength(1));
      expect(result.hasLosses, isFalse);
    });

    test('keeps everything when the transcription gets longer', () {
      final result = revalidateHighlights(
        highlights: <IpaHighlight>[highlight(id: 'a', start: 0, end: 3)],
        ipaUk: 'kɒfɪŋ',
        ipaUs: null,
      );

      expect(result.hasLosses, isFalse);
    });

    test('drops only what no longer reaches, keeping the rest', () {
      final result = revalidateHighlights(
        highlights: <IpaHighlight>[
          highlight(id: 'fits', start: 0, end: 1),
          highlight(id: 'past-the-end', start: 2, end: 3),
        ],
        // 'kɒf' shortened to 'kɒ' - index 2 no longer exists.
        ipaUk: 'kɒ',
        ipaUs: null,
      );

      expect(result.kept.map((h) => h.id), <String>['fits']);
      expect(result.dropped.map((h) => h.id), <String>['past-the-end']);
    });

    test('a range ending exactly at the new length still fits', () {
      // Ranges are half-open: [0,2) over a 2-cluster string is the whole of it.
      final result = revalidateHighlights(
        highlights: <IpaHighlight>[highlight(id: 'edge', start: 0, end: 2)],
        ipaUk: 'kɒ',
        ipaUs: null,
      );

      expect(result.hasLosses, isFalse);
    });

    test('clearing a transcription drops its highlights', () {
      final result = revalidateHighlights(
        highlights: <IpaHighlight>[highlight(id: 'a', start: 0, end: 1)],
        ipaUk: null,
        ipaUs: null,
      );

      expect(result.dropped.map((h) => h.id), <String>['a']);
    });

    test('an empty transcription counts as cleared, not as length zero', () {
      final result = revalidateHighlights(
        highlights: <IpaHighlight>[highlight(id: 'a', start: 0, end: 1)],
        ipaUk: '',
        ipaUs: null,
      );

      expect(result.hasLosses, isTrue);
    });

    test('each transcription is judged against its own string', () {
      final result = revalidateHighlights(
        highlights: <IpaHighlight>[
          highlight(id: 'uk', start: 2, end: 3),
          highlight(id: 'us', start: 2, end: 3, target: HighlightTarget.ipaUs),
        ],
        // UK shortened, US left long.
        ipaUk: 'kɒ',
        ipaUs: 'kɔːf',
      );

      expect(result.dropped.map((h) => h.id), <String>['uk']);
      expect(result.kept.map((h) => h.id), <String>['us']);
    });

    test('measures in graphemes, not code units', () {
      // 't͡ʃɜː' is 3 clusters but 5 code units. A range of [0,3) fits the
      // clusters and would look out of range if anything counted code units.
      const affricate = 't͡ʃɜː';
      final result = revalidateHighlights(
        highlights: <IpaHighlight>[highlight(id: 'a', start: 0, end: 3)],
        ipaUk: affricate,
        ipaUs: null,
      );

      expect(
        result.hasLosses,
        isFalse,
        reason: '3 grapheme clusters, whatever the code-unit count says',
      );
    });

    test('never clamps a range to make it fit', () {
      final result = revalidateHighlights(
        highlights: <IpaHighlight>[highlight(id: 'a', start: 1, end: 5)],
        ipaUk: 'kɒf',
        ipaUs: null,
      );

      // Silently shrinking it to [1,3) would leave a colour on symbols the
      // user never chose.
      expect(result.kept, isEmpty);
      expect(result.dropped.single.range, GraphemeRange(1, 5));
    });
  });

  group('pruning', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      db = AppDatabase.memory();
      await db.customSelect('SELECT 1').get();
      container = ProviderContainer(
        overrides: <Override>[...repositoryOverrides(db)],
      );
      addTearDown(container.dispose);
    });

    tearDown(() => db.close());

    Future<String> seed() async {
      final now = DateTime(2026, 9, 9);
      final created = await container
          .read(wordRepositoryProvider)
          .createWord(
            word: Word(
              id: 'word-1',
              headword: Headword('cough'),
              createdAt: now,
              updatedAt: now,
              ipaUk: Ipa.fromStorage('kɒf'),
              ipaUs: Ipa.fromStorage('kɔːf'),
            ),
          );
      return created.valueOrNull!.id;
    }

    test('removes the dropped rows and leaves the survivors', () async {
      final id = await seed();
      final repository = container.read(wordRepositoryProvider);

      await repository.replaceHighlights(
        wordId: id,
        target: HighlightTarget.ipaUk,
        highlights: <IpaHighlight>[
          highlight(id: 'fits', start: 0, end: 1),
          highlight(id: 'stale', start: 2, end: 3),
        ],
      );

      final revalidator = container.read(highlightRevalidatorProvider.notifier);
      final checked = await revalidator.check(
        wordId: id,
        ipaUk: 'kɒ',
        ipaUs: 'kɔːf',
      );
      final split = checked.valueOrNull!;
      expect(split.dropped, hasLength(1));

      await revalidator.prune(wordId: id, revalidation: split);

      final stored = (await repository.watchHighlights(id).first).valueOrNull!;
      expect(stored.map((h) => h.id), <String>['fits']);
    });

    test('leaves the untouched transcription completely alone (A7)', () async {
      final id = await seed();
      final repository = container.read(wordRepositoryProvider);

      await repository.replaceHighlights(
        wordId: id,
        target: HighlightTarget.ipaUk,
        highlights: <IpaHighlight>[highlight(id: 'uk-stale', start: 2, end: 3)],
      );
      await repository.replaceHighlights(
        wordId: id,
        target: HighlightTarget.ipaUs,
        highlights: <IpaHighlight>[
          highlight(
            id: 'us-keep',
            start: 0,
            end: 1,
            target: HighlightTarget.ipaUs,
          ),
        ],
      );

      final revalidator = container.read(highlightRevalidatorProvider.notifier);
      final split = (await revalidator.check(
        wordId: id,
        ipaUk: 'kɒ',
        ipaUs: 'kɔːf',
      )).valueOrNull!;
      await revalidator.prune(wordId: id, revalidation: split);

      final stored = (await repository.watchHighlights(id).first).valueOrNull!;
      expect(stored.map((h) => h.id), <String>['us-keep']);
    });

    test('writes nothing at all when nothing was lost', () async {
      final id = await seed();
      final repository = container.read(wordRepositoryProvider);

      await repository.replaceHighlights(
        wordId: id,
        target: HighlightTarget.ipaUk,
        highlights: <IpaHighlight>[highlight(id: 'keep', start: 0, end: 1)],
      );

      final revalidator = container.read(highlightRevalidatorProvider.notifier);
      final split = (await revalidator.check(
        wordId: id,
        ipaUk: 'kɒf',
        ipaUs: 'kɔːf',
      )).valueOrNull!;

      expect(split.hasLosses, isFalse);
      expect(
        (await revalidator.prune(wordId: id, revalidation: split)).isOk,
        isTrue,
      );

      final stored = (await repository.watchHighlights(id).first).valueOrNull!;
      expect(stored.single.id, 'keep');
    });
  });
}
