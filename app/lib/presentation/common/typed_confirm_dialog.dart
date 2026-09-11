import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/presentation/design/gap.dart';

/// Asks for [word] to be typed before an action that cannot be undone with a
/// tap - RULES §11: "Undo (5s snackbar) or a typed confirmation".
///
/// Resolves true only when the word was typed (any case) and the action
/// pressed; dismissing, cancelling or backing out are all false.
Future<bool> showTypedConfirmation(
  BuildContext context, {
  required String title,
  required String body,
  required String word,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => _TypedConfirmDialog(
        title: title,
        body: body,
        word: word,
        action: action,
      ),
    ) ??
    false;

class _TypedConfirmDialog extends StatefulWidget {
  const new({
    required this.title,
    required this.body,
    required this.word,
    required this.action,
  });

  final String title;
  final String body;
  final String word;
  final String action;

  @override
  State<_TypedConfirmDialog> createState() => _TypedConfirmDialogState();
}

class _TypedConfirmDialogState extends State<_TypedConfirmDialog> {
  final TextEditingController _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  /// Any case: the point is that the user stopped and typed it, not that
  /// they found the shift key.
  bool get _matches =>
      _typed.text.trim().toLowerCase() == widget.word.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.title),
      // Scrolls, so the field and its prompt survive 200% text with the
      // keyboard up.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.body),
            const VnGap(VnSpace.md),
            Text(l10n.typedConfirmPrompt(widget.word)),
            const VnGap(VnSpace.sm),
            TextField(
              controller: _typed,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(hintText: widget.word),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          child: Text(widget.action),
        ),
      ],
    );
  }
}
