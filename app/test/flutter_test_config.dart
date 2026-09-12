import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Test-wide configuration. Applies to **every** test under `test/`, not only
/// the goldens - it sets a zone value and runs the suite inside it.
///
/// Goldens are pictures, so they fail for reasons a logic test never does: a
/// font, a theme tweak, another machine. The app develops on Windows and its
/// CI runs on Linux, and Flutter's own renderer is not pixel-identical across
/// hosts (flutter/flutter#131559), so only **CI goldens** are taken: text is
/// drawn as blocks in the test font and shadows are off, which is what makes
/// an image portable. What they hold is layout and colour - that a row keeps
/// its shape in both themes - never how a glyph renders. Real type is checked
/// on the device (`docs/PROGRESS.md` §5).
///
/// Platform goldens (real text, one set per operating system) are deliberately
/// off: they would have to be regenerated on every machine that runs the
/// suite, and would fail for everybody else.
Future<void> testExecutable(FutureOr<void> Function() testMain) {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
      // Its defaults are `obscureText: true` and `renderShadows: false`, and
      // those two are the whole reason these images travel between machines.
      // Changing either means regenerating every golden.
      ciGoldensConfig: CiGoldensConfig(),
    ),
    // `testMain` may return void; `runWithConfig` wants a future.
    run: () async {
      await testMain();
    },
  );
}
