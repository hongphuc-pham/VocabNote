import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';
import 'package:vocabnote/domain/value_objects/headword.dart';
import 'package:vocabnote/domain/value_objects/ipa.dart';
import 'package:vocabnote/presentation/words/word_tile.dart';

/// The word row, as a picture, in both themes (M7 A6).
///
/// The first golden in the project, and deliberately alone: Flutter does not
/// render identically on every host (flutter/flutter#131559), so this one is
/// generated on Windows, committed, and checked against Linux CI before any
/// more are written. What it holds is the row's shape and colours - text is
/// drawn as blocks (`test/flutter_test_config.dart`).
void main() {
  WordListEntry entryFor({
    required String headword,
    String? partOfSpeech,
    String? ipaUk,
    int noteCount = 0,
    bool isFavourite = false,
  }) {
    final now = DateTime.utc(2026, 9, 13);
    return WordListEntry(
      word: Word(
        id: 'w1',
        headword: Headword(headword),
        createdAt: now,
        updatedAt: now,
        partOfSpeech: partOfSpeech,
        ipaUk: ipaUk == null ? null : Ipa.fromStorage(ipaUk),
        isFavourite: isFavourite,
      ),
      noteCount: noteCount,
      highlights: const <IpaHighlight>[],
    );
  }

  /// One scenario, sized: alchemist lays the scenarios out in a table with no
  /// height of its own, and an app that wants to fill the screen has no size
  /// to give it ("given an infinite size during layout").
  Widget tile(ThemeData theme, WordListEntry entry) => SizedBox(
    width: 360,
    // Room for the row plus its padding: the test font is wider and taller
    // than Inter, and at 140 the row overflowed by 22px.
    height: 190,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: WordTile(entry: entry, onTap: () {}),
        ),
      ),
    ),
  );

  // `goldenTest` registers the test and returns its future; nothing in a test
  // file awaits that, as with `testWidgets`.
  unawaited(
    goldenTest(
      'the word row keeps its shape in both themes',
      fileName: 'word_tile',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: <Widget>[
          GoldenTestScenario(
            name: 'light',
            child: tile(
              AppTheme.light(),
              entryFor(
                headword: 'cough',
                partOfSpeech: 'noun',
                ipaUk: 'kɒf',
                noteCount: 2,
                isFavourite: true,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'dark',
            child: tile(
              AppTheme.dark(),
              entryFor(
                headword: 'cough',
                partOfSpeech: 'noun',
                ipaUk: 'kɒf',
                noteCount: 2,
                isFavourite: true,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
