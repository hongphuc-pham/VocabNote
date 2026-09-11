import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/domain/entities/backup.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// What an import did (F-074: "Reports added / updated / skipped").
///
/// Plain counts, warmest first. Rows that could not be used get one quiet
/// line - worth knowing, never alarming - and a replace says where the way
/// back is.
Future<void> showImportReport(
  BuildContext context,
  ImportReport report,
  ImportMode mode,
) {
  final l10n = AppL10n.of(context);
  final also = <String>[
    if (report.notesAdded > 0) l10n.importReportNotes(report.notesAdded),
    if (report.highlightsAdded > 0)
      l10n.importReportHighlights(report.highlightsAdded),
    if (report.listsAdded > 0) l10n.importReportLists(report.listsAdded),
  ];
  final lines = <String>[
    if (mode == ImportMode.replace)
      l10n.importReportRestored(report.wordsAdded)
    else ...<String>[
      l10n.importReportAdded(report.wordsAdded),
      if (report.wordsUpdated > 0)
        l10n.importReportUpdated(report.wordsUpdated),
      if (report.wordsSkipped > 0)
        l10n.importReportSkipped(report.wordsSkipped),
    ],
    if (also.isNotEmpty) l10n.importReportAlso(also.join(l10n.listSeparator)),
    if (report.rejected > 0) l10n.importReportRejected(report.rejected),
    if (mode == ImportMode.replace) l10n.importReportSafetyCopy,
  ];

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.importReportTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final (index, line) in lines.indexed) ...<Widget>[
              if (index > 0) const VnGap(VnSpace.xs),
              Text(line),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.importReportDone),
        ),
      ],
    ),
  );
}
