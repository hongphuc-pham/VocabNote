import 'package:flutter/material.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/core/theme/tokens.dart';

/// Shown instead of the app when the database could not be opened.
///
/// `docs/DATABASE.md` §3.6 and §3.10. The one thing this screen must never do
/// is offer to reset: there is no backend, so a wiped database is a
/// permanently lost user. It explains what happened, promises nothing was
/// deleted, and offers **Export my data**.
///
/// Deliberately standalone - it renders before `ProviderScope`, without the
/// router or the database, because by definition none of those are available.
class RecoveryScreen extends StatelessWidget {
  /// Creates the recovery screen for [failure].
  const new({required this.failure, this.onExport, super.key});

  /// Why the database could not be opened.
  final AppFailure failure;

  /// Exports whatever is readable. Null while the export path is being built
  /// (M6, F-073), in which case the button is shown disabled rather than
  /// hidden, so the user can see that the option exists.
  final Future<void> Function()? onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    final (title, body) = switch (failure) {
      SchemaTooNewFailure() => (
        l10n.recoverySchemaTooNewTitle,
        l10n.recoverySchemaTooNewBody,
      ),
      MigrationFailure(:final backupRestored) => (
        l10n.recoveryMigrationTitle,
        backupRestored
            ? l10n.recoveryMigrationBodyRestored
            : l10n.recoveryMigrationBody,
      ),
      _ => (l10n.recoveryGenericTitle, l10n.recoveryGenericBody),
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.shield_outlined,
                    size: AppSpacing.xxl,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    body,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // The promise, stated plainly, because this is the moment a
                  // user is most afraid they have lost their words.
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: AppRadii.cardBorder,
                    ),
                    child: Text(
                      l10n.recoveryNothingDeleted,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: onExport,
                    icon: const Icon(Icons.ios_share),
                    label: Text(l10n.recoveryExportAction),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    failure.debugLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A minimal app wrapper so [RecoveryScreen] can render without the router.
class RecoveryApp extends StatelessWidget {
  /// Creates the wrapper.
  const new({required this.failure, this.onExport, super.key});

  /// Why the database could not be opened.
  final AppFailure failure;

  /// Exports whatever is readable.
  final Future<void> Function()? onExport;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: RecoveryScreen(failure: failure, onExport: onExport),
    );
  }
}
