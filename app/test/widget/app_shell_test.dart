import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/router/routes.dart';

/// Navigation and shell tests for M0.
///
/// The screens are placeholders, but the routes, the tab shell and the settings
/// affordance are real, so they are worth locking down now: M2 onwards replaces
/// screen bodies, not the navigation contract.
void main() {
  late ProviderContainer container;

  /// Pumps the real app against a container the test can also read, so
  /// navigation goes through the same router a tap would use.
  Future<void> pumpApp(
    WidgetTester tester, {
    Brightness platformBrightness = Brightness.light,
  }) async {
    container = ProviderContainer();
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
    await tester.pumpAndSettle();
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
      expect(find.text('Route: ${Routes.practice}'), findsOneWidget);

      await tester.tap(find.text('Words'));
      await tester.pumpAndSettle();
      expect(find.text('My words'), findsOneWidget);
    });

    testWidgets('switches to lists', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Lists'));
      await tester.pumpAndSettle();
      expect(find.text('Route: ${Routes.lists}'), findsOneWidget);
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
