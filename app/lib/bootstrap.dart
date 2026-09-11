import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 moved `Override` out of the main barrel file.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:vocabnote/app.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/database_opener.dart';
import 'package:vocabnote/data/db/database_provider.dart';
import 'package:vocabnote/presentation/common/recovery_screen.dart';

/// Starts the app (`docs/ARCHITECTURE.md` section 6).
///
/// The sequence, in order:
///
/// 1. `WidgetsFlutterBinding.ensureInitialized()`
/// 2. resolve the database path
/// 3. back the database up if a migration is pending
/// 4. open Drift and run the `stepByStep` migration
/// 5. on migration failure, restore the backup, keep the old schema, and show a
///    non-destructive recovery screen with *Export my data* - **never** delete
///    the database
/// 6. load settings, build the theme, `runApp`
///
/// Steps 2-5 live in [DatabaseOpener], where they can be tested against a
/// temporary directory rather than a real device.
Future<void> bootstrap() async {
  // Uncaught errors are written to a local rolling log the user can attach from
  // Settings -> Help & feedback. There is no crash reporter and never will be
  // (`docs/RULES.md` section 1), so this zone is the only safety net.
  await runZonedGuarded(() async {
    // 1. Bindings must exist before any platform channel call.
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      logUncaught(details.exception, details.stack ?? StackTrace.empty);
    };

    // 2-5.
    final opened = await DatabaseOpener().open();

    // The app version is read here rather than in a widget: it is a platform
    // channel call, and the About screen must not wait on one.
    final version = await resolveAppVersion();

    // Housekeeping, started but not awaited: the 30-day purge must not delay
    // the first frame (F-092).
    final database = opened.valueOrNull?.database;
    if (database != null) unawaited(purgeExpiredWords(database));

    // 6.
    opened.fold(
      (result) => runApp(
        ProviderScope(
          overrides: <Override>[
            appDatabaseProvider.overrideWithValue(result.database),
            // The one place data implementations are named. Everything above
            // this line depends on domain interfaces only.
            ...repositoryOverrides(result.database, appVersion: version),
          ],
          child: const VocabNoteApp(),
        ),
      ),
      (failure) {
        logUncaught(failure, StackTrace.current);
        // Deliberately not the normal app. Without a database there is nothing
        // to show, and offering a "reset" here is precisely the behaviour
        // docs/DATABASE.md section 3.8 forbids.
        runApp(RecoveryApp(failure: failure));
      },
    );
  }, logUncaught);
}

/// Records an uncaught error.
///
/// M6 replaces the debug print with the rolling on-device log behind `F-079`.
/// Nothing is ever transmitted: there is no backend to transmit to.
void logUncaught(Object error, StackTrace stackTrace) {
  assert(() {
    debugPrint('Uncaught error: $error\n$stackTrace');
    return true;
  }(), 'debugPrint always returns true');
}
