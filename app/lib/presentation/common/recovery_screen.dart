import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// Shown instead of the app when the database could not be opened.
///
/// `docs/DATABASE.md` §3.6 and §3.10. The one thing this screen must never do
/// is offer to reset: there is no backend, so a wiped database is a
/// permanently lost user. It explains what happened, promises nothing was
/// deleted, and offers **Export my data** - which reads the file raw and
/// read-only, since Drift is exactly what refused it.
///
/// Deliberately standalone - it renders before `ProviderScope`, without the
/// router or the database, because by definition none of those are available.
class RecoveryScreen extends StatefulWidget {
  /// Creates the recovery screen for [failure].
  const new({required this.failure, this.onExport, super.key});

  /// Why the database could not be opened.
  final AppFailure failure;

  /// Exports whatever is readable and offers it to the share sheet; true
  /// when the sheet opened. Null shows the button disabled rather than
  /// hidden, so the user can see that the option exists.
  final Future<bool> Function()? onExport;

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  bool _exporting = false;

  Future<void> _export(Future<bool> Function() export) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    setState(() => _exporting = true);
    final shared = await export();
    if (!mounted) return;
    setState(() => _exporting = false);
    if (!shared) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.recoveryExportFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final export = widget.onExport;

    final (title, body) = switch (widget.failure) {
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
            padding: EdgeInsets.all(context.metrics.spaceXxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.shield_outlined,
                    size: context.metrics.spaceXxl,
                    color: theme.colorScheme.primary,
                  ),
                  const VnGap(VnSpace.lg),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const VnGap(VnSpace.md),
                  Text(
                    body,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const VnGap(VnSpace.lg),
                  // The promise, stated plainly, because this is the moment a
                  // user is most afraid they have lost their words.
                  Container(
                    padding: EdgeInsets.all(context.metrics.spaceLg),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: context.metrics.cardBorder,
                    ),
                    child: Text(
                      l10n.recoveryNothingDeleted,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const VnGap(VnSpace.xl),
                  FilledButton.icon(
                    onPressed: export == null || _exporting
                        ? null
                        : () => unawaited(_export(export)),
                    icon: const Icon(Icons.ios_share),
                    label: Text(
                      _exporting
                          ? l10n.recoveryExporting
                          : l10n.recoveryExportAction,
                    ),
                  ),
                  const VnGap(VnSpace.sm),
                  Text(
                    widget.failure.debugLabel,
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

  /// Exports whatever is readable; true when the share sheet opened.
  final Future<bool> Function()? onExport;

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
