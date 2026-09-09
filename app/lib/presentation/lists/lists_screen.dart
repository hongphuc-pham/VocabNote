import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/presentation/common/placeholder_screen.dart';
import 'package:vocabnote/presentation/common/settings_action.dart';

/// The lists (decks) grid (`docs/UI-UX.md` §4.5).
///
/// M4 replaces this with the coloured cards, counts and due-today badges.
class ListsScreen extends StatelessWidget {
  /// Creates the lists screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppL10n.of(context).listsTitle,
      routePath: Routes.lists,
      actions: const <Widget>[SettingsAction()],
    );
  }
}
