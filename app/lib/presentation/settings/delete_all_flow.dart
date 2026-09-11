import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabnote/application/backup/backup_actions.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/presentation/common/typed_confirm_dialog.dart';

/// The first step's answers.
enum _FirstStep { backupFirst, proceed }

/// Settings → *Delete all data* (`docs/UI-UX.md` §4.9, RULES §11).
///
/// Two steps, because there is no undo and no server to restore from: the
/// first says what goes and offers a backup; the second asks for a word to
/// be typed. Then the library is removed - rows and every copy on disk - and
/// the user lands on the words tab's empty state, which is exactly what the
/// app now is.
Future<void> deleteAllData(BuildContext context, WidgetRef ref) async {
  final l10n = AppL10n.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final actions = ref.read(backupActionsProvider.notifier);

  final step = await showDialog<_FirstStep>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deleteAllTitle),
      content: SingleChildScrollView(child: Text(l10n.deleteAllBody)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_FirstStep.backupFirst),
          child: Text(l10n.deleteAllBackupFirst),
        ),
        // Tonal, not destructive: this only leads to the real question.
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(_FirstStep.proceed),
          child: Text(l10n.deleteAllContinue),
        ),
      ],
    ),
  );
  if (step == null || !context.mounted) return;
  if (step == _FirstStep.backupFirst) {
    unawaited(router.push<void>(Routes.backup));
    return;
  }

  final confirmed = await showTypedConfirmation(
    context,
    title: l10n.deleteAllConfirmTitle,
    body: l10n.deleteAllConfirmBody,
    word: l10n.deleteAllConfirmWord,
    action: l10n.deleteAllConfirmAction,
  );
  if (!confirmed) return;

  final deleted = await actions.deleteEverything();
  messenger.showSnackBar(
    SnackBar(
      content: Text(deleted ? l10n.deleteAllDone : l10n.deleteAllFailed),
    ),
  );
  if (deleted) router.go(Routes.words);
}
