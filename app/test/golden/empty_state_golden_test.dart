import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';

/// The shared empty state, as a picture, in both themes (M7 A6, F-078).
///
/// Every list in the app falls back to this widget, so its shape is worth
/// pinning: an icon, a title, a body, and up to two actions. What the golden
/// holds is layout and colour - the text is drawn as blocks
/// (`test/flutter_test_config.dart`).
void main() {
  Widget framed(ThemeData theme, Widget child) => SizedBox(
    width: 360,
    // Generous: the test font is taller than Inter, and the trial golden
    // overflowed by 22px at a height that looked ample.
    height: 460,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(body: child),
    ),
  );

  const state = EmptyState(
    icon: Icons.menu_book_outlined,
    title: 'Your first word goes here',
    body:
        'Save a word, write how it sounds, and mark the part you keep '
        'getting wrong.',
    actionLabel: 'Add a word',
    secondaryLabel: 'See how it works',
  );

  unawaited(
    goldenTest(
      'the empty state keeps its shape in both themes',
      fileName: 'empty_state',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: <Widget>[
          GoldenTestScenario(
            name: 'light',
            child: framed(AppTheme.light(), state),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: framed(AppTheme.dark(), state),
          ),
        ],
      ),
    ),
  );
}
