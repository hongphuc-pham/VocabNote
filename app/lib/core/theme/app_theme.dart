/// Builds the Material 3 light and dark themes (`docs/UI-UX.md` §2).
///
/// Widgets never name a colour, size or duration themselves; they read them
/// from here (`docs/RULES.md` §22).
library;

import 'package:flutter/material.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';
import 'package:vocabnote/core/theme/tokens.dart';

/// The app-specific text roles from the type table in `docs/UI-UX.md` §2.
///
/// Material's own [TextTheme] roles are also populated so stock widgets look
/// right, but the three roles below have no Material equivalent — `displayWord`
/// is larger than any body role, and the two IPA roles need Charis SIL.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  /// Creates a typography set.
  const new({
    required this.displayWord,
    required this.ipaLarge,
    required this.ipaInline,
  });

  /// Builds the set, colouring each role for [onSurface].
  factory forColor(Color onSurface) {
    return AppTypography(
      displayWord: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: onSurface,
      ),
      ipaLarge: TextStyle(
        fontFamily: AppFonts.ipa,
        fontSize: 30,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: onSurface,
      ),
      ipaInline: TextStyle(
        fontFamily: AppFonts.ipa,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
    );
  }

  /// 40 / 600 — the headword on the detail screen and the flashcard front.
  final TextStyle displayWord;

  /// 30 / 400 Charis SIL, letter-spacing 0.5 — IPA on the detail screen.
  final TextStyle ipaLarge;

  /// 16 / 400 Charis SIL — IPA in a list row.
  final TextStyle ipaInline;

  @override
  AppTypography copyWith({
    TextStyle? displayWord,
    TextStyle? ipaLarge,
    TextStyle? ipaInline,
  }) {
    return AppTypography(
      displayWord: displayWord ?? this.displayWord,
      ipaLarge: ipaLarge ?? this.ipaLarge,
      ipaInline: ipaInline ?? this.ipaInline,
    );
  }

  @override
  AppTypography lerp(covariant AppTypography? other, double t) {
    if (other == null) return this;
    return AppTypography(
      displayWord: TextStyle.lerp(displayWord, other.displayWord, t)!,
      ipaLarge: TextStyle.lerp(ipaLarge, other.ipaLarge, t)!,
      ipaInline: TextStyle.lerp(ipaInline, other.ipaInline, t)!,
    );
  }
}

/// Convenience access to [AppTypography] for the current theme.
extension AppTypographyContext on BuildContext {
  /// The app-specific text roles registered on the ambient theme.
  AppTypography get type =>
      Theme.of(this).extension<AppTypography>() ??
      AppTypography.forColor(Theme.of(this).colorScheme.onSurface);
}

/// Factory for the app's two themes.
abstract final class AppTheme {
  /// The light theme.
  ///
  /// [dynamicSeed] is the device's Material You accent on Android 12+; when it
  /// is null the [AppColorSeeds.primary] brand seed is used instead.
  static ThemeData light({Color? dynamicSeed}) =>
      _build(Brightness.light, dynamicSeed);

  /// The dark theme. See [light] for [dynamicSeed].
  static ThemeData dark({Color? dynamicSeed}) =>
      _build(Brightness.dark, dynamicSeed);

  static ThemeData _build(Brightness brightness, Color? dynamicSeed) {
    final isLight = brightness == Brightness.light;

    // The brand seed is the fallback, not the override: if the device offers a
    // dynamic accent we honour it, which is the whole point of Material You.
    final scheme = ColorScheme.fromSeed(
      seedColor: dynamicSeed ?? AppColorSeeds.primary,
      brightness: brightness,
      secondary: AppColorSeeds.secondary,
      tertiary: AppColorSeeds.tertiary,
      // docs/UI-UX.md §2 pins these three, so they are not left to the
      // generated tonal palette.
      surface: isLight ? AppSurfaces.surfaceLight : AppSurfaces.surfaceDark,
      surfaceContainer: isLight
          ? AppSurfaces.surfaceContainerLight
          : AppSurfaces.surfaceContainerDark,
      outlineVariant: isLight
          ? AppSurfaces.outlineVariantLight
          : AppSurfaces.outlineVariantDark,
    );

    final textTheme = _textTheme(scheme.onSurface);

    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: AppFonts.ui,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      // Tonal surfaces only — no drop shadows except the FAB.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelLarge,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.chipBorder),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetBorder),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      extensions: <ThemeExtension<dynamic>>[
        if (isLight) IpaPalette.light else IpaPalette.dark,
        AppTypography.forColor(scheme.onSurface),
      ],
    );
  }

  /// Material's roles, filled from the type table so stock widgets inherit it.
  static TextTheme _textTheme(Color onSurface) {
    TextStyle style(double size, FontWeight weight, {double? height}) {
      return TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: onSurface,
      );
    }

    return TextTheme(
      // `displayWord` (40 / 600) — see AppTypography.displayWord.
      headlineLarge: style(40, FontWeight.w600, height: 1.1),
      headlineMedium: style(28, FontWeight.w600),
      // `titleL` (22 / 600) — app bars and section titles.
      titleLarge: style(22, FontWeight.w600),
      titleMedium: style(18, FontWeight.w500),
      titleSmall: style(15, FontWeight.w500),
      // `body` (16 / 400) — definitions and notes.
      bodyLarge: style(16, FontWeight.w400, height: 1.45),
      bodyMedium: style(15, FontWeight.w400, height: 1.45),
      bodySmall: style(14, FontWeight.w400),
      // `label` (13 / 500) — chips, captions, attribution.
      labelLarge: style(13, FontWeight.w500),
      labelMedium: style(12, FontWeight.w500),
      labelSmall: style(11, FontWeight.w500),
    );
  }
}
