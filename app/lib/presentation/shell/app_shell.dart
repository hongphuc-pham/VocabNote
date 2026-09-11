import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/settings/reminder_controller.dart';
import 'package:vocabnote/application/settings/settings_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/domain/entities/app_settings.dart';
import 'package:vocabnote/presentation/settings/settings_screen.dart';

/// The bottom-navigation shell: Words · Practice · Lists (`docs/UI-UX.md` §3).
///
/// Flat and obvious — no drawer, no nested tabs. Settings is an app bar icon on
/// each tab rather than a fourth destination, because it is a detour, not a
/// place the user works.
///
/// Each branch keeps its own navigation stack, so switching tabs and coming
/// back returns the user where they were.
class AppShell extends ConsumerStatefulWidget {
  /// Creates the shell around [navigationShell].
  const new({required this.navigationShell, super.key});

  /// The branch navigator built by `StatefulShellRoute.indexedStack`.
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _reminderSynced = false;

  /// Once per launch, when the settings are first known: the reminder repeats
  /// on UTC, so it is scheduled again here from the current local time
  /// (F-066). Only when it is already on - nothing here asks for permission or
  /// switches anything on.
  void _resyncOnce(AppSettings? settings, AppL10n l10n) {
    if (_reminderSynced || settings == null) return;
    _reminderSynced = true;
    if (!settings.reminderEnabled) return;
    unawaited(
      ref
          .read(reminderActionsProvider.notifier)
          .resync(SettingsScreen.reminderCopy(l10n)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // Settings still loading arrive through the listener. Settings already
    // loaded - the provider is kept alive - never change to be heard, so they
    // are read once as well.
    ref.listen(appSettingsProvider, (_, next) => _resyncOnce(next.value, l10n));
    _resyncOnce(ref.read(appSettingsProvider).value, l10n);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
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
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
