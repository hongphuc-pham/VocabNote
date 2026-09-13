import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/words/word_list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';
import 'package:vocabnote/presentation/words/word_filter_bar.dart';

/// The filter chips, as a picture, in both themes (M7 A6, F-043).
///
/// The chips carry counts, and a selected chip differs from an unselected one
/// only by colour and weight - exactly the kind of difference a widget test
/// asserting `findsOneWidget` cannot see. The first chip ("All") is selected
/// by default, so the picture shows both states side by side.
void main() {
  final now = DateTime.utc(2026, 9, 13);

  final lists = <WordListSummary>[
    WordListSummary(
      list: WordList(
        id: 'l1',
        name: 'IELTS',
        color: IpaColorToken.teal,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
      wordCount: 24,
      dueCount: 3,
    ),
    WordListSummary(
      list: WordList(
        id: 'l2',
        name: 'Phrasal verbs',
        color: IpaColorToken.violet,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      wordCount: 8,
      dueCount: 0,
    ),
  ];

  Widget framed(ThemeData theme) => SizedBox(
    width: 360,
    height: 140,
    child: ProviderScope(
      overrides: <Override>[
        totalWordCountProvider.overrideWith((ref) => Stream.value(42)),
        listSummariesProvider.overrideWith((ref) => Stream.value(lists)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: const Scaffold(
          body: Align(alignment: Alignment.topCenter, child: WordFilterBar()),
        ),
      ),
    ),
  );

  unawaited(
    goldenTest(
      'the filter chips keep their shape in both themes',
      fileName: 'word_filter_bar',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: <Widget>[
          GoldenTestScenario(name: 'light', child: framed(AppTheme.light())),
          GoldenTestScenario(name: 'dark', child: framed(AppTheme.dark())),
        ],
      ),
    ),
  );
}
