/// Design tokens from `docs/UI-UX.md` §2.
///
/// Nothing in `presentation/` may hard-code a colour, a size or a duration
/// (`docs/RULES.md` §22). Every value a widget needs comes from here, from the
/// [ThemeData] built in `app_theme.dart`, or from `ipa_palette.dart`.
library;

import 'package:flutter/material.dart';

/// The colour seeds Material 3 generates both schemes from.
///
/// The same seeds are used in light and dark; Material derives the tonal
/// palettes. On Android 12+ the device's dynamic colour replaces
/// [AppColorSeeds.primary] and these become the fallback.
abstract final class AppColorSeeds {
  /// Actions and selected states.
  static const Color primary = Color(0xFF4C6FFF);

  /// Streaks and encouragement accents.
  static const Color secondary = Color(0xFFFF8A5B);

  /// "Known" and success states.
  static const Color tertiary = Color(0xFF16A38C);
}

/// Surface colours specified explicitly rather than left to the tonal palette,
/// because `docs/UI-UX.md` §2 pins them.
abstract final class AppSurfaces {
  /// Page background, light theme.
  static const Color surfaceLight = Color(0xFFFBFAFF);

  /// Page background, dark theme.
  static const Color surfaceDark = Color(0xFF121318);

  /// Cards and sheets, light theme.
  static const Color surfaceContainerLight = Color(0xFFF1F0F7);

  /// Cards and sheets, dark theme.
  static const Color surfaceContainerDark = Color(0xFF1D1E24);

  /// Hairlines, light theme.
  static const Color outlineVariantLight = Color(0xFFDDDCE5);

  /// Hairlines, dark theme.
  static const Color outlineVariantDark = Color(0xFF3A3B42);
}

/// The only spacing values allowed: 4 · 8 · 12 · 16 · 24 · 32.
///
/// If a layout seems to need something else, the layout is wrong.
abstract final class AppSpacing {
  /// 4dp — hairline gaps, icon padding.
  static const double xs = 4;

  /// 8dp — between related controls.
  static const double sm = 8;

  /// 12dp — inside chips.
  static const double md = 12;

  /// 16dp — the default screen gutter.
  static const double lg = 16;

  /// 24dp — between sections.
  static const double xl = 24;

  /// 32dp — around a screen's single primary action.
  static const double xxl = 32;
}

/// Corner radii. Filters use [pill]; everything else uses one of the three
/// fixed steps.
abstract final class AppRadii {
  /// 12dp — chips.
  static const double chip = 12;

  /// 16dp — cards.
  static const double card = 16;

  /// 28dp — bottom sheets and dialogs.
  static const double sheet = 28;

  /// Fully rounded — filter pills.
  static const double pill = 999;

  /// [chip] as a [BorderRadius].
  static const BorderRadius chipBorder = BorderRadius.all(
    Radius.circular(chip),
  );

  /// [card] as a [BorderRadius].
  static const BorderRadius cardBorder = BorderRadius.all(
    Radius.circular(card),
  );

  /// [sheet] as a [BorderRadius].
  static const BorderRadius sheetBorder = BorderRadius.all(
    Radius.circular(sheet),
  );

  /// [pill] as a [BorderRadius].
  static const BorderRadius pillBorder = BorderRadius.all(
    Radius.circular(pill),
  );
}

/// Motion timings.
///
/// Every one of these must be bypassed when `MediaQuery.disableAnimations` is
/// true (`docs/UI-UX.md` §6). Use [AppMotion.durationFor] rather than reading
/// these constants directly inside a widget.
abstract final class AppMotion {
  /// 200ms — something entering the screen.
  static const Duration enter = Duration(milliseconds: 200);

  /// 150ms — something leaving.
  static const Duration exit = Duration(milliseconds: 150);

  /// 320ms — the flashcard flip.
  static const Duration flip = Duration(milliseconds: 320);

  /// Curve for entering motion.
  static const Curve enterCurve = Curves.easeOutCubic;

  /// Curve for exiting motion.
  static const Curve exitCurve = Curves.easeOutCubic;

  /// Curve for the flashcard flip.
  static const Curve flipCurve = Curves.easeInOutCubic;

  /// Returns [duration], or [Duration.zero] when the user has asked the system
  /// to reduce motion.
  ///
  /// This is the single place that check lives, so a widget can never forget
  /// it. Golden and widget tests assert the zero case.
  static Duration durationFor(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

/// Bundled font families (`docs/DATA-SOURCES.md` §5). Both are SIL OFL 1.1.
abstract final class AppFonts {
  /// All UI text.
  static const String ui = 'Inter';

  /// IPA only. Charis SIL is bundled because system fonts render IPA symbols
  /// and combining diacritics inconsistently across Android OEMs.
  static const String ipa = 'Charis SIL';
}

/// Minimum interactive size, in logical pixels (`docs/UI-UX.md` §6).
///
/// Applies to IPA symbol chips too, which is why the highlight editor spaces
/// them generously.
const double kMinTouchTarget = 48;
