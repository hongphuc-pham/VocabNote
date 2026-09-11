import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/composition_root.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/app_meta.dart';

import 'db_fixtures.dart';

/// Whether a launch opens on onboarding (F-077: "never shown again after
/// completion").
///
/// Decided once in `bootstrap`, before the first frame. The case that
/// matters most is the upgrading user: every install before M6 was seeded
/// with `onboarding_completed = false`, so without the word check someone
/// with five hundred words would be greeted with "Welcome".
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  Future<bool> done() => db.metaDao.getBool(AppMetaKeys.onboardingCompleted);

  test('a fresh install opens on onboarding', () async {
    expect(await resolveOnboarding(db), isTrue);
    expect(await done(), isFalse, reason: 'deciding is not finishing');
  });

  test('once finished, never again', () async {
    await db.metaDao.setBool(AppMetaKeys.onboardingCompleted, value: true);

    expect(await resolveOnboarding(db), isFalse);
  });

  test('a user upgrading with words already is not welcomed as new', () async {
    await seedWord(db, id: 'w1', headword: 'cough');

    expect(await resolveOnboarding(db), isFalse);
    expect(
      await done(),
      isTrue,
      reason: 'marked done, so it stays skipped after they delete words',
    );
  });
}
