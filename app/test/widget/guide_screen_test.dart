import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/presentation/common/ipa_text.dart';
import 'package:vocabnote/presentation/practice/practice_hub_screen.dart';
import 'package:vocabnote/presentation/words/ipa_editor_screen.dart';
import 'package:vocabnote/presentation/words/word_detail_screen.dart';

import '../unit/application/fake_reminder_service.dart';
import '../unit/application/fake_speech_service.dart';
import '../unit/data/db_fixtures.dart';

/// *How to use* (F-071, `docs/UI-UX.md` §4.10).
///
/// Six cards, each one illustration, one sentence and a *Try it* that lands
/// on the real screen - the part that actually teaches (NN/g: help in
/// context is remembered, a deck of cards read up front is not).
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  const titles = <String>[
    'Add a word',
    'Fill it from the dictionary',
    'Write the IPA yourself',
    'Highlight the sound you struggle with',
    'Leave a note for yourself',
    'Practise a little every day',
  ];

  Future<void> launch(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(
          db,
          speechService: FakeSpeechService(),
          reminderService: FakeReminderService(),
        ),
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
  }

  /// Scrolls the frontmost list down until [finder] is on screen.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .last,
    );
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openGuide(WidgetTester tester) async {
    await launch(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('How to use'));
    await tester.tap(find.text('How to use'));
    await tester.pumpAndSettle();
  }

  /// The *Try it* on the card titled [title].
  Finder tryItOn(String title) => find.descendant(
    of: find.ancestor(of: find.text(title), matching: find.byType(Card)),
    matching: find.text('Try it'),
  );

  /// Taps the *Try it* on [title]'s card and pumps until [lands] shows.
  ///
  /// Not `pumpAndSettle`: a screen that loads a word shows a spinner until
  /// the load comes back, and a spinner never settles. Real time is let
  /// through between frames so the load can finish; capped, so a card that
  /// goes nowhere fails rather than hangs.
  Future<void> tryIt(WidgetTester tester, String title, Finder lands) async {
    await scrollTo(tester, tryItOn(title));
    await tester.tap(tryItOn(title));
    for (var i = 0; i < 50 && lands.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    // Let the page transition finish, so what was left behind is gone.
    await tester.pump(const Duration(seconds: 1));
  }

  Finder appBarTitled(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  testWidgets('holds six cards, in the order UI-UX 4.10 lists them', (
    tester,
  ) async {
    await openGuide(tester);

    expect(appBarTitled('How to use'), findsOneWidget);
    for (final title in titles) {
      // Downwards only, so finding them in turn also proves the order.
      await scrollTo(tester, find.text(title));
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('card 3 says plainly that the voice is synthesised', (
    tester,
  ) async {
    await openGuide(tester);

    final honest = find.textContaining('not a native speaker');
    await scrollTo(tester, honest);

    expect(
      find.descendant(
        of: find.ancestor(of: honest, matching: find.byType(Card)),
        matching: find.text('Write the IPA yourself'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the empty words list opens it too', (tester) async {
    await launch(tester);

    await tester.tap(find.text('See how it works'));
    await tester.pumpAndSettle();

    expect(appBarTitled('How to use'), findsOneWidget);
  });

  testWidgets('the illustrations are hidden from screen readers', (
    tester,
  ) async {
    // They are small mock-ups of real controls; read out, they would sound
    // like buttons that are not there. The card's sentence is what is read.
    await openGuide(tester);
    await scrollTo(tester, find.byType(IpaText));

    expect(
      find.ancestor(
        of: find.byType(IpaText),
        matching: find.byType(ExcludeSemantics),
      ),
      findsWidgets,
    );
  });

  group('Try it lands on the real screen', () {
    testWidgets('adding a word opens the add form', (tester) async {
      await openGuide(tester);

      await tryIt(tester, titles[0], appBarTitled('Add word'));

      expect(appBarTitled('Add word'), findsOneWidget);
    });

    testWidgets('practising opens the practice tab', (tester) async {
      await openGuide(tester);

      await tryIt(tester, titles[5], find.byType(PracticeHubScreen));

      expect(find.byType(PracticeHubScreen), findsOneWidget);
      expect(appBarTitled('How to use'), findsNothing);
    });

    testWidgets('with no words yet, highlighting starts by adding one', (
      tester,
    ) async {
      await openGuide(tester);

      await tryIt(tester, titles[3], appBarTitled('Add word'));

      expect(appBarTitled('Add word'), findsOneWidget);
    });

    testWidgets('with a word that has no IPA, highlighting opens its editor '
        'to add some', (tester) async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await openGuide(tester);

      await tryIt(tester, titles[3], appBarTitled('Edit word'));

      expect(appBarTitled('Edit word'), findsOneWidget);
    });

    testWidgets('with a transcribed word, highlighting opens its IPA', (
      tester,
    ) async {
      await seedWord(db, id: 'w1', headword: 'cough', ipaUk: 'kɒf');
      await openGuide(tester);

      await tryIt(tester, titles[3], find.byType(IpaEditorScreen));

      expect(find.byType(IpaEditorScreen), findsOneWidget);
    });

    testWidgets('with a word, the note card opens that word', (tester) async {
      await seedWord(db, id: 'w1', headword: 'cough');
      await openGuide(tester);

      await tryIt(tester, titles[4], find.byType(WordDetailScreen));

      expect(find.byType(WordDetailScreen), findsOneWidget);
    });
  });
}
