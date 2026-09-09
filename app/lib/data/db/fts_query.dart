/// Building safe FTS5 `MATCH` expressions from whatever the user typed.
library;

/// Turns raw search input into an FTS5 `MATCH` expression, or null when
/// nothing searchable is left.
///
/// Every token is wrapped in double quotes, so `AND`, `OR`, `NOT`, `NEAR`,
/// `*`, `:`, `^` and `(` are treated as text rather than as FTS5 operators.
/// Without this, typing a lone `"` or the word `AND` into the search box is a
/// SQL error rather than a search that finds nothing - and a user should never
/// be able to break search by typing punctuation into it.
///
/// The final token gets a trailing `*` so search matches as the user types:
/// `cou` finds `cough` before the word is finished.
String? buildFtsMatchQuery(String raw) {
  final tokens = raw
      .split(RegExp(r'\s+'))
      // A double quote is the one character that could escape the quoting
      // below, so it is removed rather than escaped.
      .map((token) => token.replaceAll('"', '').trim())
      .where((token) => token.isNotEmpty)
      .toList();

  if (tokens.isEmpty) return null;

  final quoted = <String>[
    for (var i = 0; i < tokens.length; i++)
      if (i == tokens.length - 1) '"${tokens[i]}"*' else '"${tokens[i]}"',
  ];
  return quoted.join(' ');
}
