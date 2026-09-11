import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/practice/scheduler/review_schedule.dart';
import 'package:vocabnote/application/settings/settings_actions.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/presentation/design/button_row.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';

/// Edits the interval of each Leitner box (`docs/GAMES.md` §5).
///
/// Box 0 is shown but not editable: it is the relearning box, always "later
/// the same day". A table that would stop words coming back is refused with a
/// sentence naming the box, and *Save* stays disabled until it is fixed - so
/// a broken table never reaches the scheduler, even for a moment.
class IntervalEditorSheet extends ConsumerStatefulWidget {
  /// Creates the sheet, starting from [initial].
  const new({required this.initial, super.key});

  /// The table being edited.
  final ReviewSchedule initial;

  /// Opens the sheet over [context].
  static Future<void> show(BuildContext context, ReviewSchedule current) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => IntervalEditorSheet(initial: current),
      );

  @override
  ConsumerState<IntervalEditorSheet> createState() =>
      _IntervalEditorSheetState();
}

class _IntervalEditorSheetState extends ConsumerState<IntervalEditorSheet> {
  /// One field per box after box 0.
  late final List<TextEditingController> _fields = <TextEditingController>[
    for (var box = 1; box < ReviewSchedule.boxCount; box++)
      TextEditingController(text: '${widget.initial.daysForBox(box)}'),
  ];

  bool _saving = false;

  @override
  void dispose() {
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  /// The table the fields describe, or the first box whose field is empty.
  ({ReviewSchedule? schedule, int? emptyBox}) _read() {
    final days = <int>[0];
    for (var i = 0; i < _fields.length; i++) {
      final value = int.tryParse(_fields[i].text.trim());
      if (value == null) return (schedule: null, emptyBox: i + 1);
      days.add(value);
    }
    return (schedule: ReviewSchedule(days), emptyBox: null);
  }

  /// Why the table cannot be saved, in words, or null when it can.
  String? _reason(AppL10n l10n) {
    final (:schedule, :emptyBox) = _read();
    if (emptyBox != null) return l10n.scheduleIssueNotNumber(emptyBox);
    return switch (schedule?.issue) {
      null => null,
      BoxTooShort(:final box) => l10n.scheduleIssueTooShort(box),
      BoxShorterThanPrevious(:final box) => l10n.scheduleIssueShorter(
        box,
        box - 1,
      ),
      // Neither can be typed here - the sheet always builds seven boxes with
      // box 0 at zero - but the switch must still say something.
      WrongBoxCount() || RelearningBoxNotZero() => l10n.scheduleIssueUnusable,
    };
  }

  void _useStandard() {
    setState(() {
      for (var i = 0; i < _fields.length; i++) {
        _fields[i].text = '${ReviewSchedule.standard.daysForBox(i + 1)}';
      }
    });
  }

  Future<void> _save() async {
    final schedule = _read().schedule;
    if (schedule == null) return;
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    final issue = await ref
        .read(settingsActionsProvider.notifier)
        .setSchedule(schedule);
    if (!mounted) return;
    if (issue == null) {
      navigator.pop();
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final reason = _reason(l10n);
    final last = _fields.length - 1;

    return VnSheetBody(
      children: <Widget>[
        Text(l10n.settingsIntervals, style: theme.textTheme.titleLarge),
        const VnGap(VnSpace.sm),
        Text(l10n.intervalEditorBody, style: theme.textTheme.bodyMedium),
        const VnGap(VnSpace.lg),
        Text(l10n.intervalEditorBoxZero, style: theme.textTheme.bodyMedium),
        for (var i = 0; i < _fields.length; i++)
          Padding(
            padding: EdgeInsets.only(top: context.metrics.spaceMd),
            child: TextField(
              controller: _fields[i],
              keyboardType: TextInputType.number,
              textInputAction: i == last
                  ? TextInputAction.done
                  : TextInputAction.next,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                // A year is 365; four digits is already a mistake.
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                labelText: l10n.intervalEditorBox(i + 1),
                suffixText: l10n.intervalEditorDays,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        if (reason != null) ...<Widget>[
          const VnGap(VnSpace.md),
          // Announced as it changes, so a screen-reader user hears why Save
          // went quiet without having to find this line.
          Semantics(
            liveRegion: true,
            child: Text(
              reason,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
        const VnGap(VnSpace.lg),
        VnButtonRow(
          labels: <String>[l10n.intervalEditorReset, l10n.intervalEditorSave],
          children: <Widget>[
            TextButton(
              onPressed: _useStandard,
              child: Text(l10n.intervalEditorReset),
            ),
            FilledButton(
              onPressed: reason == null && !_saving
                  ? () => unawaited(_save())
                  : null,
              child: Text(l10n.intervalEditorSave),
            ),
          ],
        ),
      ],
    );
  }
}
