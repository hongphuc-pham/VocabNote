import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/presentation/common/placeholder_screen.dart';
import 'package:vocabnote/presentation/common/settings_action.dart';

/// The words list — the app's home tab (`docs/UI-UX.md` §4.1).
///
/// M2 replaces this with the real list: search, filter chips, sort, 72dp rows
/// with inline highlighted IPA, and the *Add word* FAB.
class WordsScreen extends StatelessWidget {
  /// Creates the words screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppL10n.of(context).wordsTitle,
      routePath: Routes.words,
      actions: const <Widget>[SettingsAction()],
    );
  }
}
