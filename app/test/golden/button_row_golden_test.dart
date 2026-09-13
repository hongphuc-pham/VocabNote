import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/presentation/design/button_row.dart';

/// The shared button row, as a picture (M7 A6, F-093).
///
/// `VnButtonRow` measures its labels and drops to a column when they will not
/// fit side by side. That decision is the whole point of the widget, and it is
/// invisible in a widget test that only asks whether both buttons exist - so
/// the 200% scenario here is the one that earns its keep: it is the case the
/// row is built to survive, at the stress size `docs/RULES.md` names (200%
/// text on a 320dp screen).
void main() {
  Widget row() => VnButtonRow(
    labels: const <String>['Save changes', 'Discard'],
    children: <Widget>[
      FilledButton(onPressed: () {}, child: const Text('Save changes')),
      OutlinedButton(onPressed: () {}, child: const Text('Discard')),
    ],
  );

  Widget framed(
    ThemeData theme, {
    double width = 360,
    double height = 200,
    double textScale = 1,
  }) => SizedBox(
    width: width,
    height: height,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(alignment: Alignment.topCenter, child: row()),
            ),
          ),
        ),
      ),
    ),
  );

  unawaited(
    goldenTest(
      'the button row keeps its shape, and folds at 200%',
      fileName: 'button_row',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: <Widget>[
          GoldenTestScenario(name: 'light', child: framed(AppTheme.light())),
          GoldenTestScenario(name: 'dark', child: framed(AppTheme.dark())),
          // 320dp and 200% text: the stress size from RULES, and the case
          // that makes the row fold into a column.
          GoldenTestScenario(
            name: 'light, 320dp at 200%',
            child: framed(
              AppTheme.light(),
              width: 320,
              height: 320,
              textScale: 2,
            ),
          ),
          GoldenTestScenario(
            name: 'dark, 320dp at 200%',
            child: framed(
              AppTheme.dark(),
              width: 320,
              height: 320,
              textScale: 2,
            ),
          ),
        ],
      ),
    ),
  );
}
