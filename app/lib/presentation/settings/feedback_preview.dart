import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/utils/external_links.dart';
import 'package:vocabnote/domain/entities/diagnostics.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// Help → *Send feedback* (F-072, `docs/UI-UX.md` §4.11).
///
/// Shows **exactly** what the email will carry - the three facts, and the
/// error log only if the box is ticked - with "Nothing else is included";
/// opens the user's own mail app only when they say so; and if no mail app
/// opens, says where to write instead. Nothing is sent by the app itself:
/// the user presses send in their mail app, or does not.
Future<void> sendFeedback(
  BuildContext context,
  WidgetRef ref,
  String address,
) async {
  final l10n = AppL10n.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final links = ref.read(linkOpenerProvider);

  final diagnostics =
      (await ref.read(diagnosticsSourceProvider).read()).valueOrNull;
  final log = (await ref.read(errorLogProvider).read()).valueOrNull ?? '';
  if (!context.mounted) return;

  final email = await showDialog<Uri>(
    context: context,
    builder: (context) =>
        _FeedbackPreview(address: address, diagnostics: diagnostics, log: log),
  );
  if (email == null) return;

  if (!await links.open(email)) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.feedbackNoMailApp(address))),
    );
  }
}

class _FeedbackPreview extends StatefulWidget {
  const new({
    required this.address,
    required this.diagnostics,
    required this.log,
  });

  final String address;
  final Diagnostics? diagnostics;
  final String log;

  @override
  State<_FeedbackPreview> createState() => _FeedbackPreviewState();
}

class _FeedbackPreviewState extends State<_FeedbackPreview> {
  /// Off until ticked: the log is the one thing the user must opt into.
  bool _includeLog = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final metrics = context.metrics;
    final facts = widget.diagnostics;
    final unknown = l10n.feedbackUnknown;
    final subject = l10n.feedbackSubject;

    final base = <String>[
      l10n.feedbackBodyPrompt,
      '',
      l10n.feedbackBodyDivider,
      l10n.feedbackAppVersion(facts?.appVersion ?? unknown),
      l10n.feedbackOsVersion(facts?.osVersion ?? unknown),
      l10n.feedbackDeviceModel(facts?.deviceModel ?? unknown),
    ].join('\n');
    final withHeading = '$base\n\n${l10n.feedbackLogHeading}';
    // Trimmed to fit the link, and what is shown is exactly what is sent.
    final excerpt = _includeLog
        ? FeedbackEmail.fitLog(
            to: widget.address,
            subject: subject,
            body: withHeading,
            log: widget.log,
          )
        : '';
    final body = excerpt.isEmpty ? base : '$withHeading\n\n$excerpt';

    return AlertDialog(
      title: Text(l10n.feedbackPreviewTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.feedbackPreviewIntro(widget.address)),
            const VnGap(VnSpace.md),
            Container(
              padding: EdgeInsets.all(metrics.spaceMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: metrics.cardBorder,
              ),
              child: Text(body, style: theme.textTheme.bodySmall),
            ),
            if (widget.log.trim().isNotEmpty)
              CheckboxListTile(
                value: _includeLog,
                onChanged: (on) => setState(() => _includeLog = on ?? false),
                title: Text(l10n.feedbackIncludeLog),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            const VnGap(VnSpace.sm),
            Text(l10n.feedbackNothingElse, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            FeedbackEmail.uri(to: widget.address, subject: subject, body: body),
          ),
          child: Text(l10n.feedbackOpenEmail),
        ),
      ],
    );
  }
}
