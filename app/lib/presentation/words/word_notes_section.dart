import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vocabnote/application/words/word_notes_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/entities/word_note.dart';

/// The *My notes* block on word detail (`docs/UI-UX.md` §4.3, F-003).
///
/// Notes are the user's own writing: they carry no attribution and are never
/// filled in from a dictionary. Adding one is deliberately two taps from the
/// word — it is the thing people actually come back to.
class WordNotesSection extends ConsumerWidget {
  /// Creates the notes block for [wordId].
  const new({required this.wordId, required this.notes, super.key});

  /// The word the notes belong to.
  final String wordId;

  /// Its notes, pinned first.
  final List<WordNote> notes;

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final body = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddNoteSheet(),
    );

    final trimmed = body?.trim() ?? '';
    if (trimmed.isEmpty) return;

    await ref
        .read(wordNotesProvider.notifier)
        .add(wordId: wordId, body: trimmed);
  }

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    WordNote note,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    await ref.read(wordNotesProvider.notifier).delete(note.id);

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.detailNoteDeletedSnack)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.detailNotesHeading,
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () => _addNote(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.detailAddNoteAction),
            ),
          ],
        ),
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              l10n.detailNoNotesBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          for (final note in notes)
            _NoteRow(
              note: note,
              onDelete: () => _deleteNote(context, ref, note),
            ),
      ],
    );
  }
}

/// One note: its date and body, with a delete button.
class _NoteRow extends StatelessWidget {
  const new({required this.note, required this.onDelete});

  final WordNote note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    // "3 Sep" — the spec's format. Localised, so a second locale gets its own.
    final date = DateFormat.MMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(note.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Icon(
              Icons.circle,
              size: AppSpacing.sm,
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '$date — ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  TextSpan(text: note.body),
                ],
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            iconSize: AppSpacing.lg,
            tooltip: l10n.detailNoteDeleteAction,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// The sheet that writes a new note.
class _AddNoteSheet extends StatefulWidget {
  const new();

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Padding(
      // Lifts the sheet above the keyboard rather than letting it cover the
      // field the user is typing into.
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l10n.detailNoteHeading, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.fieldNoteHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancelAction),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_controller.text),
                child: Text(l10n.saveAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
