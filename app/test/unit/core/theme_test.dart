import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';
import 'package:vocabnote/core/theme/tokens.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

void main() {
  group('AppTheme', () {
    test('builds a Material 3 light theme with the pinned surfaces', () {
      final theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.surface, AppSurfaces.surfaceLight);
      expect(
        theme.colorScheme.surfaceContainer,
        AppSurfaces.surfaceContainerLight,
      );
      expect(theme.colorScheme.outlineVariant, AppSurfaces.outlineVariantLight);
    });

    test('builds a dark theme with the dark surfaces', () {
      final theme = AppTheme.dark();
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.surface, AppSurfaces.surfaceDark);
      expect(
        theme.colorScheme.surfaceContainer,
        AppSurfaces.surfaceContainerDark,
      );
      expect(theme.colorScheme.outlineVariant, AppSurfaces.outlineVariantDark);
    });

    test('uses Inter for UI text', () {
      expect(AppTheme.light().textTheme.bodyLarge?.fontFamily, AppFonts.ui);
      expect(AppTheme.light().textTheme.titleLarge?.fontFamily, AppFonts.ui);
    });

    test('implements the type table sizes and weights', () {
      final text = AppTheme.light().textTheme;
      expect(text.headlineLarge?.fontSize, 40);
      expect(text.headlineLarge?.fontWeight, FontWeight.w600);
      expect(text.titleLarge?.fontSize, 22);
      expect(text.titleLarge?.fontWeight, FontWeight.w600);
      expect(text.bodyLarge?.fontSize, 16);
      expect(text.bodyLarge?.fontWeight, FontWeight.w400);
      expect(text.labelLarge?.fontSize, 13);
      expect(text.labelLarge?.fontWeight, FontWeight.w500);
    });

    test('honours a dynamic seed when the device supplies one', () {
      const deviceAccent = Color(0xFF00A65A);
      final branded = AppTheme.light();
      final dynamic0 = AppTheme.light(dynamicSeed: deviceAccent);
      expect(
        dynamic0.colorScheme.primary,
        isNot(branded.colorScheme.primary),
        reason: 'Material You must actually change the scheme',
      );
    });

    test('falls back to the brand seed when there is no dynamic colour', () {
      // Passing an explicit null is the case under test: it is what
      // DynamicColor.accent() returns off Android 12+.
      const Color? noDynamicColour = null;
      expect(
        // The redundancy is the point: null is what the platform channel
        // returns, and the theme must treat it as "use the brand seed".
        // ignore: avoid_redundant_argument_values
        AppTheme.light(dynamicSeed: noDynamicColour).colorScheme.primary,
        AppTheme.light().colorScheme.primary,
      );
      // ...and that fallback really is the brand seed, not just "some colour".
      expect(
        AppTheme.light().colorScheme.primary,
        ColorScheme.fromSeed(seedColor: AppColorSeeds.primary).primary,
      );
    });

    test('registers both theme extensions in each brightness', () {
      for (final theme in <ThemeData>[AppTheme.light(), AppTheme.dark()]) {
        expect(theme.extension<IpaPalette>(), isNotNull);
        expect(theme.extension<AppTypography>(), isNotNull);
      }
    });

    test('uses the light palette in light and the dark palette in dark', () {
      expect(
        AppTheme.light().extension<IpaPalette>()!.amber.fill,
        IpaPalette.light.amber.fill,
      );
      expect(
        AppTheme.dark().extension<IpaPalette>()!.amber.fill,
        IpaPalette.dark.amber.fill,
      );
    });
  });

  group('AppTypography', () {
    test('uses Charis SIL for both IPA roles', () {
      final type = AppTheme.light().extension<AppTypography>()!;
      expect(type.ipaLarge.fontFamily, AppFonts.ipa);
      expect(type.ipaInline.fontFamily, AppFonts.ipa);
    });

    test('matches the type table', () {
      final type = AppTheme.light().extension<AppTypography>()!;
      expect(type.displayWord.fontSize, 40);
      expect(type.displayWord.fontWeight, FontWeight.w600);
      expect(type.ipaLarge.fontSize, 30);
      expect(type.ipaLarge.letterSpacing, 0.5);
      expect(type.ipaInline.fontSize, 16);
    });

    test('lerp interpolates rather than snapping', () {
      final a = AppTypography.forColor(const Color(0xFF000000));
      final b = AppTypography.forColor(const Color(0xFFFFFFFF));
      expect(a.lerp(b, 0).displayWord.color, a.displayWord.color);
      expect(a.lerp(b, 1).displayWord.color, b.displayWord.color);
    });
  });

  group('IpaPalette', () {
    test('resolves every token in both themes', () {
      for (final palette in <IpaPalette>[IpaPalette.light, IpaPalette.dark]) {
        for (final token in IpaColorToken.values) {
          final colors = palette.resolve(token);
          expect(colors.fill, isNotNull);
          expect(colors.line, isNotNull);
        }
      }
    });

    test('fills are translucent and lines are opaque', () {
      // The rendering rule: a tinted background plus a solid 2px underline,
      // never coloured glyphs (UI-UX.md section 2).
      for (final palette in <IpaPalette>[IpaPalette.light, IpaPalette.dark]) {
        for (final token in IpaColorToken.values) {
          final colors = palette.resolve(token);
          expect(colors.fill.a, lessThan(1.0), reason: '${token.name} fill');
          expect(colors.line.a, 1.0, reason: '${token.name} line');
        }
      }
    });

    test('dark fills are more opaque than light fills', () {
      // A dark surface swallows a light tint, so the dark palette compensates.
      for (final token in IpaColorToken.values) {
        expect(
          IpaPalette.dark.resolve(token).fill.a,
          greaterThan(IpaPalette.light.resolve(token).fill.a),
          reason: token.name,
        );
      }
    });

    test('the five tokens are visually distinct within a theme', () {
      final lines = <Color>{
        for (final token in IpaColorToken.values)
          IpaPalette.light.resolve(token).line,
      };
      expect(lines, hasLength(IpaColorToken.values.length));
    });

    test('copyWith replaces only what it is given', () {
      const replacement = IpaHighlightColors(
        fill: Color(0x11223344),
        line: Color(0xFF112233),
      );
      final palette = IpaPalette.light.copyWith(amber: replacement);
      expect(palette.amber.fill, replacement.fill);
      expect(palette.coral.fill, IpaPalette.light.coral.fill);
    });

    test('lerp reaches both endpoints', () {
      expect(
        IpaPalette.light.lerp(IpaPalette.dark, 1).amber.fill,
        IpaPalette.dark.amber.fill,
      );
      expect(
        IpaPalette.light.lerp(IpaPalette.dark, 0).amber.fill,
        IpaPalette.light.amber.fill,
      );
    });

    test('lerp against null returns itself', () {
      expect(IpaPalette.light.lerp(null, 0.5), same(IpaPalette.light));
    });
  });

  group('IpaColorToken', () {
    test('stores by name, never by hex, so themes can change', () {
      expect(IpaColorToken.amber.storageValue, 'amber');
      expect(IpaColorToken.blue.storageValue, 'blue');
    });

    test('round-trips through storage', () {
      for (final token in IpaColorToken.values) {
        expect(IpaColorToken.tryParse(token.storageValue), token);
      }
    });

    test('returns null for a token written by a newer version', () {
      // A future build may add a sixth colour; this build must not crash on it.
      expect(IpaColorToken.tryParse('chartreuse'), isNull);
      expect(IpaColorToken.tryParse(''), isNull);
    });
  });

  group('AppSpacing', () {
    test('offers only the documented scale', () {
      expect(
        <double>[
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxl,
        ],
        <double>[4, 8, 12, 16, 24, 32],
      );
    });
  });

  group('AppMotion', () {
    testWidgets('returns the full duration when animations are on', (
      tester,
    ) async {
      late Duration resolved;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Builder(
            builder: (context) {
              resolved = AppMotion.durationFor(context, AppMotion.flip);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, AppMotion.flip);
    });

    testWidgets('collapses to zero when the user asked to reduce motion', (
      tester,
    ) async {
      late Duration resolved;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              resolved = AppMotion.durationFor(context, AppMotion.flip);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, Duration.zero);
    });
  });
}
