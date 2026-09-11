import 'package:flutter/material.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/design/sheet_body.dart';

/// What the sheet returns: a name and a colour.
@immutable
class ListDraft {
  /// Creates a draft.
  const new({required this.name, required this.color});

  /// The list's name, already trimmed and known non-empty.
  final String name;

  /// The card colour.
  final IpaColorToken color;
}

/// Creates or edits a list (F-042).
///
/// One sheet for both, because they ask for exactly the same two things.
/// Passing [existing] switches the title and pre-fills the fields.
class ListEditorSheet extends StatefulWidget {
  /// Creates the sheet.
  const new({this.existing, super.key});

  /// The list being edited, or null when creating one.
  final WordList? existing;

  /// Shows the sheet and resolves to the draft, or null if dismissed.
  static Future<ListDraft?> show(BuildContext context, {WordList? existing}) {
    return showModalBottomSheet<ListDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ListEditorSheet(existing: existing),
    );
  }

  @override
  State<ListEditorSheet> createState() => _ListEditorSheetState();
}

class _ListEditorSheetState extends State<ListEditorSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late IpaColorToken _color = widget.existing?.color ?? IpaColorToken.teal;
  bool _showError = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pop(ListDraft(name: name, color: _color));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final metrics = context.metrics;

    return VnSheetBody(
      children: <Widget>[
        Text(
          widget.existing == null ? l10n.createListTitle : l10n.editListTitle,
          style: theme.textTheme.titleLarge,
        ),
        const VnGap(VnSpace.lg),
        TextField(
          controller: _name,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.listNameLabel,
            hintText: l10n.listNameHint,
            errorText: _showError ? l10n.listNameRequired : null,
          ),
          onChanged: (_) {
            if (_showError) setState(() => _showError = false);
          },
          onSubmitted: (_) => _submit(),
        ),
        const VnGap(VnSpace.lg),
        Wrap(
          spacing: metrics.spaceSm,
          runSpacing: metrics.spaceSm,
          children: <Widget>[
            for (final token in IpaColorToken.values)
              _ColorChoice(
                token: token,
                selected: token == _color,
                onTap: () => setState(() => _color = token),
              ),
          ],
        ),
        const VnGap(VnSpace.lg),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _submit,
            child: Text(l10n.saveNoteAction),
          ),
        ),
      ],
    );
  }
}

/// One colour swatch, sized to the minimum touch target.
class _ColorChoice extends StatelessWidget {
  const new({required this.token, required this.selected, required this.onTap});

  final IpaColorToken token;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = context.metrics;
    final colors = context.ipaPalette.resolve(token);

    return Semantics(
      selected: selected,
      button: true,
      // The token name is the label: a swatch with no name is invisible to a
      // screen reader, and these five names are the app's own vocabulary.
      label: token.storageValue,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(metrics.radiusPill),
        child: SizedBox(
          width: metrics.minTouchTarget,
          height: metrics.minTouchTarget,
          child: Center(
            child: Container(
              width: metrics.spaceXl,
              height: metrics.spaceXl,
              decoration: BoxDecoration(
                color: colors.fill,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? theme.colorScheme.onSurface : colors.line,
                  width: selected ? metrics.spaceXs / 2 : 1,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: metrics.spaceLg, color: colors.line)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
