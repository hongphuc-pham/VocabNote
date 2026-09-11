import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/presentation/design/button_row.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';

/// What a chosen backup holds, and how it should come in (F-074).
///
/// Shown before anything is written. Merge is chosen already, because it
/// removes nothing; Replace is one tap away and says plainly what it does.
class ImportPreviewSheet extends StatefulWidget {
  /// Creates the sheet for a backup described by [manifest].
  const new({required this.manifest, super.key});

  /// What the backup says it holds.
  final BackupManifest manifest;

  /// Opens the sheet; resolves to the chosen mode, or null if dismissed.
  static Future<ImportMode?> show(
    BuildContext context,
    BackupManifest manifest,
  ) => showModalBottomSheet<ImportMode>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ImportPreviewSheet(manifest: manifest),
  );

  @override
  State<ImportPreviewSheet> createState() => _ImportPreviewSheetState();
}

class _ImportPreviewSheetState extends State<ImportPreviewSheet> {
  ImportMode _mode = ImportMode.merge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final manifest = widget.manifest;
    final made = manifest.exportedAt;
    final locale = Localizations.localeOf(context).toString();

    return VnSheetBody(
      children: <Widget>[
        Text(l10n.importPreviewTitle, style: theme.textTheme.titleLarge),
        const VnGap(VnSpace.sm),
        Text(
          <String>[
            l10n.importPreviewWords(manifest.wordCount),
            l10n.importPreviewLists(manifest.counts['word_lists'] ?? 0),
          ].join(l10n.listSeparator),
          style: theme.textTheme.titleSmall,
        ),
        if (made != null)
          Text(
            l10n.importPreviewMade(
              DateFormat.yMMMd(locale).add_jm().format(made.toLocal()),
            ),
            style: theme.textTheme.bodyMedium,
          ),
        const VnGap(VnSpace.lg),
        RadioGroup<ImportMode>(
          groupValue: _mode,
          onChanged: (mode) => setState(() => _mode = mode ?? _mode),
          child: Column(
            children: <Widget>[
              RadioListTile<ImportMode>(
                value: ImportMode.merge,
                title: Text(l10n.importModeMerge),
                subtitle: Text(l10n.importModeMergeHint),
              ),
              RadioListTile<ImportMode>(
                value: ImportMode.replace,
                title: Text(l10n.importModeReplace),
                subtitle: Text(l10n.importModeReplaceHint),
              ),
            ],
          ),
        ),
        const VnGap(VnSpace.lg),
        VnButtonRow(
          labels: <String>[l10n.cancelAction, l10n.importContinue],
          children: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_mode),
              child: Text(l10n.importContinue),
            ),
          ],
        ),
      ],
    );
  }
}
