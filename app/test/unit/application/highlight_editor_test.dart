import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncResult;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/application/words/highlight_editor_controller.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

/// The IPA highlight editor's session (F-022, `docs/UI-UX.md` §4.4).
///
/// The selection rules are the whole point of this controller, and they are
/// where ADR-006 is either honoured or quietly broken — so the transcriptions
/// used here are deliberately awkward ones: `ˈtʃɜːtʃ` carries a stress mark, a
/// tie-bar affricate and a length mark, all of which are multi-codepoint or
/// combining and none of which may ever be split.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  const wordId = 'word-1';

  /// `/ˈt͡ʃɜːt͡ʃ/` with real U+0361 combining tie bars and a U+02D0 length
  /// mark — the awkward case ADR-006 exists for. Written with explicit escapes
  /// so an editor cannot silently normalise it away.
  const church = 'ˈt͡ʃɜːt͡ʃ';

  HighlightEditor editorFor(
    String ipa, {
    List<IpaHighlight> initial = const <IpaHighlight>[],
    HighlightTarget target = HighlightTarget.ipaUk,
    String id = wordId,
  }) {
    // Seeding is idempotent, so calling it here keeps each test to one line
    // of set-up.
    return container.read(highlightEditorProvider(id, target, ipa).notifier)
      ..loadFrom(initial);
  }

  HighlightEditorState stateFor(
    String ipa, {
    HighlightTarget target = HighlightTarget.ipaUk,
    String id = wordId,
  }) => container.read(highlightEditorProvider(id, target, ipa));

  IpaHighlight highlight({
    required String id,
    required int start,
    required int end,
    IpaColorToken color = IpaColorToken.amber,
    HighlightTarget target = HighlightTarget.ipaUk,
    String? label,
  }) => IpaHighlight(
    id: id,
    wordId: wordId,
    target: target,
    range: GraphemeRange(start, end),
    color: color,
    createdAt: DateTime(2026, 9, 9),
    label: label,
  );

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    container = ProviderContainer(
      overrides: <Override>[...repositoryOverrides(db)],
    );
    addTearDown(container.dispose);
  });

  tearDown(() => db.close());

  group('chips are grapheme clusters, never code units', () {
    test('a tie bar and its base letter are one chip', () {
      final chips = stateFor(church).chips;

      // Whatever the exact count, no chip may be half a symbol: every one must
      // be a complete cluster, and joining them back must be lossless.
      expect(chips.join(), church);
      expect(chips.every((chip) => chip.isNotEmpty), isTrue);
      expect(
        chips.length,
        lessThan(church.length),
        reason: 'multi-codepoint symbols must collapse into single chips',
      );
    });

    test('selecting one chip never lands mid-symbol', () {
      final editor = editorFor(church)..selectAt(1);
      final state = stateFor(church);

      expect(state.selection, GraphemeRange(1, 2));
      expect(state.selectionSymbols, state.chips[1]);
      expect(editor, isNotNull);
    });
  });

  group('selection', () {
    test('tapping a chip selects exactly that one', () {
      editorFor('kɒf').selectAt(1);

      expect(stateFor('kɒf').selection, GraphemeRange(1, 2));
    });

    test('tapping a second chip extends the run to cover both', () {
      editorFor('kɒf')
        ..selectAt(0)
        ..extendTo(2);

      expect(stateFor('kɒf').selection, GraphemeRange(0, 3));
    });

    test('extending backwards is normalised, not rejected', () {
      editorFor('kɒf')
        ..selectAt(2)
        ..extendTo(0);

      expect(stateFor('kɒf').selection, GraphemeRange(0, 3));
    });

    test('extending with nothing selected simply selects', () {
      editorFor('kɒf').extendTo(1);

      expect(stateFor('kɒf').selection, GraphemeRange(1, 2));
    });

    test('an index off either end is ignored rather than throwing', () {
      final editor = editorFor('kɒf')
        ..selectAt(9)
        ..selectAt(-1);

      expect(stateFor('kɒf').selection, isNull);
      expect(editor, isNotNull);
    });

    test('the selection is announced as spaced symbols', () {
      editorFor('kɒf')
        ..selectAt(0)
        ..extendTo(1);

      // "selected k ɒ" is what a screen reader reads (`UI-UX.md` §4.4).
      expect(stateFor('kɒf').selectionSymbols, 'k ɒ');
    });
  });

  group('colouring', () {
    test('applies a colour to the selected run and clears the selection', () {
      editorFor('kɒf')
        ..selectAt(1)
        ..applyColor(IpaColorToken.amber);

      final state = stateFor('kɒf');
      expect(state.highlights, hasLength(1));
      expect(state.highlights.single.range, GraphemeRange(1, 2));
      expect(state.highlights.single.color, IpaColorToken.amber);
      expect(state.selection, isNull);
    });

    test('does nothing when nothing is selected', () {
      editorFor('kɒf').applyColor(IpaColorToken.amber);

      expect(stateFor('kɒf').highlights, isEmpty);
    });

    test('keeps a label, trimmed', () {
      editorFor('kɒf')
        ..selectAt(2)
        ..applyColor(IpaColorToken.coral, label: '  too soft  ');

      expect(stateFor('kɒf').highlights.single.label, 'too soft');
    });

    test('a blank label is stored as none, not as an empty string', () {
      editorFor('kɒf')
        ..selectAt(2)
        ..applyColor(IpaColorToken.coral, label: '   ');

      expect(stateFor('kɒf').highlights.single.label, isNull);
    });

    test('a label over 40 characters is truncated, not thrown away', () {
      final long = 'x' * 60;
      editorFor('kɒf')
        ..selectAt(0)
        ..applyColor(IpaColorToken.teal, label: long);

      final label = stateFor('kɒf').highlights.single.label!;
      expect(label.length, IpaHighlight.maxLabelLength);
      expect(long, startsWith(label));
    });

    test('overlapping highlights are allowed - both are kept', () {
      editorFor('kɒf')
        ..selectAt(0)
        ..extendTo(1)
        ..applyColor(IpaColorToken.amber)
        ..selectAt(1)
        ..extendTo(2)
        ..applyColor(IpaColorToken.blue);

      final highlights = stateFor('kɒf').highlights;
      expect(highlights, hasLength(2));
      expect(highlights.first.overlaps(highlights.last), isTrue);
    });

    test('recolouring an existing highlight replaces it in place', () {
      final existing = highlight(id: 'h1', start: 0, end: 1);
      final editor = editorFor(
        'kɒf',
        initial: <IpaHighlight>[existing],
      )..applyColor(IpaColorToken.violet, label: 'now violet', replacing: 'h1');

      final highlights = stateFor('kɒf').highlights;
      expect(highlights, hasLength(1), reason: 'replaced, not added');
      expect(highlights.single.id, 'h1');
      expect(highlights.single.color, IpaColorToken.violet);
      expect(highlights.single.label, 'now violet');
      expect(editor, isNotNull);
    });
  });

  group('loading an existing set', () {
    test('keeps only the highlights for this transcription', () {
      editorFor(
        'kɒf',
        initial: <IpaHighlight>[
          highlight(id: 'uk', start: 0, end: 1),
          highlight(id: 'us', start: 0, end: 1, target: HighlightTarget.ipaUs),
        ],
      );

      expect(stateFor('kɒf').highlights.map((h) => h.id), <String>['uk']);
    });

    test('drops a range that no longer fits the transcription (F-023)', () {
      editorFor(
        'kɒf',
        initial: <IpaHighlight>[
          highlight(id: 'fits', start: 0, end: 2),
          highlight(id: 'stale', start: 4, end: 9),
        ],
      );

      expect(stateFor('kɒf').highlights.map((h) => h.id), <String>['fits']);
    });

    test('a second load never clobbers work already in progress', () {
      editorFor('kɒf')
        ..selectAt(0)
        ..applyColor(IpaColorToken.amber)
        // The screen watches a stream that re-emits on every change to the
        // word, so a second seeding is the ordinary case, not a rare one.
        ..loadFrom(<IpaHighlight>[highlight(id: 'stored', start: 2, end: 3)]);

      final highlights = stateFor('kɒf').highlights;
      expect(highlights, hasLength(1));
      expect(
        highlights.single.range,
        GraphemeRange(0, 1),
        reason: 'the colour the user just placed must survive a re-emit',
      );
    });
  });

  group('undo', () {
    test('is unavailable until something changes', () {
      expect(stateFor('kɒf').canUndo, isFalse);
    });

    test('steps back one colour', () {
      editorFor('kɒf')
        ..selectAt(0)
        ..applyColor(IpaColorToken.amber)
        ..undo();

      final state = stateFor('kɒf');
      expect(state.highlights, isEmpty);
      expect(state.canUndo, isFalse);
    });

    test('covers the whole session, not just the last step', () {
      editorFor('kɒf')
        ..selectAt(0)
        ..applyColor(IpaColorToken.amber)
        ..selectAt(1)
        ..applyColor(IpaColorToken.blue)
        ..selectAt(2)
        ..applyColor(IpaColorToken.teal)
        ..undo()
        ..undo()
        ..undo();

      expect(stateFor('kɒf').highlights, isEmpty);
    });

    test('undoes a deletion too', () {
      final existing = highlight(id: 'h1', start: 0, end: 1);
      editorFor('kɒf', initial: <IpaHighlight>[existing])
        ..removeHighlight('h1')
        ..undo();

      expect(stateFor('kɒf').highlights, hasLength(1));
    });

    test('does nothing when there is nothing to undo', () {
      editorFor('kɒf').undo();

      expect(stateFor('kɒf').highlights, isEmpty);
    });
  });

  group('saving', () {
    test('nothing is written until save is called', () async {
      final word = await _seed(container, ipaUk: 'kɒf');

      editorFor('kɒf', id: word)
        ..selectAt(1)
        ..applyColor(IpaColorToken.amber);

      final stored = await container
          .read(wordRepositoryProvider)
          .watchHighlights(word)
          .first;

      expect(
        stored.valueOrNull,
        isEmpty,
        reason: 'UI-UX §4.4: nothing is persisted until Done',
      );
    });

    test('save writes the session and it survives a reload (A7)', () async {
      final word = await _seed(container, ipaUk: 'kɒf');
      final editor = editorFor('kɒf', id: word)
        ..selectAt(1)
        ..applyColor(IpaColorToken.amber, label: 'the vowel');

      final result = await editor.save();
      expect(result.isOk, isTrue);

      final stored =
          (await container
                  .read(wordRepositoryProvider)
                  .watchHighlights(word)
                  .first)
              .valueOrNull!;

      expect(stored, hasLength(1));
      expect(stored.single.range, GraphemeRange(1, 2));
      expect(stored.single.color, IpaColorToken.amber);
      expect(stored.single.label, 'the vowel');
      expect(stored.single.target, HighlightTarget.ipaUk);
    });

    test('saving one transcription leaves the other alone', () async {
      final word = await _seed(container, ipaUk: 'kɒf', ipaUs: 'kɔːf');
      final repository = container.read(wordRepositoryProvider);

      await repository.replaceHighlights(
        wordId: word,
        target: HighlightTarget.ipaUs,
        highlights: <IpaHighlight>[
          IpaHighlight(
            id: 'us-1',
            wordId: word,
            target: HighlightTarget.ipaUs,
            range: GraphemeRange(0, 1),
            color: IpaColorToken.blue,
            createdAt: DateTime(2026, 9, 9),
          ),
        ],
      );

      final editor = editorFor('kɒf', id: word)
        ..selectAt(0)
        ..applyColor(IpaColorToken.amber);
      await editor.save();

      final stored =
          (await repository.watchHighlights(word).first).valueOrNull!;

      expect(stored, hasLength(2));
      expect(
        stored.where((h) => h.target == HighlightTarget.ipaUs).single.id,
        'us-1',
      );
    });
  });
}

/// Seeds a word and returns its id.
Future<String> _seed(
  ProviderContainer container, {
  String? ipaUk,
  String? ipaUs,
}) async {
  final now = DateTime(2026, 9, 9);
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
        ),
      );
  return result.valueOrNull!.id;
}
