import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabnote/data/db/app_database.dart';

import 'generated/schema.dart';

/// The migration harness, standing guard at v1.
///
/// There is no `vN -> vN+1` test yet because there is only one schema version.
/// What *can* be verified today, and is:
///
/// * the committed snapshot in `drift_schemas/` still matches the schema the
///   generated code produces - so a table changed without re-exporting fails
///   CI rather than shipping;
/// * a freshly created database passes drift's full schema validation;
/// * the harness itself compiles and runs, so the first real migration starts
///   from working infrastructure rather than a cold start.
///
/// `README.md` in this folder explains how to add the v1 -> v2 test. The
/// pipeline these tests depend on was proven end to end at M1 with a throwaway
/// `words.synonyms` column, which was then reverted.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('the committed schema snapshot matches the current schema', () async {
    // The check `docs/RULES.md` §27 is really about: generated artefacts are
    // committed, so a stale one is a bug. If this fails, someone changed a
    // table and did not run `drift_dev schema dump`.
    final db = AppDatabase(await verifier.startAt(1));
    await verifier.migrateAndValidate(db, 1);
    await db.close();
  });

  test('a fresh database validates against the generated schema', () async {
    final db = AppDatabase.memory();
    await db.customSelect('SELECT 1').get();
    // The full check `docs/DATABASE.md` §4 wants in `beforeOpen`. It lives in
    // `drift_dev`, a dev dependency, so it runs here rather than shipping the
    // Dart analyzer inside the app; `AppDatabase` does a cheap table-presence
    // check at runtime instead.
    await db.validateDatabaseSchema();
    await db.close();
  });

  test('the exported snapshot covers every table, index and trigger', () async {
    // Guards against the subtler failure: an export that succeeded but
    // silently dropped the FTS table or its triggers, which would make a
    // future migration test pass while the real app lost search.
    final schema = await verifier.schemaAt(1);
    final names = schema.rawDatabase
        .select(
          'SELECT name FROM sqlite_master '
          "WHERE type IN ('table', 'index', 'trigger') "
          "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'words_fts_%' "
          'ORDER BY name',
        )
        .map((row) => row['name'] as String)
        .toSet();

    expect(
      names,
      containsAll(<String>[
        'app_meta',
        'idx_cards_due',
        'idx_words_normalized',
        'idx_words_updated',
        'ipa_highlights',
        'notes_fts_after_delete',
        'notes_fts_after_insert',
        'notes_fts_after_update',
        'practice_answers',
        'practice_sessions',
        'settings',
        'study_cards',
        'word_list_items',
        'word_lists',
        'word_notes',
        'words',
        'words_fts',
      ]),
    );
  });

  test('schemaVersion is 1, and changing it requires a new snapshot', () {
    // A deliberate tripwire. Bumping schemaVersion without adding
    // drift_schemas/drift_schema_vN.json and a vN-1 -> vN test fails here
    // first, with a message that says what to do.
    expect(
      AppDatabase.latestSchemaVersion,
      1,
      reason:
          'If you bumped the schema version, follow the steps in '
          'test/migration/README.md: export the new snapshot, '
          'regenerate the steps and '
          'helpers, and add the migration test. Then update this expectation.',
    );
  });
}
