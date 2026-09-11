import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/section.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';

/// Help → *View error log* (F-079): what VocabNote ran into, readable and
/// clearable, and never sent by itself.
class ErrorLogSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const new({super.key});

  /// Opens the sheet over [context].
  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const ErrorLogSheet(),
  );

  @override
  ConsumerState<ErrorLogSheet> createState() => _ErrorLogSheetState();
}

class _ErrorLogSheetState extends ConsumerState<ErrorLogSheet> {
  /// Null while it is being read.
  String? _text;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final text = (await ref.read(errorLogProvider).read()).valueOrNull ?? '';
    if (mounted) setState(() => _text = text);
  }

  Future<void> _clear() async {
    await ref.read(errorLogProvider).clear();
    if (mounted) setState(() => _text = '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final metrics = context.metrics;
    final text = _text;

    return VnSheetBody(
      children: <Widget>[
        Text(l10n.errorLogTitle, style: theme.textTheme.titleLarge),
        const VnGap(VnSpace.sm),
        VnQuietText(l10n.errorLogIntro, emphasis: VnQuietEmphasis.body),
        const VnGap(VnSpace.md),
        // Words, not a spinner, while it is read: a spinner never settles.
        if (text == null)
          Text(l10n.errorLogReading)
        else if (text.trim().isEmpty)
          Text(l10n.errorLogEmpty, style: theme.textTheme.bodyMedium)
        else ...<Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(metrics.spaceMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: metrics.cardBorder,
            ),
            child: SelectableText(text, style: theme.textTheme.bodySmall),
          ),
          const VnGap(VnSpace.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => unawaited(_clear()),
              child: Text(l10n.errorLogClear),
            ),
          ),
        ],
      ],
    );
  }
}
