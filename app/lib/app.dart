import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/core/l10n/gen/app_localizations.dart';
import 'package:vocabnote/core/router/app_router.dart';
import 'package:vocabnote/core/theme/app_theme.dart';

/// The root widget: `MaterialApp.router` plus theme and localisation wiring.
///
/// Everything above this (database, migrations, settings) is resolved in
/// `bootstrap.dart` before the first frame, so this widget stays synchronous
/// and cheap - it is on the cold-start budget of 2s (`F-092`).
class VocabNoteApp extends ConsumerWidget {
  /// Creates the app.
  ///
  /// [dynamicSeed] is the device's Material You accent on Android 12+, read
  /// once during bootstrap; null everywhere else, and the brand seed is used.
  const new({this.dynamicSeed, super.key});

  /// The device accent colour, when the platform offers one.
  final Color? dynamicSeed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,

      // The title shown in the OS task switcher. Localised via
      // onGenerateTitle so it follows the device language.
      onGenerateTitle: (context) => AppL10n.of(context).appTitle,

      theme: AppTheme.light(dynamicSeed: dynamicSeed),
      darkTheme: AppTheme.dark(dynamicSeed: dynamicSeed),

      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,

      localeListResolutionCallback: (locales, supported) {
        // Explicit rather than implicit: an unsupported device language falls
        // back to English instead of whatever happens to sort first.
        for (final locale in locales ?? const <Locale>[]) {
          for (final candidate in supported) {
            if (candidate.languageCode == locale.languageCode) return candidate;
          }
        }
        return const Locale('en');
      },
    );
  }
}
