import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';

/// The bottom-navigation shell: Words · Practice · Lists (`docs/UI-UX.md` §3).
///
/// Flat and obvious — no drawer, no nested tabs. Settings is an app bar icon on
/// each tab rather than a fourth destination, because it is a detour, not a
/// place the user works.
///
/// Each branch keeps its own navigation stack, so switching tabs and coming
/// back returns the user where they were.
class AppShell extends StatelessWidget {
  /// Creates the shell around [navigationShell].
  const new({required this.navigationShell, super.key});

  /// The branch navigator built by `StatefulShellRoute.indexedStack`.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.navWords,
          ),
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
            label: l10n.navPractice,
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: l10n.navLists,
          ),
        ],
      ),
    );
  }

  void _onDestinationSelected(int index) {
    // Tapping the tab you are already on pops that branch back to its root —
    // the behaviour every platform's tab bar has trained users to expect.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
