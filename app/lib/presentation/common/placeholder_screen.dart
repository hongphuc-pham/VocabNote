import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/tokens.dart';

/// Stands in for a screen that a later milestone builds.
///
/// Every route in `docs/UI-UX.md` §3 resolves from M0 onwards, so navigation
/// can be wired and tested before the screens exist. Each one is replaced in
/// the milestone that owns it; none of this copy survives to release.
class PlaceholderScreen extends StatelessWidget {
  /// Creates a placeholder for [title], standing in for [routePath].
  const new({
    required this.title,
    required this.routePath,
    this.actions,
    super.key,
  });

  /// App bar title — always an l10n string.
  final String title;

  /// The route this screen is standing in for, shown for orientation while the
  /// app is still a skeleton.
  final String routePath;

  /// Extra app bar actions, e.g. the settings button on a tab root.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.construction_outlined,
                size: AppSpacing.xxl,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.comingSoonTitle,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.comingSoonBody,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.comingSoonRoute(routePath),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
