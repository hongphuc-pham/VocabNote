import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/lists/list_actions_controller.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/entities/word_list.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/common/settings_action.dart';
import 'package:vocabnote/presentation/lists/list_card.dart';
import 'package:vocabnote/presentation/lists/list_editor_sheet.dart';

/// The lists (decks) grid (`docs/UI-UX.md` §4.5, F-042).
class ListsScreen extends ConsumerWidget {
  /// Creates the lists screen.
  const new({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    // The notifier is read *before* the await, not after. A `WidgetRef` is
    // only good for the build that produced it; reading it once the sheet has
    // closed can throw, and because this runs unawaited the throw is swallowed
    // and the list is silently never created. Same lesson as M3's
    // `ref.read` inside `onDispose`.
    final actions = ref.read(listActionsProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final failedMessage = AppL10n.of(context).listSaveFailed;
    final draft = await ListEditorSheet.show(context);
    if (draft == null) return;

    final result = await actions.create(name: draft.name, color: draft.color);
    // Never swallow the Result. A create that fails silently looks exactly
    // like a create that never happened, which is how this went unnoticed
    // until a widget test asked the database whether the row existed.
    if (result.isErr) {
      messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final lists = ref.watch(listSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.listsTitle),
        actions: const <Widget>[SettingsAction()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Unique per branch - see the note on the words screen's FAB.
        heroTag: Routes.lists,
        onPressed: () => unawaited(_create(context, ref)),
        icon: const Icon(Icons.add),
        label: Text(l10n.newListAction),
      ),
      body: lists.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.listsLoadFailedTitle,
          body: l10n.listsLoadFailedBody,
        ),
        data: (data) => data.isEmpty
            ? EmptyState(
                icon: Icons.folder_copy_outlined,
                title: l10n.listsEmptyTitle,
                body: l10n.listsEmptyBody,
                actionLabel: l10n.newListAction,
                onAction: () => unawaited(_create(context, ref)),
              )
            : _Grid(lists: data),
      ),
    );
  }
}

/// The grid itself.
class _Grid extends ConsumerWidget {
  const new({required this.lists});

  final List<WordListSummary> lists;

  /// Moves [list] one place, by rewriting the whole order.
  ///
  /// The repository takes the complete order rather than a moved pair: a
  /// partial write would leave two lists claiming the same position.
  List<String> _moved(WordList list, {required int by}) {
    final ids = lists.map((s) => s.list.id).toList();
    final from = ids.indexOf(list.id);
    final to = (from + by).clamp(0, ids.length - 1);
    if (from == to) return ids;
    ids
      ..removeAt(from)
      ..insert(to, list.id);
    return ids;
  }

  Future<void> _actions(
    BuildContext context,
    WidgetRef ref,
    WordList list,
  ) async {
    // Read before the first await - see the note on `_create`.
    final actions = ref.read(listActionsProvider.notifier);
    final index = lists.indexWhere((s) => s.list.id == list.id);
    final isFirst = index <= 0;
    final isLast = index == lists.length - 1;
    final chosen = await showModalBottomSheet<_ListAction>(
      context: context,
      builder: (context) {
        final l10n = AppL10n.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.renameListAction),
                onTap: () => Navigator.of(context).pop(_ListAction.edit),
              ),
              // Reordering is a drag, and `docs/UI-UX.md` §1 forbids an action
              // that only a gesture can reach - a screen-reader user cannot
              // pan. These two are the same operation, one step at a time.
              if (!isFirst)
                ListTile(
                  leading: const Icon(Icons.arrow_upward),
                  title: Text(l10n.moveListUpAction),
                  onTap: () => Navigator.of(context).pop(_ListAction.moveUp),
                ),
              if (!isLast)
                ListTile(
                  leading: const Icon(Icons.arrow_downward),
                  title: Text(l10n.moveListDownAction),
                  onTap: () => Navigator.of(context).pop(_ListAction.moveDown),
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.deleteListAction),
                onTap: () => Navigator.of(context).pop(_ListAction.delete),
              ),
            ],
          ),
        );
      },
    );
    if (!context.mounted || chosen == null) return;

    switch (chosen) {
      case _ListAction.edit:
        final draft = await ListEditorSheet.show(context, existing: list);
        if (draft == null) return;
        await actions.rename(list.copyWith(color: draft.color), draft.name);
      case _ListAction.delete:
        await _confirmDelete(context, actions, list);
      case _ListAction.moveUp:
        await actions.reorder(_moved(list, by: -1));
      case _ListAction.moveDown:
        await actions.reorder(_moved(list, by: 1));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ListActions actions,
    WordList list,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppL10n.of(context);
        return AlertDialog(
          title: Text(l10n.deleteListTitle),
          // Says plainly that the words survive. Deleting a deck and deleting
          // a vocabulary look identical from the outside (F-042).
          content: Text(l10n.deleteListBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteListAction),
            ),
          ],
        );
      },
    );
    if (confirmed ?? false) await actions.delete(list.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = context.metrics;

    // ReorderableGridView is not in Flutter, and RULES §18 prefers the
    // platform or a short helper over a package for one small job. The drag is
    // therefore the *fast* path over the same `reorder` call the Move up /
    // Move down items make - exactly the shape M3 settled on for the IPA
    // editor's selection (`context.md` §4).
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        metrics.spaceLg,
        metrics.spaceLg,
        metrics.spaceLg,
        // Room for the FAB not to cover the last card.
        metrics.spaceXxl * 2,
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        // Extent rather than a fixed column count: two columns on a phone,
        // more on a foldable, with no breakpoint to maintain.
        maxCrossAxisExtent: 220,
        mainAxisSpacing: metrics.spaceMd,
        crossAxisSpacing: metrics.spaceMd,
        childAspectRatio: 1.1,
      ),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final summary = lists[index];
        return ListCard(
          key: ValueKey<String>(summary.list.id),
          summary: summary,
          onTap: () => context.push(Routes.listDetailOf(summary.list.id)),
          onActions: () => unawaited(_actions(context, ref, summary.list)),
        );
      },
    );
  }
}

enum _ListAction { edit, delete, moveUp, moveDown }
