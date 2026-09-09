/// The IPA highlight palette (`docs/UI-UX.md` §2).
///
/// Five colours, chosen to stay distinguishable under the common colour-vision
/// deficiencies, and used for nothing else in the app.
///
/// **Rendering rule.** A highlight is a tinted background plus a 2px underline
/// in the line colour — never coloured glyphs. The text keeps its normal
/// on-surface colour, so contrast stays AA in both themes and a colourblind
/// user still sees the underline.
library;

import 'package:flutter/material.dart';
import 'package:vocabnote/domain/value_objects/ipa_color_token.dart';

/// The fill and line colours for one highlight token.
@immutable
class IpaHighlightColors {
  /// Creates a fill/line pair.
  const new({required this.fill, required this.line});

  /// The tinted background drawn behind the run of symbols.
  final Color fill;

  /// The 2px underline drawn beneath the run, and the legend swatch colour.
  final Color line;
}

/// Resolves an [IpaColorToken] to the colours for the current theme.
///
/// Read it with `Theme.of(context).extension<IpaPalette>()!`, or through
/// [IpaPaletteContext.ipaPalette].
@immutable
class IpaPalette extends ThemeExtension<IpaPalette> {
  /// Creates a palette from an explicit map of every token.
  const new({
    required this.amber,
    required this.coral,
    required this.violet,
    required this.teal,
    required this.blue,
  });

  /// The light-theme palette.
  ///
  /// Fills carry alpha `0x29` (~16%); lines are darkened so they read against
  /// a light surface.
  static const IpaPalette light = IpaPalette(
    amber: IpaHighlightColors(fill: Color(0x29F2B705), line: Color(0xFFB98400)),
    coral: IpaHighlightColors(fill: Color(0x29F2664B), line: Color(0xFFC4402A)),
    violet: IpaHighlightColors(
      fill: Color(0x298A6BF2),
      line: Color(0xFF5B41C4),
    ),
    teal: IpaHighlightColors(fill: Color(0x2916A38C), line: Color(0xFF0C7565)),
    blue: IpaHighlightColors(fill: Color(0x293E8BF2), line: Color(0xFF1E63C4)),
  );

  /// The dark-theme palette.
  ///
  /// Fills carry alpha `0x3D` (~24%) because a dark surface swallows a lighter
  /// tint; lines are lightened for the same reason.
  static const IpaPalette dark = IpaPalette(
    amber: IpaHighlightColors(fill: Color(0x3DF2B705), line: Color(0xFFF2C55C)),
    coral: IpaHighlightColors(fill: Color(0x3DF2664B), line: Color(0xFFFF9377)),
    violet: IpaHighlightColors(
      fill: Color(0x3D8A6BF2),
      line: Color(0xFFB8A2FF),
    ),
    teal: IpaHighlightColors(fill: Color(0x3D16A38C), line: Color(0xFF5DD6C0)),
    blue: IpaHighlightColors(fill: Color(0x3D3E8BF2), line: Color(0xFF84B8FF)),
  );

  /// Colours for [IpaColorToken.amber].
  final IpaHighlightColors amber;

  /// Colours for [IpaColorToken.coral].
  final IpaHighlightColors coral;

  /// Colours for [IpaColorToken.violet].
  final IpaHighlightColors violet;

  /// Colours for [IpaColorToken.teal].
  final IpaHighlightColors teal;

  /// Colours for [IpaColorToken.blue].
  final IpaHighlightColors blue;

  /// The thickness of a highlight's underline, in logical pixels.
  static const double underlineThickness = 2;

  /// Looks up the colours for [token].
  IpaHighlightColors resolve(IpaColorToken token) => switch (token) {
    IpaColorToken.amber => amber,
    IpaColorToken.coral => coral,
    IpaColorToken.violet => violet,
    IpaColorToken.teal => teal,
    IpaColorToken.blue => blue,
  };

  @override
  IpaPalette copyWith({
    IpaHighlightColors? amber,
    IpaHighlightColors? coral,
    IpaHighlightColors? violet,
    IpaHighlightColors? teal,
    IpaHighlightColors? blue,
  }) {
    return IpaPalette(
      amber: amber ?? this.amber,
      coral: coral ?? this.coral,
      violet: violet ?? this.violet,
      teal: teal ?? this.teal,
      blue: blue ?? this.blue,
    );
  }

  @override
  IpaPalette lerp(covariant IpaPalette? other, double t) {
    if (other == null) return this;
    IpaHighlightColors mix(IpaHighlightColors a, IpaHighlightColors b) {
      return IpaHighlightColors(
        fill: Color.lerp(a.fill, b.fill, t)!,
        line: Color.lerp(a.line, b.line, t)!,
      );
    }

    return IpaPalette(
      amber: mix(amber, other.amber),
      coral: mix(coral, other.coral),
      violet: mix(violet, other.violet),
      teal: mix(teal, other.teal),
      blue: mix(blue, other.blue),
    );
  }
}

/// Convenience access to the [IpaPalette] for the current theme.
extension IpaPaletteContext on BuildContext {
  /// The IPA highlight palette registered on the ambient theme.
  ///
  /// Falls back to [IpaPalette.light] so a widget rendered outside the app's
  /// theme (a bare `MaterialApp` in a test, say) still paints something sane
  /// instead of throwing.
  IpaPalette get ipaPalette =>
      Theme.of(this).extension<IpaPalette>() ?? IpaPalette.light;
}
