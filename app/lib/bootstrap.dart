import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/app.dart';
import 'package:vocabnote/core/utils/dynamic_color.dart';

/// Starts the app (`docs/ARCHITECTURE.md` section 6).
///
/// The full sequence is:
///
/// 1. `WidgetsFlutterBinding.ensureInitialized()`
/// 2. resolve the database path
/// 3. back the database up if a migration is pending
/// 4. open Drift and migrate inside a transaction
/// 5. on migration failure, restore the backup and show the recovery screen -
///    never delete anything
/// 6. load settings, build the theme, `runApp`
///
/// Steps 2-5 arrive with the data layer in M1; the numbered comments below mark
/// exactly where they go so the order cannot drift. Steps 1 and 6 are here now,
/// which is what makes the M0 app runnable.
Future<void> bootstrap() async {
  // Uncaught errors are written to a local rolling log the user can attach from
  // Settings -> Help & feedback. There is no crash reporter and never will be
  // (`docs/RULES.md` section 1), so this zone is the only safety net.
  await runZonedGuarded(() async {
    // 1. Bindings must exist before any platform channel call.
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logUncaught(details.exception, details.stack ?? StackTrace.empty);
    };

    // TODO(m1): 2. Resolve getApplicationSupportDirectory()/vocabnote/.
    // TODO(m1): 3. Copy to vocabnote.pre-v<n>.bak when a migration is due.
    // TODO(m1): 4. Open Drift; run stepByStep migration in a transaction.
    // TODO(m1): 5. On failure restore the backup and show the recovery
    //  screen with "Export my data". Never call deleteDatabase().

    // 6a. Material You accent, if the device has one. Read before the first
    // frame so the app never repaints from brand colours to device colours.
    final dynamicSeed = await DynamicColor.accent();

    // 6b.
    runApp(ProviderScope(child: VocabNoteApp(dynamicSeed: dynamicSeed)));
  }, _logUncaught);
}

/// Records an uncaught error.
///
/// M6 replaces the debug print with the rolling on-device log behind `F-079`.
/// Nothing is ever transmitted: there is no backend to transmit to.
void _logUncaught(Object error, StackTrace stackTrace) {
  assert(() {
    debugPrint('Uncaught error: $error\n$stackTrace');
    return true;
  }(), 'debugPrint always returns true');
}
