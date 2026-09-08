/// The five IPA highlight colours, by name.
///
/// `docs/DATABASE.md` stores `ipa_highlights.color_token` as the **token name**,
/// never a hex value, so a theme change repaints every existing highlight
/// instead of stranding users with last year's palette.
///
/// This lives in `domain/` because it is persisted data. The colours it maps to
/// live in `core/theme/ipa_palette.dart`, which is the only place that knows
/// what "amber" looks like.
///
/// Adding a token is an additive schema change: old rows keep their names.
enum IpaColorToken {
  /// Warm yellow.
  amber,

  /// Warm red.
  coral,

  /// Purple.
  violet,

  /// Blue-green.
  teal,

  /// Blue.
  blue;

  /// The value written to `ipa_highlights.color_token`.
  String get storageValue => name;

  /// Parses a value read back from the database.
  ///
  /// Returns `null` for an unrecognised token rather than throwing: a database
  /// written by a newer version of the app may contain a colour this build has
  /// never heard of, and a highlight we cannot paint must not crash the screen
  /// that shows it. Callers fall back to [IpaColorToken.amber].
  static IpaColorToken? tryParse(String value) {
    for (final token in IpaColorToken.values) {
      if (token.name == value) return token;
    }
    return null;
  }
}
