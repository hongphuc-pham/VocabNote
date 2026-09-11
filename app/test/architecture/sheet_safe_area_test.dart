import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A tall bottom sheet must stay below the status bar (`docs/UI-UX.md` §6).
///
/// `isScrollControlled: true` lets a sheet grow to the full screen height, and
/// without `useSafeArea: true` it grows *under* the status bar. Found on the
/// emulator at 200% text, where the quick-test sheet's title sat on the clock.
///
/// A source scan rather than a widget test per sheet: the fault only shows
/// once content is tall enough, and a new sheet would never get that test.
void main() {
  /// The argument list of every `showModalBottomSheet` call, by location.
  Map<String, String> sheetCalls() {
    final calls = <String, String>{};
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('.g.dart'));

    for (final file in files) {
      final source = file.readAsStringSync();
      for (final match in RegExp('showModalBottomSheet<').allMatches(source)) {
        // Up to the builder: the named options all come before it.
        final end = source.indexOf('builder:', match.end);
        final line = '\n'.allMatches(source.substring(0, match.start)).length;
        calls['${file.path}:${line + 1}'] = source.substring(
          match.end,
          end == -1 ? source.length : end,
        );
      }
    }
    return calls;
  }

  test('the scan finds the sheets it is meant to check', () {
    final scrollControlled = sheetCalls().values.where(
      (args) => args.contains('isScrollControlled: true'),
    );
    expect(scrollControlled.length, greaterThanOrEqualTo(4));
  });

  test('every scroll-controlled sheet also keeps to the safe area', () {
    final offenders = <String>[
      for (final MapEntry(key: where, value: args) in sheetCalls().entries)
        if (args.contains('isScrollControlled: true') &&
            !args.contains('useSafeArea: true'))
          where,
    ];
    expect(offenders, isEmpty, reason: 'add useSafeArea: true');
  });
}
