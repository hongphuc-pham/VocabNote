# VocabNote — coding prompts

Two parts:

- **Part A — the master prompt.** Paste once at the start of a coding session (or save as
  `CLAUDE.md` / `.cursorrules` / a custom instruction). It sets the whole context.
- **Part B — milestone prompts.** Paste one at a time, in order, after Part A.

Do **not** commit this file to the repo — it is your working prompt, not project documentation.

---

# PART A — MASTER PROMPT

````text
You are the senior Flutter engineer building **VocabNote**, a free, offline-first
English vocabulary and pronunciation app for Android and iOS. I am the product owner
and reviewer. Work milestone by milestone; leave the app runnable after every step.

## Where the truth lives

The repository root contains design documents that are BINDING. Read them before writing
code and re-read the relevant one before each milestone:

- `README.md`             — product overview and principles
- `docs/PLAN.md`          — milestones M0–M8 and their exit criteria
- `docs/FEATURES.md`      — numbered features (F-xxx) with acceptance criteria
- `docs/ARCHITECTURE.md`  — layers, exact folder tree, packages, ADRs, bootstrap sequence
- `docs/DATABASE.md`      — full schema and the migration policy
- `docs/GAMES.md`         — the pluggable practice-game framework and its contracts
- `docs/UI-UX.md`         — design tokens, screen specs, copy and accessibility rules
- `docs/DATA-SOURCES.md`  — dictionary/audio sources and licence obligations
- `docs/RULES.md`         — binding engineering and product rules

If a document and my request conflict, STOP and tell me. Do not silently choose.
If a document is silent on something that matters, ask one focused question rather than
inventing a convention.

## Product in one paragraph

The user saves English words they are studying. For each word they store the IPA (typed by
hand or filled from an openly licensed dictionary), a definition, examples, and their own
timestamped notes. The signature feature is **highlighting runs of IPA symbols in colour with
a label**, so the user can mark exactly which sound they struggle with. They can hear the word
via device text-to-speech, group words into lists, and practise with flashcards. Everything is
local — no backend, no account, no analytics.

## Stack (do not substitute without asking)

Flutter 3.24+/Dart 3 · Riverpod 2 with codegen · go_router · **Drift over SQLite** ·
freezed + json_serializable · flutter_tts · dio · path_provider / share_plus / file_picker /
archive · flutter_local_notifications · url_launcher · package_info_plus / device_info_plus ·
characters / collection / uuid / intl. Dev: mocktail, alchemist, integration_test,
very_good_analysis.

## Hard rules — violating any of these fails the review

1. **No backend, no account, no analytics, no ads, no tracking SDK. Ever.**
2. **No feature may require the network.** Network only enriches; every core action works
   offline.
3. **Upgrading the app must never lose data.** Migrations are additive only; no
   `deleteDatabase()`, no drop-and-recreate, no "on migration error, start fresh". Every schema
   change ships with migration tests (`n-1 → n` and `1 → n`, seeded data asserted intact) plus
   regenerated and committed `drift_schemas/` and `schema_versions.dart`.
4. **Never scrape Cambridge Dictionary.** The only allowed integration is `url_launcher`
   opening `https://dictionary.cambridge.org/dictionary/english/<word>` in the external
   browser. Do not fetch, parse, cache or embed their content, and do not use their branding.
5. **Manual entry is a first-class path.** Every field the dictionary can fill must be typeable
   by hand, and a look-up suggestion never overwrites text the user has typed without a confirm.
6. **IPA strings are only ever indexed by grapheme cluster** (package `characters`, via
   `core/extensions/grapheme.dart`). `substring`, `codeUnitAt` and `[i]` on IPA are forbidden —
   they corrupt combining marks and multi-codepoint symbols.
7. **Settings always contains "How to use" and "Help & feedback".**
8. **Layer direction:** `presentation → application → domain ← data`. `domain` imports only
   Dart and freezed; `data` never imports `presentation`; repositories expose domain entities,
   never Drift row classes.
9. **No hard-coded colours, sizes or user-facing strings in widgets.** Colours from the theme,
   spacing from the 4/8/12/16/24/32 scale, text from l10n.
10. **Dependencies must be MIT / BSD / Apache-2.0 / OFL.** No copyleft, no non-commercial.
    Ask before adding any package, and justify it in one line.

## Data sources (licence-critical)

- Look-up: `GET https://freedictionaryapi.com/api/v1/entries/en/{word}` — no key, 1,000
  req/hour/IP. Content is Wiktionary via wiktextract, **CC BY-SA 4.0**: store and display
  attribution plus the source page link per word, and show a "Wiktionary · CC BY-SA 4.0"
  line under any API-derived definition.
- Offline fallback: CMUdict-derived asset `assets/data/ipa_fallback.json.gz`, generated by a
  committed script. CMU asks that its origin be acknowledged. US pronunciation only.
- **Do not use `dictionaryapi.dev`** — no published licence, Google Dictionary provenance.
- Audio is device TTS only in v1. No bundled or downloaded audio files.

## How I want you to work

- One milestone per session. Before coding, restate in 3–6 bullets what you are about to build
  and any assumption you are making. Wait for my go-ahead on anything ambiguous.
- Write the tests named in the milestone's exit criteria; do not report a milestone done while
  `flutter analyze` or `flutter test` is red.
- Prefer small, readable files (< ~300 lines) and pure functions for anything gradeable or
  schedulable.
- When you finish a milestone: list files added/changed, state which F-IDs are now met, note
  anything deliberately left for later, and give me the exact commands to run it.
- Commit style: Conventional Commits, imperative, ≤72-char subject.
- If a decision gets made mid-milestone, update the relevant file in `docs/` in the same change.

Acknowledge by listing the milestones from `docs/PLAN.md` and asking which one to start.
````

---

# PART B — MILESTONE PROMPTS

Paste these one at a time, after Part A, in order.

## M0 — Foundations

````text
Build milestone M0 (Foundations) from docs/PLAN.md.

1. Create the Flutter project in `app/` (org: com.vocabnote, platforms android + ios only).
2. Add the dependencies listed in docs/ARCHITECTURE.md §3. Nothing else.
3. Create the exact folder tree from docs/ARCHITECTURE.md §2 (empty folders get a
   `.gitkeep`). Do not invent a different structure.
4. Wire up:
   - `very_good_analysis` lints plus a custom import-boundary rule or a documented
     convention enforcing the layer direction
   - Riverpod (`ProviderScope`) and riverpod_generator
   - go_router with the routes listed in docs/UI-UX.md §3, all pointing at placeholder screens
   - `core/theme/`: tokens.dart (colour seeds, spacing scale, radii, durations),
     ipa_palette.dart (the five highlight tokens for light and dark), app_theme.dart
     (Material 3, light + dark, dynamic colour on Android 12+ with the seed as fallback)
   - bundled fonts Inter and Charis SIL under `assets/fonts/` with their OFL.txt files,
     and a `TextTheme` implementing docs/UI-UX.md §2's type table
   - l10n scaffolding (`en` ARB) — every visible string goes through it from day one
5. A bottom-nav shell with three tabs (Words, Practice, Lists) and a settings icon in the app
   bar, each showing a placeholder.
6. `core/result.dart` (`Result<T, AppFailure>`) and `core/failure.dart`.
7. `core/extensions/grapheme.dart`: grapheme-safe helpers over `characters` —
   `graphemeLength`, `graphemeSubstring(start, end)`, `graphemeAt`, `graphemeRanges` —
   with unit tests covering `/ˈtʃɜːtʃ/`, `/ˌɪntəˈneɪʃənəl/` and combining diacritics.
8. GitHub Actions workflow: `dart format --set-exit-if-changed`, `flutter analyze`,
   `flutter test`, build Android AAB and unsigned iOS, upload as artefacts.

Exit criteria: builds on both platforms, CI green, grapheme tests pass.
````

## M1 — Data layer

````text
Build milestone M1 (Data layer). docs/DATABASE.md is the specification — implement it exactly.

1. Drift tables, one file each under `lib/data/db/tables/`: words, word_notes, ipa_highlights,
   word_lists, word_list_items, study_cards, practice_sessions, practice_answers, app_meta,
   settings. Types, defaults, nullability and indexes exactly as documented. IDs are TEXT uuid,
   timestamps INTEGER epoch ms UTC.
2. `words_fts` FTS5 virtual table over headword/definition/example plus note bodies, kept in
   sync with triggers. Treat it as derived: it may be dropped and rebuilt in any migration.
3. DAOs: WordsDao, NotesDao, HighlightsDao, ListsDao, PracticeDao, SettingsDao, MetaDao.
   Streams for anything the UI watches. Repositories in `data/repositories/` implement the
   `domain/repositories/` interfaces and map rows to freezed domain entities.
4. `app_database.dart`: `schemaVersion = 1`, `MigrationStrategy` with `onCreate` (createAll +
   seed the settings row and the default "All words" behaviour), `stepByStep` `onUpgrade`,
   and `beforeOpen` that sets `PRAGMA foreign_keys = ON` and calls `validateDatabaseSchema()`
   in debug.
5. `bootstrap.dart` per docs/ARCHITECTURE.md §6, including:
   - DB path `getApplicationSupportDirectory()/vocabnote/vocabnote.sqlite`
   - copy to `vocabnote.pre-v<n>.bak` when the on-disk version is lower than `schemaVersion`
   - on migration failure: restore the backup, do NOT delete anything, show a recovery screen
     with an "Export my data" button
   - refuse to open (with a clear message) if the on-disk version is HIGHER than the binary's
6. Export the schema and set up the migration test harness:
   `dart run drift_dev schema dump  lib/data/db/app_database.dart drift_schemas/`
   `dart run drift_dev schema steps drift_schemas/ lib/data/db/schema_versions.dart`
   `dart run drift_dev schema generate drift_schemas/ test/migration/generated/`
   Commit `drift_schemas/` and `schema_versions.dart`.
7. Prove the pipeline: temporarily add a nullable `words.synonyms` column as v2, write
   `test/migration/v1_to_v2_test.dart` seeding a word + note + highlight + list + study card,
   assert every row survives with correct values, then revert to v1 but KEEP the test harness
   and a README note in `test/migration/` explaining how to add the next one.
8. Add a CI step that greps for and fails on `deleteDatabase`, `dropTable`, `recreate`,
   `DROP TABLE`, `if (from != to)` inside migration code.

Exit criteria: migration tests run in CI; a seeded database survives a simulated upgrade;
foreign keys and cascades verified by tests.
````

## M2 — Word capture

````text
Build milestone M2 (Word capture) — features F-001 to F-008, F-040, F-041.
Screens follow docs/UI-UX.md §4.1 and §4.2 exactly.

1. Words list screen: search (FTS5, debounced, ≤100ms on 5,000 rows — add a perf test with a
   generated fixture), filter chips (All / Favourites / Due today / No IPA yet / by list),
   sort (recent / A–Z / least known), 72dp rows showing headword, inline IPA with highlight
   colours rendered, and a note count. FAB "Add word". Friendly empty state.
2. Add/edit form:
   - headword autofocus, trimmed, required; duplicate `headword_normalized` shows a
     non-blocking "You already have X — open it?" banner
   - IPA UK and IPA US fields, each with a docked IPA symbol row:
     ˈ ˌ ː ə ɜ æ ɑ ɒ ʌ ʊ ɪ i u ʃ ʒ tʃ dʒ θ ð ŋ ɹ  (slashes are fixed affixes, not typed)
   - part of speech chips, definition, example, first note, add-to-lists chips
   - saving creates the `study_cards` row (box 0, due now)
3. Dictionary look-up (F-004):
   - `FreeDictionaryClient` on dio: `GET https://freedictionaryapi.com/api/v1/entries/en/{word}`,
     base URL from `--dart-define DICTIONARY_BASE_URL` with that default, 6s timeout, one
     retry, exponential back-off on 429, descriptive User-Agent, freezed DTOs
   - 24h on-disk cache keyed by normalised word
   - results render as PER-FIELD suggestion chips; tapping one fills only that field; a chip
     never overwrites non-empty user text without a confirm dialog
   - store `source`, `source_attribution` and the source page URL on accepted fields; show the
     "Wiktionary · CC BY-SA 4.0 · View source" line in the results card
   - failure is quiet and inline: "Couldn't reach the dictionary — you can still type it in";
     the form stays fully usable
4. Offline fallback (F-005): write `tool/build_ipa_fallback.dart` that downloads a pinned
   CMUdict revision, converts ARPAbet → IPA with a committed mapping table, and emits
   `assets/data/ipa_fallback.json.gz`. `OfflineIpaSource` looks up from it, marks
   `source = 'offline'`, fills US only, and is used automatically when the API is unreachable
   or returns nothing.
5. Soft delete with a 5-second Undo snackbar; a purge job for rows older than 30 days.

Exit criteria: 20 words can be added by hand and by look-up, online and in airplane mode, and
found by search over headword, definition, example and note text.
````

## M3 — Pronunciation & IPA highlighting

````text
Build milestone M3 — features F-020 to F-025. This is the signature feature; take care.

1. `SpeechService` interface in `domain/repositories/`, implemented by `FlutterTtsService`:
   - `speak(text, {locale, rate, pitch})`, `stop()`, `availableLocales()`
   - startup detection with fallback en-GB → en-US → device default, surfaced once to the user
     with a link to the OS voice settings
   - rate and pitch come from the settings row
2. Word detail screen exactly as docs/UI-UX.md §4.3: displayWord headword, part of speech,
   UK and US IPA rows each with a play button (long-press = 0.6× slow replay), the highlight
   legend, definition with attribution and View source, example, notes list with Add,
   and "Open in Cambridge Dictionary ↗" via url_launcher external application mode.
3. `IpaText` widget: renders an IPA string with its highlights as a tinted background plus a
   2px underline in the token colour — never coloured glyphs, so contrast stays AA in both
   themes. Charis SIL, letter-spacing per the type table.
4. IPA highlight editor (docs/UI-UX.md §4.4):
   - renders the IPA as individually hit-testable grapheme chips, ≥48dp targets
   - tap to select a symbol, drag to extend the run; selection is grapheme-snapped, never
     splitting a symbol or a combining mark
   - bottom sheet: five colour swatches, optional 40-char label, Delete highlight
   - overlapping highlights allowed; session-wide undo; nothing persists until Done
   - semantics: the selection announces the symbols, e.g. "selected ʃ ɜː"
5. Highlight re-validation (F-023): when the IPA string changes, keep ranges that still fit and
   list the ones that no longer do in a confirm dialog before dropping them. Also validate on
   read, defensively.
6. Tests: grapheme-range unit tests over multi-codepoint symbols and combining marks; a widget
   test for select → colour → save → reopen; a test that a highlight survives an IPA edit that
   keeps its range valid.

Exit criteria: a highlight survives app restart and an IPA edit; no grapheme corruption in any
test case; TTS works with no network.
````

## M4 — Lists, notes, favourites

````text
Build milestone M4 — features F-042 to F-045 and F-003.

1. Lists screen (docs/UI-UX.md §4.5): grid of coloured cards showing name, word count and a
   due-today badge; create/rename/recolour/reorder/delete. Deleting a list must never delete
   words — assert this in a test.
2. List detail = the Words screen filtered, with "Practise this list" in the app bar.
3. Add/remove words to lists from the word detail and via multi-select in the words list.
4. Notes: multiple timestamped notes per word, add/edit/delete, optional pin-to-top.
5. Favourite toggle on the list row and the detail screen; the Favourites filter chip.
6. Filter chips wired to real queries with correct empty states for each.
````

## M5 — Practice framework and flashcards

````text
Build milestone M5 — features F-060 to F-067. docs/GAMES.md is the specification.
The framework matters more than the game: I will add more games in phase 2.

1. `application/practice/game_contracts.dart` — implement the contracts in docs/GAMES.md §2
   verbatim: PracticeMode, PromptSide, RoundResult, GameDescriptor, GameConfig (freezed,
   serialised into `practice_sessions.config_json`, tolerant of unknown keys), PracticeCard,
   CardPoolProvider, GameRound, GameAnswer, PracticeGame<R>, ReviewScheduler, GameRegistry.
2. `card_pool_providers.dart`: DueCardPool, RandomCardPool, WeakestCardPool, NewestCardPool.
   Sources: all / list(id) / favourites. The 30-card cap for quickTest is enforced BOTH in
   `GameConfig` construction and in the query — unit-test it with a 500-word fixture.
3. `LeitnerScheduler` implementing the box/interval table in docs/GAMES.md §5, with ±10%
   jitter. Pure function, 100% test coverage, including `again` resetting to box 0 and
   incrementing lapses.
4. `PracticeSessionController` (Riverpod notifier) implementing the runner in docs/GAMES.md §3.
   It owns all persistence, progress and navigation; games own none of it. Crucially:
   scheduling is applied ONLY when `affects_scheduling` is true (daily mode). Quick test
   records answers but must not touch `study_cards` — assert this in a test.
5. `FlashcardGame` per docs/GAMES.md §6, plus its round widget per docs/UI-UX.md §4.7:
   flip animation (skipped when animations are disabled), three grading buttons each labelled
   with the interval they produce, swipe as an alternative to tapping, optional TTS autoplay
   on reveal.
6. Practice hub (docs/UI-UX.md §4.6): goal ring, one card per registered game, "Daily review
   (N due)" and "Quick test", games below `minCards` greyed with an unlock hint, and the
   "Nothing due — practise 10 at random?" path which starts a quick test.
7. Quick-test config bottom sheet: source, size 5/10/20/All (All labelled "max 30"), prompt
   side, autoplay, Start. Store the random seed in the config.
8. Session summary (docs/UI-UX.md §4.8) with warm copy and "Add missed words to a list".
9. `test/unit/practice/dummy_game_test.dart`: register a throwaway `DummyGame` and run a full
   session through the real controller. If making this pass requires editing ANY shared file
   other than the registry and l10n, the framework is wrong — fix the framework, not the test.

Exit criteria: daily review and quick test both run end to end; the 30 cap holds; quick test
provably leaves `study_cards` untouched; DummyGame passes.
````

## M6 — Settings, guide, help, backup

````text
Build milestone M6 — features F-070 to F-079.

1. Settings screen with the exact sections in docs/UI-UX.md §4.9. All values persist to the
   settings row and take effect immediately.
2. Pronunciation section: voice UK/US, speed, pitch, autoplay-on-open, and a "Test voice ▶".
3. Practice section: daily goal, prompt side, daily reminder (OFF by default;
   flutter_local_notifications; ask for permission only at the moment the user enables it;
   schedule in the device timezone).
4. Backup export (F-073): `.vnb` ZIP containing `manifest.json`
   {app_version, schema_version, export_format_version, exported_at, counts} and `data.json`
   with every table. Shared via the OS share sheet.
5. Backup import (F-074): file_picker, then Merge (default — match on `id`, then on
   `headword_normalized`; newer `updated_at` wins) or Replace (explicit confirm, automatic
   backup first). One transaction. Report added / updated / skipped. The reader must ignore
   unknown fields and default missing ones.
6. Onboarding (F-077): 3 slides then the guide; skippable; `app_meta.onboarding_completed`.
7. "How to use" guide (F-071, docs/UI-UX.md §4.10): six illustrated cards, each with a "Try it"
   deep link into the real screen. Card 3 carries the honest one-liner that text-to-speech is a
   synthesised reference, not a native speaker. Always reachable from Settings.
8. "Help & feedback" (F-072, docs/UI-UX.md §4.11): searchable FAQ (write 12 short answers),
   "Send feedback" via mailto — and the pre-filled diagnostics (app version, OS version, device
   model) MUST be shown in a preview dialog first with "nothing else is included" — plus a
   GitHub Issues link and a rate-the-app link. Always reachable from Settings.
9. "Data sources & licences" (F-075): `showLicensePage()` for packages, plus our own section
   for FreeDictionaryAPI.com / Wiktionary (CC BY-SA 4.0, linked), CMUdict, Inter and Charis SIL
   (OFL). And the plain-English privacy note (F-076) matching docs/DATA-SOURCES.md §7 word for
   word.
10. "Delete all data" with a typed confirmation and an offer to export first.

Exit criteria: an integration test does export → wipe → import → deep-equal on both platforms.
````

## M7 — Polish and accessibility

````text
Build milestone M7 — features F-090 to F-097. No new features; make what exists excellent.

1. Empty, loading and error states on every screen, with the copy style in docs/UI-UX.md §5.
2. Motion pass per docs/UI-UX.md §2, and verify everything is skipped when
   `MediaQuery.disableAnimations` is true.
3. Accessibility audit (blocking): contrast ≥4.5:1 for text and ≥3:1 for UI edges in BOTH
   themes; every icon-only button has a Semantics label; the flip card announces its state;
   IPA is exposed to screen readers as symbol names; full traversal order; layouts verified at
   200% text scale and 320dp width with no clipping.
4. Golden tests (alchemist) for the word tile, word detail and flashcard in light and dark.
5. Performance: cold start to interactive ≤2s on a mid-range Android device; search ≤100ms on
   a 5,000-word fixture; the words list scrolls at 60fps with 5,000 rows. Add the fixture
   generator and the benchmarks to the repo.
6. Run through docs/RULES.md's Definition of Done for every F-ID marked M or S and report any
   gaps as a checklist rather than quietly fixing scope.
````

## M8 — Release

````text
Build milestone M8 (Release).

1. App icons and splash for both platforms; store screenshots from the golden device sizes.
2. Store listings: short and long description, keywords. Do not imply any affiliation with
   Cambridge Dictionary or Wiktionary.
3. Privacy declarations — Play Data Safety and Apple App Privacy — matching
   docs/DATA-SOURCES.md §7 exactly. "No data collected" must be literally true; verify no
   dependency phones home (`flutter pub deps` review plus a network-log run).
4. Android: applicationId, signing via GitHub secrets, Auto Backup enabled with sensible
   `dataExtractionRules`, minSdk 26, R8 enabled with any needed keep rules.
5. iOS: bundle id, minimum iOS 13, background modes off, `NSUserTrackingUsageDescription` NOT
   present (we do not track), microphone permission NOT requested (no recording in v1).
6. Version 1.0.0+1; CI auto-increments the build number; release notes in plain language.
7. Run the release checklist in docs/RULES.md §7, including the real-device migration test from
   the previously published schema.
8. Ship to Play internal testing and TestFlight, then a 10% staged production rollout held for
   48 hours.
````

---

## Two prompts to keep handy afterwards

**Adding a new practice game (phase 2):**

````text
Add a new practice game "<name>" to VocabNote, following docs/GAMES.md §7.
It must require exactly: a new folder under application/practice/games/<name>/ with a
PracticeGame implementation and a GameDescriptor, a round widget under
presentation/practice/games/<name>/, one line in game_registry.dart, and l10n strings.
If you need to edit any other shared file, stop and tell me — that means the framework is
wrong and we fix the framework first. Include tests for buildRounds determinism under a fixed
seed, a grade() truth table, and one widget test.
````

**Any schema change:**

````text
I need to change the VocabNote schema: <describe the change>.
Follow docs/DATABASE.md §3 exactly: additive only, new columns nullable or defaulted, bump
schemaVersion by one, add the stepByStep migration, regenerate and commit drift_schemas/ and
schema_versions.dart, and add BOTH migration tests (n-1 → n and 1 → n) seeding a word, a note,
a highlight, a list membership and a study card, asserting every row survives with correct
values. Never drop, rename or recreate a table containing user data. Show me the migration and
the tests before anything else.
````
