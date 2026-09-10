import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';

import '../unit/data/db_fixtures.dart';

/// The practice hub (`docs/UI-UX.md` §4.6, F-060).
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() {
    // The quick-test sheet has no text field, but the hub is reached through
    // the shell and the words tab does. Cheap insurance either way.
    EditableText.debugDeterministicCursor = true;
  });

  tearDownAll(() {
    EditableText.debugDeterministicCursor = false;
  });

  Future<void> openHub(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
  }

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  group('with no words', () {
    testWidgets('says what to do rather than showing an empty screen', (
      tester,
    ) async {
      await openHub(tester);

      expect(find.text('Nothing to practise yet'), findsOneWidget);
      expect(find.text('Add word'), findsWidgets);
    });
  });

  group('below the minimum', () {
    setUp(() async {
      // The flashcard game needs four.
      for (var i = 0; i < 2; i++) {
        await seedWord(db, id: 'w$i', headword: 'word$i');
      }
    });

    testWidgets('the game still gets a card, saying how many more are needed', (
      tester,
    ) async {
      // F-060: a game the user cannot start yet needs a card saying why.
      // Hiding it would leave the user wondering whether practice exists.
      await openHub(tester);

      expect(find.text('Flashcards'), findsOneWidget);
      expect(find.textContaining('Add 2 more words'), findsOneWidget);
    });

    testWidgets('offers no way to start it', (tester) async {
      await openHub(tester);

      expect(find.text('Quick test'), findsNothing);
    });
  });

  group('with enough words', () {
    setUp(() async {
      for (var i = 0; i < 6; i++) {
        await seedWord(db, id: 'w$i', headword: 'word$i');
      }
    });

    testWidgets('offers the game', (tester) async {
      await openHub(tester);

      expect(find.text('Flashcards'), findsOneWidget);
      expect(find.text('Quick test'), findsOneWidget);
    });

    testWidgets('nothing due reads as an offer, never a scolding', (
      tester,
    ) async {
      // UI-UX §4.6: "encouraging copy, never a warning". The seeded cards are
      // due today, so this test pushes them into the future first.
      await db
          .update(db.studyCards)
          .write(
            StudyCardsCompanion(
              dueAt: Value(DateTime.now().add(const Duration(days: 3))),
            ),
          );
      await openHub(tester);

      expect(find.textContaining('Nothing due right now'), findsOneWidget);
      expect(find.textContaining('behind'), findsNothing);
      expect(find.textContaining('missed'), findsNothing);
    });

    testWidgets('the daily button is disabled when nothing is due', (
      tester,
    ) async {
      await db
          .update(db.studyCards)
          .write(
            StudyCardsCompanion(
              dueAt: Value(DateTime.now().add(const Duration(days: 3))),
            ),
          );
      await openHub(tester);

      final button = tester.widget<FilledButton>(
        find
            .ancestor(
              of: find.textContaining('Daily review'),
              matching: find.byType(FilledButton),
            )
            .first,
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('the daily button counts what is actually due', (tester) async {
      await openHub(tester);
      expect(find.text('Daily review (6 due)'), findsOneWidget);
    });

    testWidgets('the quick-test sheet names the cap out loud', (tester) async {
      // The user picking "All" from a 5000-word library deserves to know they
      // are getting 30, rather than being silently trimmed.
      await openHub(tester);

      await tester.tap(find.text('Quick test'));
      await tester.pumpAndSettle();

      expect(find.text('All (max 30)'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('the sheet offers every source and prompt side', (
      tester,
    ) async {
      await openHub(tester);
      await tester.tap(find.text('Quick test'));
      await tester.pumpAndSettle();

      for (final label in <String>[
        'All',
        'Favourites',
        'The word',
        'The sounds',
        'The meaning',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });
  });
}
