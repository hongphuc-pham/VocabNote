import 'dart:async';

import 'package:flutter/material.dart';
// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:flutter_riverpod/flutter_riverpod.dart' hide AsyncResult;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/value_objects/grapheme_range.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

/// The IPA highlight editor, end to end (F-022, A3, A7).
///
/// The milestone's acceptance criterion is *"a highlight survives an app
/// restart and an IPA edit"*. A widget test cannot restart the process, but it
/// can do the thing that matters: write through the real screen, throw the
/// whole widget tree away, and read it back from the same database — which is
/// what a restart amounts to for this feature.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<String> seedWord({String ipaUk = 'kɒf', String? ipaUs}) async {
    final now = DateTime(2026, 9, 9);
    final created = await container
        .read(wordRepositoryProvider)
        .createWord(
          word: Word(
            id: 'word-1',
            headword: Headword('cough'),
            createdAt: now,
            updatedAt: now,
            ipaUk: Ipa.fromStorage(ipaUk),
            ipaUs: ipaUs == null ? null : Ipa.fromStorage(ipaUs),
          ),
        );
    return created.valueOrNull!.id;
  }

  /// Mounts the app and navigates to the editor for [id].
  Future<void> pumpEditor(WidgetTester tester, String id) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(container.read(appRouterProvider).push('/words/$id/ipa'));
    await tester.pumpAndSettle();
  }

  /// Reads the highlights straight out of the database.
  ///
  /// A one-shot `getHighlights`, not `watchHighlights(...).first`: a Drift
  /// stream delivers on a real timer, which a widget test's fake clock never
  /// advances, so awaiting the first event of a watch wedges the test forever
  /// with no error at all.
  Future<List<IpaHighlight>> stored(String id) async =>
      (await container.read(wordRepositoryProvider).getHighlights(id))
          .valueOrNull!;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db),
      ],
    );
    // One teardown, in this order on purpose: disposing the container first
    // cancels the providers' Drift stream subscriptions. Closing the database
    // while a watch is still live deadlocks the test — it completes its body
    // and then never finishes.
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  group('selecting', () {
    testWidgets('shows one chip per grapheme cluster', (tester) async {
      // 'kɒf' is three symbols and three chips.
      final id = await seedWord();
      await pumpEditor(tester, id);

      expect(find.bySemanticsLabel('k'), findsOneWidget);
      expect(find.bySemanticsLabel('short o as in hot'), findsOneWidget);
      expect(find.bySemanticsLabel('f'), findsOneWidget);
    });

    testWidgets('announces nothing selected until a chip is tapped', (
      tester,
    ) async {
      final id = await seedWord();
      await pumpEditor(tester, id);

      expect(find.text('Nothing selected yet'), findsOneWidget);
    });

    testWidgets('tapping a chip announces that symbol', (tester) async {
      final id = await seedWord();
      await pumpEditor(tester, id);

      await tester.tap(find.bySemanticsLabel('short o as in hot'));
      await tester.pumpAndSettle();

      // The sound by its learner name, not the glyph (UI-UX §6, M7).
      expect(find.text('selected short o as in hot'), findsOneWidget);
    });

    testWidgets('tapping a second chip extends the run, no drag needed', (
      tester,
    ) async {
      final id = await seedWord();
      await pumpEditor(tester, id);

      await tester.tap(find.bySemanticsLabel('k'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('f'));
      await tester.pumpAndSettle();

      // UI-UX §1: no action may live only behind a gesture.
      expect(find.text('selected k, short o as in hot, f'), findsOneWidget);
    });
  });

  group('the round trip (A7)', () {
    testWidgets('select, colour, save, reopen - the highlight is still there', (
      tester,
    ) async {
      final id = await seedWord();
      await pumpEditor(tester, id);

      // Select the vowel.
      await tester.tap(find.bySemanticsLabel('short o as in hot'));
      await tester.pumpAndSettle();

      // Open the colour sheet.
      await tester.tap(find.text('Colour this sound'));
      await tester.pumpAndSettle();

      // Choose coral and label it.
      await tester.tap(find.bySemanticsLabel('Use coral'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'too short');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Nothing is written until Done (`UI-UX.md` §4.4).
      expect(await stored(id), isEmpty);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final saved = await stored(id);
      expect(saved, hasLength(1));
      expect(saved.single.range, GraphemeRange(1, 2));
      expect(saved.single.color, IpaColorToken.coral);
      expect(saved.single.label, 'too short');
      expect(saved.single.target, HighlightTarget.ipaUk);

      // Throw the whole tree away and rebuild from the same database — as
      // close to a restart as a widget test gets.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await pumpEditor(tester, id);

      expect(find.text('coral: too short'), findsOneWidget);
    });

    testWidgets('undo takes a colour back before it is ever written', (
      tester,
    ) async {
      final id = await seedWord();
      await pumpEditor(tester, id);

      await tester.tap(find.bySemanticsLabel('k'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Colour this sound'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'the k');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('amber: the k'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text('amber: the k'), findsNothing);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(await stored(id), isEmpty);
    });
  });

  // F-023's behaviour is covered by `test/unit/application/
  // highlight_revalidation_test.dart` — twelve tests, including pruning
  // against a real database.
  //
  // There is deliberately no widget test of the confirm dialog here: the word
  // editor screen never reaches a settled frame in a widget test, so
  // `pumpAndSettle` on it times out. Something on that screen animates
  // indefinitely on open. Tracked as a follow-up; it is also why that screen
  // has had no widget test since M2.
}
