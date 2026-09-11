import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/words/highlight_editor_controller.dart';
import 'package:vocabnote/application/words/word_detail_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/word.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/common/ipa_speech.dart';
import 'package:vocabnote/presentation/design/gap.dart';
import 'package:vocabnote/presentation/words/highlight_color_sheet.dart';
import 'package:vocabnote/presentation/words/highlight_legend.dart';
import 'package:vocabnote/presentation/words/ipa_chip_row.dart';

/// The IPA highlight editor — the signature screen (`docs/UI-UX.md` §4.4, F-022).
///
/// One primary action: **colour the sound you struggle with**.
///
/// The whole session is held in memory with session-wide undo, and **nothing is
/// written until *Done***. That is what makes experimenting safe, and it is why
/// leaving with unsaved changes asks first.
class IpaEditorScreen extends ConsumerWidget {
  /// Creates the editor for [wordId].
  const new({required this.wordId, super.key});

  /// The word being marked up.
  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final detail = ref.watch(wordDetailProvider(wordId));

    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.ipaEditorTitle)),
        body: EmptyState(
          icon: Icons.error_outline,
          title: l10n.detailLoadFailedTitle,
          body: l10n.detailLoadFailedBody,
          actionLabel: l10n.retryAction,
          onAction: () => ref.invalidate(wordDetailProvider(wordId)),
        ),
      ),
      data: (loaded) {
        if (loaded == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.ipaEditorTitle)),
            body: EmptyState(
              icon: Icons.delete_outline,
              title: l10n.detailNotFoundTitle,
              body: l10n.detailNotFoundBody,
              actionLabel: l10n.backLabel,
              onAction: () => context.go(Routes.words),
            ),
          );
        }

        // UK is the transcription the app prefers everywhere
        // (`Word.preferredIpa`) and the one the offline fallback cannot supply,
        // so a present UK value is one somebody chose. The target follows
        // whichever exists.
        final useUk = loaded.word.ipaUk != null;
        final ipa = useUk ? loaded.word.ipaUk : loaded.word.ipaUs;

        if (ipa == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.ipaEditorTitle)),
            body: EmptyState(
              icon: Icons.record_voice_over_outlined,
              title: l10n.ipaEditorNoIpaTitle,
              body: l10n.ipaEditorNoIpaBody,
              actionLabel: l10n.detailAddIpaAction,
              onAction: () => context.push(Routes.wordEditOf(wordId)),
            ),
          );
        }

        return _Editor(
          word: loaded.word,
          target: useUk ? HighlightTarget.ipaUk : HighlightTarget.ipaUs,
          ipa: ipa.value,
          stored: loaded.highlights,
        );
      },
    );
  }
}

/// The editor proper, once there is a transcription to mark up.
class _Editor extends ConsumerStatefulWidget {
  const new({
    required this.word,
    required this.target,
    required this.ipa,
    required this.stored,
  });

  final Word word;
  final HighlightTarget target;
  final String ipa;
  final List<IpaHighlight> stored;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  HighlightEditorProvider get _provider =>
      highlightEditorProvider(widget.word.id, widget.target, widget.ipa);

  /// Whether anything has been changed since the editor opened.
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    // Seeded after the first frame: reading a notifier during initState is
    // fine, but writing to it is a state change during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(_provider.notifier).loadFrom(widget.stored);
    });
  }

  Future<void> _colourSelection() async {
    final choice = await HighlightColorSheet.show(context);
    if (choice == null || choice.isDelete) return;

    ref.read(_provider.notifier).applyColor(choice.color!, label: choice.label);
    setState(() => _dirty = true);
  }

  Future<void> _editHighlight(IpaHighlight highlight) async {
    final choice = await HighlightColorSheet.show(context, existing: highlight);
    if (choice == null) return;

    final editor = ref.read(_provider.notifier);
    if (choice.isDelete) {
      editor.removeHighlight(highlight.id);
    } else {
      editor.applyColor(
        choice.color!,
        label: choice.label,
        replacing: highlight.id,
      );
    }
    setState(() => _dirty = true);
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    final router = GoRouter.of(context);

    final result = await ref.read(_provider.notifier).save();

    result.fold(
      (_) {
        if (router.canPop()) router.pop();
      },
      (_) => messenger.showSnackBar(
        SnackBar(content: Text(l10n.ipaEditorSaveFailed)),
      ),
    );
  }

  /// Asks before throwing away unsaved colours.
  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final l10n = AppL10n.of(context);

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ipaEditorDiscardTitle),
        content: Text(l10n.ipaEditorDiscardBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.ipaEditorKeepEditingAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.ipaEditorDiscardAction),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final state = ref.watch(_provider);
    final editor = ref.read(_provider.notifier);
    final selected = state.selection;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.ipaEditorTitle),
          actions: <Widget>[
            TextButton(
              onPressed: state.canUndo
                  ? () {
                      editor.undo();
                      setState(() => _dirty = true);
                    }
                  : null,
              child: Text(l10n.ipaEditorUndoAction),
            ),
            TextButton(onPressed: _save, child: Text(l10n.ipaEditorDoneAction)),
          ],
        ),
        floatingActionButton: selected == null
            ? null
            : FloatingActionButton.extended(
                onPressed: _colourSelection,
                icon: const Icon(Icons.palette_outlined),
                label: Text(l10n.ipaEditorColorHeading),
              ),
        body: ListView(
          padding: EdgeInsets.all(context.metrics.spaceLg),
          children: <Widget>[
            Text(l10n.ipaEditorIntro, style: theme.textTheme.bodyMedium),
            const VnGap(VnSpace.lg),
            IpaChipRow(
              chips: state.chips,
              highlights: state.highlights,
              selection: state.selection,
              onSelectAt: editor.selectAt,
              onExtendTo: editor.extendTo,
            ),
            const VnGap(VnSpace.md),
            // Announced live, so a screen-reader user hears "selected sh, er
            // as in her" as the run changes (`UI-UX.md` §4.4) - the sounds,
            // by their learner names, as the chips are.
            Semantics(
              liveRegion: true,
              child: Text(
                selected == null
                    ? l10n.ipaEditorNothingSelected
                    : l10n.ipaEditorSelectedLabel(
                        spokenIpa(
                          l10n,
                          state.selectionSymbols,
                          announce: false,
                        ),
                      ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const VnGap(VnSpace.lg),
            HighlightLegend(
              highlights: state.highlights,
              onJumpTo: _editHighlight,
            ),
          ],
        ),
      ),
    );
  }
}
