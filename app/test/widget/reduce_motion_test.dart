import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/theme/app_theme.dart';

/// "All animation is skipped when `MediaQuery.disableAnimations` is true"
/// (`docs/UI-UX.md` §2, §6, F-093), for the transitions the app does not write
/// itself: opening a screen, and opening a sheet.
///
/// Flutter runs a normal `AnimationController` at 5% of its duration when the
/// device asks for less motion (`animation_controller.dart:651`), and route
/// and sheet transitions are such controllers - so a transition that takes
/// most of half a second lands inside a frame or two. This test holds that:
/// the app takes the stock
/// transitions, and `no_unmanaged_motion_test.dart` forbids a screen from
/// opting out of them. The app's own durations go to zero through
/// `AppMotion.durationFor`, which the flip (`flashcard_game_test.dart`) and
/// onboarding (`onboarding_test.dart`) cover.
///
/// A bare app on purpose: no database, no providers. What is being measured is
/// the framework's transition, and driving the real app here only adds streams
/// that keep a widget test awake.
///
/// Each case is measured twice, on and off. Off, the same short wait must
/// leave the transition unfinished - otherwise the test would pass on a screen
/// that never animated at all.
void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    required bool reduceMotion,
  }) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: reduceMotion);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: Center(child: Text('home'))),
      ),
    );
  }

  /// How far the transition of the route showing [target] has got, 0 to 1.
  double progress(WidgetTester tester, Finder target) =>
      ModalRoute.of(tester.element(target))!.animation!.value;

  /// Three frames - 50ms - which a transition cut to 5% is well inside, and a
  /// full one is nowhere near.
  ///
  /// Measured: a pushed screen takes ~22ms with motion reduced (5% of the
  /// ~450ms transition), a sheet less. A single 16ms frame catches the sheet
  /// but lands mid-way through the screen, at 0.71.
  Future<void> aMoment(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> pushScreen(WidgetTester tester) async {
    Navigator.of(tester.element(find.text('home'))).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            const Scaffold(body: Center(child: Text('pushed'))),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    unawaited(
      showModalBottomSheet<void>(
        context: tester.element(find.text('home')),
        builder: (context) =>
            const SizedBox(height: 200, child: Center(child: Text('sheet'))),
      ),
    );
  }

  group('opening a screen', () {
    testWidgets('is over in a moment when motion is reduced', (tester) async {
      await pumpApp(tester, reduceMotion: true);
      await pushScreen(tester);

      await aMoment(tester);

      expect(progress(tester, find.text('pushed')), 1.0);
    });

    testWidgets('still animates when it is not', (tester) async {
      await pumpApp(tester, reduceMotion: false);
      await pushScreen(tester);

      await aMoment(tester);

      expect(progress(tester, find.text('pushed')), lessThan(1.0));
      await tester.pumpAndSettle();
    });
  });

  group('opening a sheet', () {
    testWidgets('is over in a moment when motion is reduced', (tester) async {
      await pumpApp(tester, reduceMotion: true);
      await openSheet(tester);

      await aMoment(tester);

      expect(progress(tester, find.text('sheet')), 1.0);
    });

    testWidgets('still animates when it is not', (tester) async {
      await pumpApp(tester, reduceMotion: false);
      await openSheet(tester);

      await aMoment(tester);

      expect(progress(tester, find.text('sheet')), lessThan(1.0));
      await tester.pumpAndSettle();
    });
  });
}
