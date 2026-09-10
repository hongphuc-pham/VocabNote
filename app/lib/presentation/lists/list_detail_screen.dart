import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/lists/list_controller.dart';
import 'package:vocabnote/application/words/word_actions_controller.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/core/theme/app_metrics.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';
import 'package:vocabnote/presentation/common/empty_state.dart';
import 'package:vocabnote/presentation/words/word_tile.dart';

/// One list's words (`docs/UI-UX.md` §4.5, F-042).
///
/// "Detail = a filtered Words screen with **Practise this list** in the app
/// bar." It reads a family provider rather than the words tab's global query,
/// so opening a list does not disturb the filter the user left there — going
/// back finds that tab exactly as it was.
class ListDetailScreen extends ConsumerWidget {
  /// Creates the screen for [listId].
  const new({required this.listId, super.key});

  /// Which list to show.
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final list = ref.watch(listByIdProvider(listId));
    final words = ref.watch(wordsInListProvider(listId));

    return Scaffold(
      appBar: AppBar(
        title: Text(list.value?.name ?? l10n.listsTitle),
        actions: <Widget>[
          TextButton(
            // Routes with the list id. What happens on arrival is M5's; the
            // route and its argument are this milestone's.
            onPressed: () => context.push(Routes.practiceForList(listId)),
            child: Text(l10n.practiseListAction),
          ),
        ],
      ),
      body: words.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: l10n.wordsLoadFailedTitle,
          body: l10n.wordsLoadFailedBody,
        ),
        data: (entries) => entries.isEmpty
            ? EmptyState(
                icon: Icons.folder_open_outlined,
                title: l10n.listEmptyTitle,
                body: l10n.listEmptyBody,
              )
            : _Words(entries: entries),
      ),
    );
  }
}

class _Words extends ConsumerWidget {
  const new({required this.entries});

  final List<WordListEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = context.metrics;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        metrics.spaceLg,
        metrics.spaceSm,
        metrics.spaceLg,
        metrics.spaceXl,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return WordTile(
          key: ValueKey<String>(entry.word.id),
          entry: entry,
          onTap: () => context.push(Routes.wordDetailOf(entry.word.id)),
          onToggleFavourite: () => unawaited(
            ref
                .read(wordActionsProvider.notifier)
                .setFavourite(
                  entry.word.id,
                  isFavourite: !entry.word.isFavourite,
                ),
          ),
        );
      },
    );
  }
}
