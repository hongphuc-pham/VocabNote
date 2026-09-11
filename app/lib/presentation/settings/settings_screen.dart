import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';
import 'package:vocabnote/presentation/settings/practice_settings.dart';
import 'package:vocabnote/presentation/settings/settings_sections.dart';

/// Settings (F-070, `docs/UI-UX.md` §4.9).
///
/// One primary job: change how the app behaves. Every control writes to the
/// settings row and takes effect at once, because every screen watches that
/// row rather than reading it at startup.
///
/// The sections are in the order §4.9 draws them. *Help* must always be here
/// with *How to use* and *Help & feedback* (RULES §4), which the widget test
/// holds it to.
class SettingsScreen extends StatelessWidget {
  /// Creates the screen.
  const new({super.key});

  /// The reminder's words, in the user's language.
  ///
  /// Kept here as well as in `practice_settings.dart` because the shell
  /// reschedules the reminder at launch and names it through this screen.
  static ReminderCopy reminderCopy(AppL10n l10n) => reminderCopyOf(l10n);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.of(context).settingsTitle)),
      body: ListView(
        padding: EdgeInsets.only(bottom: context.metrics.spaceXl),
        children: const <Widget>[
          AppearanceSettings(),
          PronunciationSettings(),
          PracticeSettings(),
          DataSettings(),
          HelpSettings(),
          AboutSettings(),
        ],
      ),
    );
  }
}
