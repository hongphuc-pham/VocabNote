import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:vocabnote/application/practice/practice_hub_controller.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/application/words/word_list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/domain/entities/practice_progress.dart';
import 'package:vocabnote/presentation/practice/practice_hub_screen.dart';

/// The practice hub, including the daily-goal ring (M7 A6, F-065).
///
/// The ring is a private widget inside `practice_hub_screen.dart`, so the
/// whole screen is the unit - which is no loss: the ring's job is to sit in
/// this screen without shouting, and a picture of it alone could not show
/// that. The progress is fixed at 12 of 20 with a four-day streak, so the
/// arc is partway round rather than empty or complete.
void main() {
  final today = DateTime(2026, 9, 13);

  final progress = PracticeProgress(
    today: today,
    wordsToday: 12,
    daysPractised: <DateTime>{
      today,
      today.subtract(const Duration(days: 1)),
      today.subtract(const Duration(days: 2)),
      today.subtract(const Duration(days: 3)),
    },
  );

  Widget framed(ThemeData theme) => SizedBox(
    width: 360,
    height: 720,
    child: ProviderScope(
      overrides: <Override>[
        totalWordCountProvider.overrideWith((ref) => Stream.value(42)),
        dueCardCountProvider.overrideWith((ref) => Stream.value(7)),
        practiceProgressProvider.overrideWith((ref) => Stream.value(progress)),
        appSettingsOrDefaultsProvider.overrideWithValue(AppSettings.defaults),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        home: const PracticeHubScreen(),
      ),
    ),
  );

  unawaited(
    goldenTest(
      'the practice hub and its goal ring, in both themes',
      fileName: 'practice_hub',
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
