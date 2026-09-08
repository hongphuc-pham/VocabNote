import 'package:flutter/material.dart';
import 'package:vocabnote/core/theme/tokens.dart';

/// The shared empty / error state (`docs/UI-UX.md` §4.1, §5, F-078).
///
/// Empty states teach the feature rather than apologising for it, so every one
/// carries a primary action. Copy is second person and never blames the user
/// (§5) - the strings live in l10n; this widget only arranges them.
class EmptyState extends StatelessWidget {
  /// Creates an empty state.
  const new({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  /// A quiet illustration. Never the only thing carrying meaning.
  final IconData icon;

  /// One short line saying where the user is.
  final String title;

  /// One or two lines saying what to do next.
  final String body;

  /// The primary action.
  final String? actionLabel;

  /// Runs the primary action.
  final VoidCallback? onAction;

  /// An optional secondary link, e.g. into the guide.
  final String? secondaryLabel;

  /// Runs the secondary action.
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Decorative: the title and body carry the meaning, so a screen
              // reader should not announce an icon name.
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: AppSpacing.xxl + AppSpacing.lg,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                body,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xl),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
              if (secondaryLabel != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
