# Rules

These are binding for humans and for AI assistants working in this repository. A PR that
breaks a **🔴 hard rule** is rejected without discussion.

## 1. Product rules

1. 🔴 **No backend, no account, no analytics, no ads, no tracking SDK.** Ever.
2. 🔴 **No feature may require a network connection.** Network only enriches.
3. 🔴 **Manual entry is always available** for every field the dictionary can fill.
4. 🔴 Settings always contains **How to use** and **Help & feedback**.
5. Any new screen must state its one primary action before it is built.
6. Encouraging copy only. No shame, no loss aversion, no forced notifications.

## 2. Data-safety rules (see `docs/DATABASE.md` §3)

7. 🔴 **Never destroy user data on upgrade.** No `deleteDatabase()`, no drop-and-recreate, no
   "if migration fails, start fresh". CI greps for these patterns.
8. 🔴 **Schema changes are additive.** New columns are nullable or defaulted. Shipped columns
   are never dropped or renamed.
9. 🔴 **Every schema change ships with migration tests** (`n-1 → n` and `1 → n`, with seeded
   data asserted intact) and regenerated, committed `drift_schemas/` + `schema_versions.dart`.
10. 🔴 Soft-delete user content; hard-delete only after 30 days or on explicit user action.
11. Destructive actions need either Undo (5s snackbar) or a typed confirmation, never both-less.
12. The export format version is bumped separately from the schema version, and readers ignore
    unknown fields.

## 3. Licence rules (see `docs/DATA-SOURCES.md`)

13. 🔴 **No scraping of Cambridge Dictionary** or any site without a public API and permissive
    terms. Linking out is the only allowed integration.
14. 🔴 Any bundled or displayed third-party content carries in-app attribution and its licence.
15. 🔴 Dependencies must be MIT / BSD / Apache-2.0 / OFL. No copyleft, no "non-commercial".
16. Attribution is stored **per word** (`source`, `source_attribution`), not assumed globally.

## 4. Dependency rules

17. A new package needs: a one-line justification in the PR, a permissive licence, recent
    maintenance, and no transitive network/analytics behaviour.
18. Prefer the platform or a 30-line helper over a package that does one small thing.
19. Pin with caret ranges; `flutter pub outdated` is reviewed monthly, not automated blindly.

### Dependency ledger

Every direct dependency, its licence and the one line that justifies it. Added to whenever a
package enters `pubspec.yaml`; `docs/ARCHITECTURE.md` §3.1 records what was deliberately
*not* added, and why.

| Package | Licence | Why it is here |
|---|---|---|
| `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | MIT | State and DI (ADR-002). v3 — see ARCHITECTURE §3.1. |
| `go_router` | BSD-3 | Declarative routing, deep-link ready. |
| `drift`, `drift_flutter`, `drift_dev` | MIT | Typed SQL with tested, versioned migrations (ADR-001). |
| `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`, `build_runner` | MIT / BSD-3 | Immutable models and safe JSON. |
| `flutter_tts` | MIT | Device speech; the only audio source in v1 (ADR-003). |
| `dio` | MIT | Dictionary look-up with timeouts, retry and 429 back-off. |
| `path_provider` | BSD-3 | Resolves the database and backup directories. |
| `share_plus` | BSD-3 | Hands a `.vnb` backup to the OS share sheet (F-073). |
| `file_picker` | MIT | Chooses a `.vnb` file to import (F-074). |
| `archive` | MIT | Reads and writes the `.vnb` ZIP. |
| `flutter_local_notifications`, `timezone` | BSD-3 / BSD-2 | Optional daily reminder, scheduled in the device timezone (F-066). |
| `url_launcher` | BSD-3 | Cambridge link, mailto feedback, GitHub issues — the only allowed Cambridge integration. |
| `package_info_plus`, `device_info_plus` | BSD-3 | The three diagnostics shown in the feedback preview (F-072). |
| `characters` | BSD-3 | Grapheme-cluster indexing for IPA (ADR-006). Used only by `core/extensions/grapheme.dart`. |
| `collection` | BSD-3 | Equality and sorting helpers. |
| `uuid` | MIT | TEXT UUID primary keys, so exports merge across devices. |
| `intl` | BSD-3 | Date and number formatting for l10n. |
| `meta` | BSD-3 | `@immutable` in `domain/`, which may not import Flutter. |
| `cupertino_icons` | MIT | Ships with the Flutter template; iOS-style glyphs. |
| dev: `very_good_analysis` | MIT | The lint baseline. |
| dev: `mocktail` | MIT | Mocks without codegen. |
| dev: `alchemist` | MIT | Golden tests in light and dark (RULES §32). |
| dev: `integration_test` | BSD-3 | The one end-to-end path per release (RULES §33). |

## 5. Code rules

20. 🔴 Layer direction: `presentation → application → domain ← data`. `domain` imports nothing
    but Dart and freezed. `data` never imports `presentation`.
21. 🔴 **IPA strings are only ever indexed by grapheme cluster** via `core/extensions/grapheme.dart`.
    `substring`, `codeUnitAt` and `[i]` on an IPA string are forbidden.
22. 🔴 No hard-coded colours, sizes or strings in widgets. Colours come from the theme, spacing
    from the scale, text from l10n.
23. Widgets are `const` wherever possible; no business logic inside `build`.
24. All async work returns `Result<T, AppFailure>`; no bare exceptions crossing a layer boundary.
25. Repositories expose domain entities, never Drift row classes.
26. `flutter analyze` (very_good_analysis) and `dart format` are clean — enforced in CI.
27. Generated files are committed; a PR that changes a table without regenerating is rejected.
28. Files under ~300 lines, functions under ~40. Split by responsibility, not by line count.

## 6. Testing rules

29. 🔴 Migration tests are blocking.
30. `application/` and `domain/` keep ≥90% line coverage; schedulers and the backup codec are
    100%.
31. Every bug fix starts with a failing test.
32. Golden tests cover the word tile, word detail and flashcard in light and dark.
33. One integration test per release: add → highlight → practise → export → import.
34. Practice framework: `DummyGame` must stay green — it proves a new game needs no shared-file
    edits.

## 7. Process rules

35. Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`), imperative,
    ≤72-char subject.
36. Branches: `feat/<milestone>-<slug>`, `fix/<slug>`. One milestone-sized concern per PR.
37. A PR body states: what, why, which `F-` IDs, screenshots for UI, and migration notes.
38. When a decision is made, it is written into `docs/` in the same PR. If the docs and the code
    disagree, that is a bug.

### Definition of done (per feature)
- [ ] Acceptance criteria in `FEATURES.md` all met
- [ ] Works offline
- [ ] Light + dark reviewed
- [ ] 200% text scale, ≥48dp targets, semantics labels present
- [ ] Empty, loading and error states exist
- [ ] Tests written; `flutter analyze` and `flutter test` green
- [ ] Migration tests updated if the schema moved
- [ ] Docs updated

### Release checklist
- [ ] Migration tested from the *previously published* version's schema, on a real device with
      real data — not just in CI
- [ ] Backup export/import round-trip verified on both platforms
- [ ] Licence and attribution screens re-verified against `DATA-SOURCES.md`
- [ ] Store privacy declarations match `DATA-SOURCES.md` §7 word for word
- [ ] Version and build number bumped; release notes written in plain language
- [ ] Rollback plan: staged rollout at 10% for 48 hours before going wide

## 8. Rules for AI assistants working in this repo

39. 🔴 Read `RULES.md`, `ARCHITECTURE.md` and `DATABASE.md` before writing code. Follow the
    folder tree exactly; do not invent a different structure.
40. 🔴 Never introduce a backend, an account system, analytics, or a Cambridge scraper — even if
    it seems to make a task easier.
41. 🔴 Never write a migration that drops, renames or recreates a table containing user data.
42. Ask before: adding a dependency, changing the schema, changing navigation structure, or
    deviating from `UI-UX.md` tokens.
43. Work milestone by milestone. Do not skip ahead; leave the app runnable after each step.
44. When a doc and a request conflict, say so and ask — do not silently pick one.
