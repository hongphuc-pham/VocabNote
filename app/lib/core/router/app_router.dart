import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/presentation/common/placeholder_screen.dart';
import 'package:vocabnote/presentation/lists/lists_screen.dart';
import 'package:vocabnote/presentation/practice/practice_hub_screen.dart';
import 'package:vocabnote/presentation/shell/app_shell.dart';
import 'package:vocabnote/presentation/words/words_screen.dart';

part 'app_router.g.dart';

/// The router for the whole app (`docs/UI-UX.md` section 3).
///
/// Three tab branches keep their own stacks inside [AppShell]; detail, editor
/// and settings routes are pushed onto the root navigator so they cover the
/// bottom bar and get a back arrow, matching the mocks in section 4.3-4.4.
///
/// Screens that a later milestone owns resolve to [PlaceholderScreen] for now,
/// so navigation is real and testable from M0.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.words,
    routes: _routes,
    errorBuilder: (context, state) =>
        _RouteNotFoundScreen(location: state.uri.toString()),
  );
  ref.onDispose(router.dispose);
  return router;
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

List<RouteBase> get _routes => <RouteBase>[
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        AppShell(navigationShell: navigationShell),
    branches: <StatefulShellBranch>[
      StatefulShellBranch(routes: <RouteBase>[_wordsBranch]),
      StatefulShellBranch(routes: <RouteBase>[_practiceBranch]),
      StatefulShellBranch(routes: <RouteBase>[_listsBranch]),
    ],
  ),
  _settingsRoute,
  GoRoute(
    path: Routes.onboarding,
    name: RouteNames.onboarding,
    parentNavigatorKey: _rootNavigatorKey,
    builder: (context, state) => PlaceholderScreen(
      title: AppL10n.of(context).onboardingTitle,
      routePath: Routes.onboarding,
    ),
  ),
];

// --- Words -----------------------------------------------------------------

GoRoute get _wordsBranch => GoRoute(
  path: Routes.words,
  name: RouteNames.words,
  builder: (context, state) => const WordsScreen(),
  routes: <RouteBase>[
    GoRoute(
      path: ':${Routes.wordIdParam}',
      name: RouteNames.wordDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PlaceholderScreen(
        title: AppL10n.of(context).wordDetailTitle,
        routePath: Routes.wordDetail,
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'edit',
          name: RouteNames.wordEdit,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => PlaceholderScreen(
            title: AppL10n.of(context).wordEditTitle,
            routePath: Routes.wordEdit,
          ),
        ),
        GoRoute(
          path: 'ipa',
          name: RouteNames.wordIpa,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => PlaceholderScreen(
            title: AppL10n.of(context).ipaEditorTitle,
            routePath: Routes.wordIpa,
          ),
        ),
      ],
    ),
  ],
);

// --- Practice --------------------------------------------------------------

GoRoute get _practiceBranch => GoRoute(
  path: Routes.practice,
  name: RouteNames.practice,
  builder: (context, state) => const PracticeHubScreen(),
  routes: <RouteBase>[
    GoRoute(
      path: 'summary/:${Routes.sessionIdParam}',
      name: RouteNames.practiceSummary,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PlaceholderScreen(
        title: AppL10n.of(context).practiceSummaryTitle,
        routePath: Routes.practiceSummary,
      ),
    ),
    GoRoute(
      path: ':${Routes.gameIdParam}/run',
      name: RouteNames.practiceRun,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PlaceholderScreen(
        title: AppL10n.of(context).practiceRunTitle,
        routePath: Routes.practiceRun,
      ),
    ),
  ],
);

// --- Lists -----------------------------------------------------------------

GoRoute get _listsBranch => GoRoute(
  path: Routes.lists,
  name: RouteNames.lists,
  builder: (context, state) => const ListsScreen(),
  routes: <RouteBase>[
    GoRoute(
      path: ':${Routes.listIdParam}',
      name: RouteNames.listDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PlaceholderScreen(
        title: AppL10n.of(context).listDetailTitle,
        routePath: Routes.listDetail,
      ),
    ),
  ],
);

// --- Settings --------------------------------------------------------------

GoRoute get _settingsRoute => GoRoute(
  path: Routes.settings,
  name: RouteNames.settings,
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) => PlaceholderScreen(
    title: AppL10n.of(context).settingsTitle,
    routePath: Routes.settings,
  ),
  routes: <RouteBase>[
    GoRoute(
      path: 'guide',
      name: RouteNames.guide,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PlaceholderScreen(
        title: AppL10n.of(context).guideTitle,
        routePath: Routes.guide,
      ),
    ),
    GoRoute(
      path: 'help',
      name: RouteNames.help,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PlaceholderScreen(
        title: AppL10n.of(context).helpTitle,
        routePath: Routes.help,
      ),
    ),
    GoRoute(
      path: 'backup',
      name: RouteNames.backup,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PlaceholderScreen(
        title: AppL10n.of(context).backupTitle,
        routePath: Routes.backup,
      ),
    ),
    GoRoute(
      path: 'licences',
      name: RouteNames.licences,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PlaceholderScreen(
        title: AppL10n.of(context).licencesTitle,
        routePath: Routes.licences,
      ),
    ),
  ],
);

/// Shown when a route cannot be resolved - a stale deep link, usually.
///
/// Copy follows `docs/UI-UX.md` section 5: say what happened, offer the way
/// out, never blame the user.
class _RouteNotFoundScreen extends StatelessWidget {
  const new({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.routeNotFoundTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.routeNotFoundBody,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.comingSoonRoute(location),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => context.go(Routes.words),
                child: Text(l10n.routeNotFoundAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
