import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/database_provider.dart';

/// Navigation and shell tests for M0.
///
/// The screens are placeholders, but the routes, the tab shell and the settings
/// affordance are real, so they are worth locking down now: M2 onwards replaces
/// screen bodies, not the navigation contract.
void main() {
  late ProviderContainer container;
  late AppDatabase db;

  setUp(() async {
    // The shell used to need no database, because every screen behind it was a
    // placeholder. From M4 the tabs are real screens that read real
    // repositories, so the routing test needs one too.
    db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  /// Pumps the real app against a container the test can also read, so
  /// navigation goes through the same router a tap would use.
  Future<void> pumpApp(
    WidgetTester tester, {
    Brightness platformBrightness = Brightness.light,
  }) async {
    container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(db),
        ...repositoryOverrides(db),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(platformBrightness: platformBrightness),
        child: UncontrolledProviderScope(
          container: container,
          child: const VocabNoteApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> go(WidgetTester tester, String location) async {
    container.read(appRouterProvider).go(location);
    // Deliberately not `pumpAndSettle`. The practice run screen shows an
    // indeterminate CircularProgressIndicator while it loads a pool, and an
    // indeterminate spinner is an animation that never ends - `pumpAndSettle`
    // waits for it until it times out, and the failure is a hang with no
    // message. (PROGRESS §6 guessed at exactly this for the word editor
    // screen; there the culprit turned out to be the blinking caret, but the
    // guess was a good one - both are endless animations.)
    //
    // This test only asks whether a route resolves, so a handful of frames is
    // all it needs.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('bottom navigation', () {
    testWidgets('shows the three tabs from UI-UX section 3', (tester) async {
      await pumpApp(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Words'), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('Lists'), findsOneWidget);
    });

    testWidgets('opens on the words tab', (tester) async {
      await pumpApp(tester);
      expect(find.text('My words'), findsOneWidget);
    });

    testWidgets('switches to practice and back', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Practice'));
      await tester.pumpAndSettle();
      // Asserted the placeholder's "Route: /practice" until M5 built the hub.
      expect(find.widgetWithText(AppBar, 'Practice'), findsOneWidget);

      await tester.tap(find.text('Words'));
      await tester.pumpAndSettle();
      expect(find.text('My words'), findsOneWidget);
    });

    testWidgets('switches to lists', (tester) async {
      // Asserted the placeholder's "Route: /lists" until M4 built the real
      // screen. The lists grid's own title is the durable assertion.
      await pumpApp(tester);

      await tester.tap(find.text('Lists'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Lists'), findsOneWidget);
    });

    testWidgets('each branch FAB has its own hero tag', (tester) async {
      // The shell is a StatefulShellRoute.indexedStack, so every branch stays
      // in the tree. Two FABs with the default tag is a "multiple heroes share
      // the same tag" crash the moment a second branch grows one - which is
      // exactly what happened when the lists grid replaced the placeholder.
      await pumpApp(tester);

      final tags = tester
          .widgetList<FloatingActionButton>(find.byType(FloatingActionButton))
          .map((fab) => fab.heroTag)
          .toList();
      expect(tags, isNotEmpty);
      expect(tags.whereType<Object>().toSet(), hasLength(tags.length));
      expect(tags.contains(null), isFalse, reason: 'null is the default tag');
    });

    testWidgets('there is no fourth destination for settings', (tester) async {
      // Settings is a detour, not a place the user works, so it lives in the
      // app bar (UI-UX.md section 3).
      await pumpApp(tester);
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.destinations, hasLength(3));
    });
  });

  group('settings affordance', () {
    testWidgets('every tab offers a settings button', (tester) async {
      await pumpApp(tester);

      for (final tab in <String>['Words', 'Practice', 'Lists']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(
          find.byIcon(Icons.settings_outlined),
          findsOneWidget,
          reason: 'no settings button on the $tab tab',
        );
      }
    });

    testWidgets('the icon-only button carries a semantic label', (
      tester,
    ) async {
      // UI-UX.md section 6 makes this blocking, not optional.
      await pumpApp(tester);

      final button = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.settings_outlined),
          matching: find.byType(IconButton),
        ),
      );
      expect(button.tooltip, 'Open settings');
    });

    testWidgets('tapping it opens settings over the shell', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      // Pushed onto the root navigator, so the tab bar is gone and there is a
      // way back.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BackButton), findsOneWidget);
    });
  });

  group('routing', () {
    testWidgets('resolves every route in UI-UX section 3', (tester) async {
      await pumpApp(tester);

      const locations = <String>[
        Routes.words,
        '/words/abc',
        '/words/abc/edit',
        '/words/abc/ipa',
        Routes.lists,
        '/lists/xyz',
        Routes.practice,
        '/practice/flashcard/run',
        '/practice/summary/s1',
        Routes.settings,
        Routes.guide,
        Routes.help,
        Routes.backup,
        Routes.licences,
        Routes.onboarding,
      ];

      for (final location in locations) {
        await go(tester, location);
        expect(
          find.text('Page not found'),
          findsNothing,
          reason: '$location did not resolve',
        );
        expect(tester.takeException(), isNull, reason: location);
      }
    });

    testWidgets('an unknown route shows the friendly not-found screen', (
      tester,
    ) async {
      await pumpApp(tester);
      await go(tester, '/nope/nowhere');

      expect(find.text('Page not found'), findsOneWidget);
      expect(find.text('Go to my words'), findsOneWidget);
    });

    testWidgets('the not-found screen leads back to the words list', (
      tester,
    ) async {
      await pumpApp(tester);
      await go(tester, '/nope');

      await tester.tap(find.text('Go to my words'));
      await tester.pumpAndSettle();

      expect(find.text('My words'), findsOneWidget);
    });
  });

  group('theming', () {
    testWidgets('follows the platform into dark mode', (tester) async {
      await pumpApp(tester, platformBrightness: Brightness.dark);

      final context = tester.element(find.text('My words'));
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('renders in light mode by default', (tester) async {
      await pumpApp(tester);

      final context = tester.element(find.text('My words'));
      expect(Theme.of(context).brightness, Brightness.light);
    });
  });
}
