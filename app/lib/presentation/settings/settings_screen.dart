import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/settings/reminder_controller.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/repositories/reminder_service.dart';

/// Settings (F-070) — so far the Practice section, with the daily reminder
/// (F-066).
///
/// M6 builds the rest of `docs/UI-UX.md` §4.9 here. The reminder came first
/// because it had nowhere else to live: its switch is the only thing in the
/// app allowed to ask for notification permission.
class SettingsScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  /// The reminder's words, in the user's language.
  static ReminderCopy reminderCopy(AppL10n l10n) => ReminderCopy(
    title: l10n.reminderNotificationTitle,
    body: l10n.reminderNotificationBody,
    channelName: l10n.reminderChannelName,
    channelDescription: l10n.reminderChannelDescription,
  );

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    // Read before the await - a WidgetRef is only good for its build.
    final actions = ref.read(reminderActionsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    final outcome = await actions.enable(reminderCopy(l10n));
    // Said plainly and once. A refusal is the user's decision, or their
    // phone's; nothing here argues with it.
    switch (outcome) {
      case ReminderOutcome.on:
        break;
      case ReminderOutcome.denied:
        messenger.showSnackBar(SnackBar(content: Text(l10n.reminderDenied)));
      case ReminderOutcome.failed:
        messenger.showSnackBar(SnackBar(content: Text(l10n.reminderFailed)));
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay current,
  ) async {
    final actions = ref.read(reminderActionsProvider.notifier);
    final copy = reminderCopy(AppL10n.of(context));
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    await actions.setTime(picked.hour * 60 + picked.minute, copy);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;
    final settings = ref.watch(appSettingsOrDefaultsProvider);
    final minutes =
        settings.reminderTimeMinutes ?? ReminderActions.defaultMinutes;
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    final timeText = time.format(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.spaceLg,
              metrics.spaceLg,
              metrics.spaceLg,
              metrics.spaceSm,
            ),
            child: Text(
              l10n.settingsPracticeSection,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.reminderTitle),
            subtitle: Text(
              settings.reminderEnabled
                  ? l10n.reminderOnAt(timeText)
                  : l10n.reminderOff,
            ),
            value: settings.reminderEnabled,
            onChanged: (on) => unawaited(
              on
                  ? _enable(context, ref)
                  : ref.read(reminderActionsProvider.notifier).disable(),
            ),
          ),
          if (settings.reminderEnabled)
            ListTile(
              title: Text(l10n.reminderTimeLabel),
              trailing: Text(timeText),
              onTap: () => unawaited(_pickTime(context, ref, time)),
            ),
        ],
      ),
    );
  }
}
