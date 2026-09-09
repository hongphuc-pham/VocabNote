# Migration tests

**These are blocking.** `docs/RULES.md` §29 and §9: a schema change without a
migration test is rejected, and CI fails the build rather than merging it.

The reason is the one promise this app cannot break — installing a new version
adopts the user's existing database in place. There is no backend to restore
from, so a wiped database is a permanently lost user.

## What is here

| File | Purpose |
|---|---|
| `generated/` | Schema helpers, generated from `drift_schemas/`. **Committed.** One `schema_vN.dart` per released version, with data classes and companions so a test can write rows exactly as version *N* wrote them. |
| `schema_snapshot_test.dart` | Runs today, at v1: the committed snapshot still matches the code, a fresh database validates, and the snapshot covers every table, index and trigger. |
| `vN_to_vN1_test.dart` | One per migration. None yet — v1 is the first schema. |

## Was this ever actually exercised?

Yes. At M1 the whole pipeline was proven end to end with a throwaway
`words.synonyms` column: schema bumped to 2, snapshot exported, steps and
helpers generated, and a test that seeded a **real v1 database** with a word, a
note, a highlight, a list, a membership and a study card, migrated it, and
asserted every field of every row survived — including that the new nullable
column came through as `NULL` rather than a default.

It passed, then the column was reverted. The harness stayed, which is why the
first real migration starts from working infrastructure.

## Adding v2 (or v3, or v9)

1. **Change the schema additively.** New columns are nullable or have a
   non-null DEFAULT. Never drop or rename a column that has ever shipped —
   mark it deprecated in a comment and stop writing to it
   (`docs/DATABASE.md` §3.2, §3.3).

2. **Bump `schemaVersion` by exactly 1** in `lib/data/db/app_database.dart`.
   Never reuse a number.

3. **Export the snapshot and regenerate**, from `app/`:

   ```bash
   dart run build_runner build
   dart run drift_dev schema dump  lib/data/db/app_database.dart ../drift_schemas/
   dart run drift_dev schema steps ../drift_schemas/ lib/data/db/schema_versions.dart
   dart run drift_dev schema generate --data-classes --companions \
       ../drift_schemas/ test/migration/generated/
   ```

   `drift_schemas/` and `lib/data/db/schema_versions.dart` are **committed**.

4. **Write the step.** `stepByStep()` in `app_database.dart` now requires a
   `from1To2:` callback; fill it in:

   ```dart
   onUpgrade: stepByStep(
     from1To2: (m, schema) async {
       await m.addColumn(schema.words, schema.words.synonyms);
     },
   ),
   ```

   Backfills are guarded — `UPDATE … WHERE new_col IS NULL`, never a blanket
   rewrite (§3.9). If the step touches `words` or `word_notes`, call
   `rebuildFtsIndex()` at the end: `words_fts` is derived and is meant to be
   rebuilt rather than patched.

5. **Write the tests.** Two are required (§3.5):
   - `v1_to_v2_test.dart` — seed a v1 database with one of everything, migrate,
     assert every field survives;
   - `v1_to_vN_test.dart` — the same from v1 straight to the newest version,
     because a user who skipped five releases must upgrade cleanly.

   Both end with `verifier.migrateAndValidate(db, N)`, which is drift's full
   schema check.

   The shape:

   ```dart
   final schema = await verifier.schemaAt(1);

   final oldDb = v1.DatabaseAtV1(schema.newConnection());
   await oldDb.into(oldDb.words).insert(v1.WordsCompanion.insert(...));
   await oldDb.close();

   final db = AppDatabase(schema.newConnection());
   await verifier.migrateAndValidate(db, 2);

   expect((await db.wordsDao.getById(id))!.headword, 'cough');
   ```

   Two gotchas worth knowing before you hit them:
   - the generated `schema_vN.dart` types booleans as **`int`**, so write
     `Value(1)`, not `Value(true)` — which is honest, since that is what SQLite
     holds;
   - seed and migrate on **separate connections** from the same
     `schema.newConnection()`, never one database instance reused.

6. **Update the tripwire** in `schema_snapshot_test.dart` — the test that
   asserts `schemaVersion == 1` exists precisely so that step 2 cannot be done
   without reading this file.

## What must never appear in a migration

CI greps for these and fails the build (`docs/DATABASE.md` §3.8):

- `deleteDatabase`
- `dropTable` / `DROP TABLE`
- "recreate"
- `if (from != to)`

Dropping and recreating `words_fts` is the one exception, because it is a
derived index holding nothing of the user's — and it goes through
`rebuildFtsIndex()`, which the grep allows by name.
