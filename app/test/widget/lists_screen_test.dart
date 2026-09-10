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

/// The lists grid against a real (in-memory) database (F-042, UI-UX §4.5).
///
/// Drives the real app through the real router, so what is asserted here is
/// what a user would see.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> pumpLists(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db),
      ],
    );
    // Container before database, or teardown deadlocks.
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VocabNoteApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lists'));
    await tester.pumpAndSettle();
  }

  setUpAll(() {
    // The name field autofocuses, and a blinking text cursor is an animation
    // that never ends - so `pumpAndSettle` waits for it until it times out,
    // and the failure is a hang with no message. This freezes the cursor.
    //
    // Strongly suspected to be the same thing that has made the word editor
    // screen untestable since M2 (PROGRESS §6): it autofocuses too.
    EditableText.debugDeterministicCursor = true;
  });

  tearDownAll(() {
    EditableText.debugDeterministicCursor = false;
  });

  /// Lets real async work finish, then rebuilds.
  ///
  /// The screen fires its writes and does not await them, so `pumpAndSettle`
  /// alone returns before the database has been touched - it drives frames,
  /// and nothing has scheduled a frame to wait for. `runAsync` steps outside
  /// the fake clock so the write can actually complete.
  Future<void> settleAsync(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  group('empty state', () {
    testWidgets('says what a list is for, not just that there are none', (
      tester,
    ) async {
      await pumpLists(tester);

      expect(find.text('No lists yet'), findsOneWidget);
      expect(find.text('New list'), findsWidgets);
    });
  });

  group('creating', () {
    testWidgets('a new list appears in the grid', (tester) async {
      await pumpLists(tester);

      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget, reason: 'sheet opened');
      await tester.enterText(find.byType(TextField), 'IELTS speaking');
      await tester.pumpAndSettle();
      expect(find.text('IELTS speaking'), findsWidgets, reason: 'text typed');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);
      expect(find.byType(TextField), findsNothing, reason: 'sheet closed');

      // Split deliberately: if the row exists but the card does not, the bug
      // is in the grid, not in the write.
      final rows = await db.select(db.wordLists).get();
      expect(rows.map((r) => r.name), <String>['IELTS speaking']);
      expect(find.text('IELTS speaking'), findsOneWidget);
      expect(find.text('No words'), findsOneWidget);
    });

    testWidgets('a blank name is refused rather than saved', (tester) async {
      // "" is a plausible thing to submit by accident, and a nameless card is
      // unusable once it is in the grid.
      await pumpLists(tester);

      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);

      expect(find.text('Give the list a name.'), findsOneWidget);
      expect(
        find.byType(TextField),
        findsOneWidget,
        reason: 'sheet stays open',
      );
    });
  });

  group('a populated grid', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await seedWord(db, id: 'w2', headword: 'through');
    });

    testWidgets('a card counts the words in its list', (tester) async {
      await pumpLists(tester);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Vowels');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);

      // A one-shot select, never `watchLists().first`: awaiting a Drift
      // *watch* stream inside testWidgets wedges forever, because it
      // delivers on a real timer that the fake clock never advances. The
      // failure is a hang with no error message.
      final list = (await db.select(db.wordLists).get()).single;
      await db.listsDao.addWord(
        listId: list.id,
        wordId: 'w1',
        addedAt: DateTime.utc(2026, 9, 10),
      );
      await settleAsync(tester);

      expect(find.text('1 word'), findsOneWidget);
    });

    testWidgets('deleting says plainly that the words survive', (tester) async {
      // F-042's hard rule is that deleting a list keeps the words. The user
      // cannot tell that from the outside, so the dialog has to say it.
      await pumpLists(tester);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Doomed');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);

      await tester.longPress(find.text('Doomed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete list'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('every word in it stays'),
        findsOneWidget,
        reason: 'the dialog must promise the words are safe',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Delete list'));
      await settleAsync(tester);

      expect(find.text('Doomed'), findsNothing);
      expect(await db.wordsDao.getById('w1'), isNotNull);
      expect(await db.wordsDao.getById('w2'), isNotNull);
    });

    testWidgets('the actions button is reachable without a long-press', (
      tester,
    ) async {
      // UI-UX §1: no action may live only behind a gesture.
      await pumpLists(tester);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'New list'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Reachable');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settleAsync(tester);

      await tester.tap(find.byTooltip('Actions for Reachable'));
      await tester.pumpAndSettle();

      expect(find.text('Rename or recolour'), findsOneWidget);
      expect(find.text('Delete list'), findsOneWidget);
    });
  });

  group('list detail (A5)', () {
    setUp(() async {
      await seedWord(db, id: 'w1', headword: 'cough', ipaUk: 'kɒf');
      await seedWord(db, id: 'w2', headword: 'through');
      await seedList(db, id: 'l1', name: 'IELTS');
      await seedMembership(db, listId: 'l1', wordId: 'w1');
    });

    testWidgets('shows only the words in that list', (tester) async {
      await pumpLists(tester);

      await tester.tap(find.text('IELTS'));
      await settleAsync(tester);

      expect(find.text('cough'), findsOneWidget);
      expect(find.text('through'), findsNothing, reason: 'not in this list');
    });

    testWidgets('offers Practise this list', (tester) async {
      await pumpLists(tester);

      await tester.tap(find.text('IELTS'));
      await settleAsync(tester);

      expect(find.text('Practise this list'), findsOneWidget);
    });

    testWidgets('an empty list says so rather than looking broken', (
      tester,
    ) async {
      await seedList(db, id: 'l2', name: 'Empty', sortOrder: 1);
      await pumpLists(tester);

      await tester.tap(find.text('Empty'));
      await settleAsync(tester);

      expect(find.text('Nothing in this list yet'), findsOneWidget);
    });

    testWidgets('opening a list leaves the words tab filter alone', (
      tester,
    ) async {
      // The detail screen reads a family provider, not the words tab's global
      // query. If it shared that query, coming back would find the tab
      // silently filtered to one list.
      await pumpLists(tester);
      await tester.tap(find.text('IELTS'));
      await settleAsync(tester);
      await tester.pageBack();
      await settleAsync(tester);

      await tester.tap(find.text('Words'));
      await settleAsync(tester);

      expect(find.text('cough'), findsOneWidget);
      expect(find.text('through'), findsOneWidget, reason: 'still unfiltered');
    });
  });

  group('reorder (A3)', () {
    setUp(() async {
      await seedList(db, id: 'l1', name: 'First');
      await seedList(db, id: 'l2', name: 'Second', sortOrder: 1);
      await seedList(db, id: 'l3', name: 'Third', sortOrder: 2);
    });

    Future<void> openActions(WidgetTester tester, String name) async {
      await tester.tap(find.byTooltip('Actions for $name'));
      await tester.pumpAndSettle();
    }

    testWidgets('moving a list down changes the stored order', (tester) async {
      await pumpLists(tester);
      await openActions(tester, 'First');
      await tester.tap(find.text('Move down'));
      await settleAsync(tester);

      final rows = await db.select(db.wordLists).get()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      expect(rows.map((r) => r.name), <String>['Second', 'First', 'Third']);
    });

    testWidgets('moving up is the inverse of moving down', (tester) async {
      await pumpLists(tester);
      await openActions(tester, 'Third');
      await tester.tap(find.text('Move up'));
      await settleAsync(tester);
      await openActions(tester, 'Third');
      await tester.tap(find.text('Move down'));
      await settleAsync(tester);

      final rows = await db.select(db.wordLists).get()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      expect(rows.map((r) => r.name), <String>['First', 'Second', 'Third']);
    });

    testWidgets('the first list is not offered Move up', (tester) async {
      // Offering a move that cannot happen is worse than not offering it: the
      // user taps, nothing changes, and they cannot tell whether it failed.
      await pumpLists(tester);
      await openActions(tester, 'First');

      expect(find.text('Move up'), findsNothing);
      expect(find.text('Move down'), findsOneWidget);
    });

    testWidgets('the last list is not offered Move down', (tester) async {
      await pumpLists(tester);
      await openActions(tester, 'Third');

      expect(find.text('Move down'), findsNothing);
      expect(find.text('Move up'), findsOneWidget);
    });

    testWidgets('the grid renders in the stored order, not insertion order', (
      tester,
    ) async {
      // Persistence itself is asserted above, by reading sort_order back out
      // of the database. What this adds is that the grid *reads* that order -
      // a stored order the UI ignores would look identical to no reorder at
      // all.
      //
      // Deliberately not a second `pumpLists`: rebuilding the app in one test
      // leaves the first container's Drift stream timers pending, and the test
      // fails on "a Timer is still pending" rather than on anything real.
      await pumpLists(tester);
      await openActions(tester, 'First');
      await tester.tap(find.text('Move down'));
      await settleAsync(tester);

      final names = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(GridView),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .where((d) => d == 'First' || d == 'Second' || d == 'Third')
          .toList();
      expect(names, <String>['Second', 'First', 'Third']);
    });
  });
}
