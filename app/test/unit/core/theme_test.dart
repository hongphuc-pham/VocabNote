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
      expect(theme.colorScheme.outline, AppSurfaces.outlineLight);
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
      expect(theme.colorScheme.outline, AppSurfaces.outlineDark);
    });

    test('carries the Phonetic Naturalist brand seeds', () {
      expect(AppColorSeeds.primary, const Color(0xFF4E6E34), reason: 'olive');
      expect(
        AppColorSeeds.secondary,
        const Color(0xFFD9653B),
        reason: 'terracotta',
      );
      expect(AppColorSeeds.tertiary, const Color(0xFF16A38C), reason: 'teal');
    });

    test('the restyle left the surfaces alone', () {
      // The design system's own prose keeps these near-neutral values, and its
      // frontmatter disagrees with it. Asserting the literals means a later
      // "tidy-up" toward the frontmatter has to be a deliberate edit here.
      expect(AppSurfaces.surfaceLight, const Color(0xFFFBFAFF));
      expect(AppSurfaces.surfaceDark, const Color(0xFF121318));
      expect(AppSurfaces.surfaceContainerLight, const Color(0xFFF1F0F7));
      expect(AppSurfaces.surfaceContainerDark, const Color(0xFF1D1E24));
    });

    test('tones each brand hue rather than using it as a role directly', () {
      // A raw brand hex in `secondary` gets an `onSecondary` computed from a
      // different palette, which is how white-on-#FF8A5B shipped at 2.32:1.
      // Each hue now brings its own tonal palette; see theme_contrast_test.
      for (final theme in <ThemeData>[AppTheme.light(), AppTheme.dark()]) {
        expect(theme.colorScheme.secondary, isNot(AppColorSeeds.secondary));
        expect(theme.colorScheme.tertiary, isNot(AppColorSeeds.tertiary));
      }
      // ...and the tone comes from the right hue, not from the primary palette.
      expect(
        AppTheme.light().colorScheme.secondary,
        ColorScheme.fromSeed(seedColor: AppColorSeeds.secondary).primary,
      );
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

    test('always ships the brand, with no device accent to displace it', () {
      // Material You used to replace the primary seed outright, which meant
      // most Android 12+ users never saw the app's own identity. The theme now
      // takes no device input at all, so the brand is what renders.
      expect(
        AppTheme.light().colorScheme.primary,
        ColorScheme.fromSeed(seedColor: AppColorSeeds.primary).primary,
      );
      expect(
        AppTheme.dark().colorScheme.primary,
        ColorScheme.fromSeed(
          seedColor: AppColorSeeds.primary,
          brightness: Brightness.dark,
        ).primary,
      );
    });

    test('gives the app one answer to "this one is selected"', () {
      // Material defaults a selected FilterChip and the navigation indicator to
      // secondaryContainer, which put a terracotta selection next to an olive
      // FAB. Found by looking at it on a device, not by a test.
      for (final theme in <ThemeData>[AppTheme.light(), AppTheme.dark()]) {
        final container = theme.colorScheme.primaryContainer;
        expect(theme.chipTheme.selectedColor, container);
        expect(theme.navigationBarTheme.indicatorColor, container);
      }
    });

    test('the selected navigation icon is legible on the indicator', () {
      for (final theme in <ThemeData>[AppTheme.light(), AppTheme.dark()]) {
        final icons = theme.navigationBarTheme.iconTheme!;
        expect(
          icons.resolve(<WidgetState>{WidgetState.selected})?.color,
          theme.colorScheme.onPrimaryContainer,
        );
        expect(
          icons.resolve(<WidgetState>{})?.color,
          theme.colorScheme.onSurfaceVariant,
        );
      }
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
