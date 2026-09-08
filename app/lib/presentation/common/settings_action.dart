import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';

/// The settings button that sits in every tab's app bar (`docs/UI-UX.md` §3).
///
/// Icon-only, so it carries a semantic label — `docs/UI-UX.md` §6 makes that
/// blocking, not optional. [IconButton] promotes [IconButton.tooltip] to the
/// accessibility label, so one string serves both.
class SettingsAction extends StatelessWidget {
  /// Creates the app bar settings button.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: AppL10n.of(context).settingsOpenLabel,
      onPressed: () => context.push(Routes.settings),
    );
  }
}
