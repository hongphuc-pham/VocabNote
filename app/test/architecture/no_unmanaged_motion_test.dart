import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Motion and timing stay where the design system can see them
/// (`docs/UI-UX.md` §2, §6, `docs/RULES.md` §22).
///
/// Two things a screen must not do:
///
/// * **Opt out of reduce-motion.** A plain `AnimationController` shortens
///   itself when the device asks for less motion; `AnimationBehavior.preserve`,
///   `AnimationController.unbounded` (which defaults to `preserve`) and
///   `repeat()` do not. Flutter uses them deliberately for scroll physics and
///   for spinners; a screen of ours has no such reason.
/// * **Name a duration.** Durations are design values: `AppMotion` for motion,
///   `AppTiming` for waits where nothing moves.
///
/// A test rather than a lint for the same reason as `layer_boundaries_test`:
/// `custom_lint` cannot be installed beside `drift_dev`.
void main() {
  final offences = <String, RegExp>{
    'opts out of reduce-motion': RegExp(
      r'AnimationBehavior\.preserve|AnimationController\.unbounded|\.repeat\(',
    ),
    'names a duration of its own': RegExp(r'\bDuration\('),
  };

  late List<File> screens;

  setUpAll(() {
    screens = Directory('lib/presentation')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .toList();
  });

  test('there is something to check', () {
    expect(screens.length, greaterThan(30));
  });

  for (final MapEntry(key: what, value: pattern) in offences.entries) {
    test('no screen $what', () {
      final violations = <String>[
        for (final file in screens)
          for (final (index, line) in file.readAsLinesSync().indexed)
            // Comments may name either; only code is held to it.
            if (!line.trimLeft().startsWith('//') && pattern.hasMatch(line))
              '${file.path.replaceAll(r'\', '/')}:${index + 1}: ${line.trim()}',
      ];

      expect(
        violations,
        isEmpty,
        reason:
            'take the value from core/theme/tokens.dart (AppMotion, AppTiming) '
            'and let a plain AnimationController honour reduce-motion',
      );
    });
  }
}
