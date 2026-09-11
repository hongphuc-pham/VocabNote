import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/presentation/common/recovery_screen.dart';

/// The recovery screen (DATABASE §3.6, §3.8, §3.10).
///
/// Shown instead of the app when the database cannot be opened. The one
/// thing it must never do is offer to reset: there is no backend, so a wiped
/// database is a permanently lost user. It offers *Export my data*.
void main() {
  const tooNew = SchemaTooNewFailure(onDiskVersion: 99, supportedVersion: 2);

  Finder exportButton() => find.widgetWithText(FilledButton, 'Export my data');

  testWidgets('offers Export my data, and nothing that deletes', (
    tester,
  ) async {
    await tester.pumpWidget(
      RecoveryApp(failure: tooNew, onExport: () async => true),
    );

    expect(tester.widget<FilledButton>(exportButton()).onPressed, isNotNull);
    for (final dangerous in <String>['Reset', 'Delete', 'Start fresh']) {
      expect(find.textContaining(dangerous), findsNothing, reason: dangerous);
    }
  });

  testWidgets('tapping it exports', (tester) async {
    var exports = 0;
    await tester.pumpWidget(
      RecoveryApp(
        failure: tooNew,
        onExport: () async {
          exports++;
          return true;
        },
      ),
    );

    await tester.tap(exportButton());
    await tester.pumpAndSettle();

    expect(exports, 1);
  });

  testWidgets('an export that fails says so, and that nothing was touched', (
    tester,
  ) async {
    await tester.pumpWidget(
      RecoveryApp(failure: tooNew, onExport: () async => false),
    );

    await tester.tap(exportButton());
    await tester.pumpAndSettle();

    expect(
      find.text(
        "Couldn't make the export just now. Your data is still on this "
        'phone, untouched.',
      ),
      findsOneWidget,
    );
  });
}
