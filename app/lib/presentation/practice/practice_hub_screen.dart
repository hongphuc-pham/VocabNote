import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/presentation/common/placeholder_screen.dart';
import 'package:vocabnote/presentation/common/settings_action.dart';

/// The practice hub (`docs/UI-UX.md` §4.6).
///
/// M5 replaces this with the goal ring and one card per registered game.
class PracticeHubScreen extends StatelessWidget {
  /// Creates the practice hub.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppL10n.of(context).practiceTitle,
      routePath: Routes.practice,
      actions: const <Widget>[SettingsAction()],
    );
  }
}
