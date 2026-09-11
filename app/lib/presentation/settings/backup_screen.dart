import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vocabnote/application/backup/backup_actions.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/repositories/backup_files.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/section.dart';

/// Backup & restore (F-073, F-074, `docs/UI-UX.md` §4.9).
///
/// One primary action: make a backup. There is no cloud, so this file is how
/// a user moves their words to a new phone - the screen says what is in it,
/// when the last one was made, and that nothing is uploaded.
class BackupScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _exporting = false;

  Future<void> _export(BuildContext buttonContext) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    final anchor = _anchorOf(buttonContext);

    setState(() => _exporting = true);
    final outcome = await ref
        .read(backupActionsProvider.notifier)
        .export(anchor: anchor);
    if (!mounted) return;
    setState(() => _exporting = false);

    switch (outcome) {
      case ExportOutcome.shared:
        messenger.showSnackBar(SnackBar(content: Text(l10n.backupExportDone)));
      case ExportOutcome.notShared:
        // The user closed the sheet; they know. Nothing to add.
        break;
      case ExportOutcome.failed:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.backupExportFailed)),
        );
    }
  }

  /// Where the button is, for the iPad's share popover.
  static ShareAnchor? _anchorOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return ShareAnchor(
      left: origin.dx,
      top: origin.dy,
      width: box.size.width,
      height: box.size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final last = ref.watch(lastBackupAtProvider).value;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        padding: EdgeInsets.all(context.metrics.spaceLg),
        children: <Widget>[
          Text(l10n.backupIntro, style: theme.textTheme.bodyLarge),
          const VnGap(VnSpace.lg),
          Text(
            last == null
                ? l10n.backupNever
                : l10n.backupLast(
                    DateFormat.yMMMd(locale).add_jm().format(last.toLocal()),
                  ),
            style: theme.textTheme.titleSmall,
          ),
          const VnGap(VnSpace.xl),
          Builder(
            builder: (buttonContext) => FilledButton.icon(
              onPressed: _exporting
                  ? null
                  : () => unawaited(_export(buttonContext)),
              icon: const Icon(Icons.ios_share),
              label: Text(
                _exporting ? l10n.backupPreparing : l10n.backupExport,
              ),
            ),
          ),
          const VnGap(VnSpace.sm),
          VnQuietText(l10n.backupExportHint),
        ],
      ),
    );
  }
}
