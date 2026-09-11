import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// No colour is written into widget code (`docs/RULES.md` §22, F-095).
///
/// Every colour comes from the theme, so both themes stay complete and a
/// contrast fix is made once, in `core/theme/`, where `theme_contrast_test`
/// checks it. A test rather than a lint for the same reason as
/// `layer_boundaries_test.dart`: `custom_lint` cannot be installed beside
/// `drift_dev`.
void main() {
  /// A colour made on the spot: `Color(0x…)`, `Color.fromARGB`/`fromRGBO`,
  /// or a named `Colors.` constant. `Colors.transparent` is not a colour
  /// choice - it is the absence of one - so it stays allowed.
  final colourLiteral = RegExp(
    r'\bColor\(|\bColor\.from(?:ARGB|RGBO)\(|\bColors\.(?!transparent\b)[a-z]\w*',
  );

  late List<File> sources;

  setUpAll(() {
    sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) {
          final path = f.path.replaceAll(r'\', '/');
          // The theme is where colours are allowed to live.
          return !path.startsWith('lib/core/theme/') &&
              !path.endsWith('.g.dart') &&
              !path.endsWith('.freezed.dart') &&
              !path.contains('/l10n/gen/');
        })
        .toList();
  });

  test('there is something to check', () {
    expect(sources.length, greaterThan(50));
  });

  test('no widget code names a colour of its own', () {
    final violations = <String>[
      for (final file in sources)
        for (final (index, line) in file.readAsLinesSync().indexed)
          // Comments may talk about colours; only code is held to it.
          if (!line.trimLeft().startsWith('//') && colourLiteral.hasMatch(line))
            '${file.path.replaceAll(r'\', '/')}:${index + 1}: ${line.trim()}',
    ];

    expect(
      violations,
      isEmpty,
      reason:
          'take the colour from Theme.of(context).colorScheme, or add '
          'a token in lib/core/theme/',
    );
  });
}
