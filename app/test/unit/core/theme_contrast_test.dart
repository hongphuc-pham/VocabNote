import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/theme/app_theme.dart';

/// WCAG 2.1 contrast assertions for the generated colour scheme.
///
/// `AppTheme` pins five roles inside `ColorScheme.fromSeed`, which means
/// Material is no longer free to keep the tonal palette self-consistent: a
/// pinned role and its generated `on-` partner are computed from different
/// inputs. Flutter's own guidance is that pinning several roles "usually breaks
/// contrast somewhere", so this file asserts it rather than assuming it.
///
/// Thresholds are WCAG AA: 4.5:1 for body text, 3:1 for large text and for
/// non-text UI boundaries.
void main() {
  group('colour scheme contrast', () {
    for (final entry in <String, ThemeData>{
      'light': AppTheme.light(),
      'dark': AppTheme.dark(),
    }.entries) {
      final name = entry.key;
      final scheme = entry.value.colorScheme;

      test('$name: text on the two surfaces is readable', () {
        expectContrast(
          scheme.onSurface,
          scheme.surface,
          atLeast: 4.5,
          because: '$name body text on the page background',
        );
        expectContrast(
          scheme.onSurface,
          scheme.surfaceContainer,
          atLeast: 4.5,
          because: '$name body text on a card',
        );
        expectContrast(
          scheme.onSurfaceVariant,
          scheme.surface,
          atLeast: 4.5,
          because: '$name secondary text on the page background',
        );
      });

      test('$name: text on the brand colours is readable', () {
        expectContrast(
          scheme.onPrimary,
          scheme.primary,
          atLeast: 4.5,
          because: '$name label on a filled primary button',
        );
        expectContrast(
          scheme.onSecondary,
          scheme.secondary,
          atLeast: 4.5,
          because: '$name label on a filled secondary control',
        );
        expectContrast(
          scheme.onTertiary,
          scheme.tertiary,
          atLeast: 4.5,
          because: '$name label on a filled tertiary control',
        );
      });

      test('$name: boundaries and icons meet the non-text threshold', () {
        expectContrast(
          scheme.outline,
          scheme.surface,
          atLeast: 3,
          because: '$name outline against the page background',
        );
        expectContrast(
          scheme.primary,
          scheme.surface,
          atLeast: 3,
          because: '$name a primary-tinted icon on the page background',
        );
      });
    }
  });
}

/// Fails with the measured ratio, so a break says how far off it is.
void expectContrast(
  Color foreground,
  Color background, {
  required double atLeast,
  required String because,
}) {
  final ratio = contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(atLeast),
    reason:
        '$because: ${ratio.toStringAsFixed(2)}:1, needs $atLeast:1 '
        '(fg ${_hex(foreground)} on bg ${_hex(background)})',
  );
}

/// The WCAG 2.1 contrast ratio between two opaque colours.
double contrastRatio(Color foreground, Color background) {
  // computeLuminance() is Flutter's implementation of the WCAG relative
  // luminance formula, so the ratio is the only part worth writing here.
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

String _hex(Color color) {
  final value =
      (color.a * 255).round() << 24 |
      (color.r * 255).round() << 16 |
      (color.g * 255).round() << 8 |
      (color.b * 255).round();
  return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
