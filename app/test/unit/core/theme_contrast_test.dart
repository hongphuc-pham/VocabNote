import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/theme/app_theme.dart';
import 'package:vocabnote/core/theme/ipa_palette.dart';

/// Contrast, audited from the theme itself (`docs/UI-UX.md` §6, F-093).
///
/// Every colour pair the widgets actually put together, in both themes:
/// text at 4.5:1 (WCAG 1.4.3), the edges and icons that identify a control or
/// its state at 3:1 (WCAG 1.4.11). Computed from `AppTheme`, not from pixels:
/// Flutter's `textContrastGuideline` guesses a background by partitioning
/// rendered colours and is known to pass subtle failures, so it is only the
/// second net (the accessibility widget tests). A palette change that breaks a
/// pair fails here, naming the pair and the ratio.
///
/// `ColorScheme.fromSeed` is designed to keep its own pairs readable, but
/// `AppTheme` pins roles inside it (the surfaces, and the secondary and
/// tertiary families from their own seeds), so a pinned role and its partner
/// come from different inputs - Flutter's own guidance is that pinning several
/// roles "usually breaks contrast somewhere". The IPA palette is hand-picked
/// too. Nothing is taken on trust.
void main() {
  for (final (name, theme) in <(String, ThemeData)>[
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    group('$name theme', () {
      final s = theme.colorScheme;
      final ipa = theme.extension<IpaPalette>()!;

      /// Where text and controls sit: the page, cards and sheets, and the
      /// quiet boxes (previews, the error log, chips).
      final surfaces = <String, Color>{
        'surface': s.surface,
        'surfaceContainer': s.surfaceContainer,
        'surfaceContainerHighest': s.surfaceContainerHighest,
      };

      test('text is readable on everything it sits on (4.5:1)', () {
        final failures = <String>[
          for (final (fg, color) in <(String, Color)>[
            ('onSurface', s.onSurface),
            ('onSurfaceVariant', s.onSurfaceVariant),
            // Quiet text (`VnQuietText`), IPA slashes and captions.
            ('outline', s.outline),
            // Text buttons and links.
            ('primary', s.primary),
            // Validation and error lines.
            ('error', s.error),
          ])
            for (final MapEntry(key: bg, value: background) in surfaces.entries)
              ?_below(4.5, '$fg on $bg', color, background),
        ];

        expect(failures, isEmpty);
      });

      test('quiet text stays quieter than secondary text', () {
        // `outline` is pinned to read as text; it must still be the quieter
        // of the two, or "quiet" stops meaning anything.
        expect(
          _ratio(s.outline, s.surface),
          lessThan(_ratio(s.onSurfaceVariant, s.surface)),
        );
      });

      test('every on-colour is readable on its own fill (4.5:1)', () {
        final failures = <String>[
          for (final (pair, fg, bg) in <(String, Color, Color)>[
            ('onPrimary on primary', s.onPrimary, s.primary),
            ('onSecondary on secondary', s.onSecondary, s.secondary),
            ('onTertiary on tertiary', s.onTertiary, s.tertiary),
            ('onError on error', s.onError, s.error),
            (
              'onPrimaryContainer on primaryContainer',
              s.onPrimaryContainer,
              s.primaryContainer,
            ),
            (
              'onSecondaryContainer on secondaryContainer',
              s.onSecondaryContainer,
              s.secondaryContainer,
            ),
            (
              'onTertiaryContainer on tertiaryContainer',
              s.onTertiaryContainer,
              s.tertiaryContainer,
            ),
            (
              'onErrorContainer on errorContainer',
              s.onErrorContainer,
              s.errorContainer,
            ),
            // Snackbars.
            (
              'onInverseSurface on inverseSurface',
              s.onInverseSurface,
              s.inverseSurface,
            ),
          ])
            ?_below(4.5, pair, fg, bg),
        ];

        expect(failures, isEmpty);
      });

      test('edges and icons that mark a control or its state (3:1)', () {
        final failures = <String>[
          for (final (fg, color) in <(String, Color)>[
            // Text field outlines.
            ('outline', s.outline),
            // Switches, radios, sliders, checkboxes, the focus ring.
            ('primary', s.primary),
            // The favourite star, the goal ring's progress.
            ('secondary', s.secondary),
          ])
            for (final MapEntry(key: bg, value: background) in surfaces.entries)
              ?_below(3, '$fg on $bg', color, background),
        ];

        expect(failures, isEmpty);
      });

      test('highlighted IPA stays readable, and its underline visible', () {
        // A highlight is a tint behind the symbols plus an underline in the
        // line colour; the symbols keep `onSurface` (`ipa_palette.dart`).
        final failures = <String>[
          for (final (token, colors) in <(String, IpaHighlightColors)>[
            ('amber', ipa.amber),
            ('coral', ipa.coral),
            ('violet', ipa.violet),
            ('teal', ipa.teal),
            ('blue', ipa.blue),
          ])
            for (final MapEntry(key: bg, value: background) in surfaces.entries)
              ...<String?>[
                _below(
                  4.5,
                  'onSurface on $token tint over $bg',
                  s.onSurface,
                  Color.alphaBlend(colors.fill, background),
                ),
                _below(3, '$token underline on $bg', colors.line, background),
                _below(
                  3,
                  '$token underline on its tint over $bg',
                  colors.line,
                  Color.alphaBlend(colors.fill, background),
                ),
              ].nonNulls,
        ];

        expect(failures, isEmpty);
      });
    });
  }

  // Deliberately not checked, each for a stated reason (WCAG 1.4.11 exempts
  // decoration and what does not identify a control):
  //
  // - `outlineVariant`: dividers and hairlines are decoration, and a chip is
  //   identified by its label, not its border.
  // - The onboarding dots' inactive colour: the current page is the `primary`
  //   dot (checked above) and is also announced ("2 of 3").
  // - Disabled controls: WCAG 1.4.3 and 1.4.11 exempt inactive components.

  test('the ratio matches WCAG on known pairs', () {
    // Black on white is the maximum; the rest are WCAG's worked figures.
    expect(_ratio(Colors.black, Colors.white), closeTo(21, 0.001));
    expect(_ratio(Colors.white, Colors.white), closeTo(1, 0.001));
    expect(_ratio(const Color(0xFF767676), Colors.white), closeTo(4.54, 0.01));
  });
}

/// A failure line for [pair] when its contrast is below [minimum], else null.
///
/// Not rounded: WCAG says 4.499:1 does not meet 4.5:1.
String? _below(
  double minimum,
  String pair,
  Color foreground,
  Color background,
) {
  final ratio = _ratio(foreground, background);
  return ratio < minimum
      ? '$pair: ${ratio.toStringAsFixed(2)}:1, needs $minimum:1 '
            '(${_hex(foreground)} on ${_hex(background)})'
      : null;
}

String _hex(Color color) {
  final value =
      (color.a * 255).round() << 24 |
      (color.r * 255).round() << 16 |
      (color.g * 255).round() << 8 |
      (color.b * 255).round();
  return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

/// WCAG 2.2 contrast ratio, `(L1 + 0.05) / (L2 + 0.05)`.
double _ratio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// WCAG 2.2 relative luminance of an opaque sRGB colour.
///
/// Written out rather than `Color.computeLuminance()`, which still linearises
/// at WCAG 2.0's 0.03928; the current text says 0.04045. The difference changes
/// no ratio here, but this is the formula being claimed.
double _luminance(Color c) {
  double linear(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * linear(c.r) + 0.7152 * linear(c.g) + 0.0722 * linear(c.b);
}
