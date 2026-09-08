# Plan

Solo developer, part-time. Estimates assume roughly 8–10 focused hours per week; adjust the
calendar, not the order — the sequence is chosen so that every milestone leaves the app in a
runnable, demoable state.

## 0. Scope decisions already made

| Decision | Choice | Locked because |
|---|---|---|
| Backend | none, ever | privacy + zero cost + the brief |
| Dictionary | FreeDictionaryAPI.com (Wiktionary, CC BY-SA 4.0) + CMUdict offline fallback + manual entry | licence-clean; manual entry aids memorisation |
| Cambridge | external link only | no API; scraping breaches their terms |
| Audio | device TTS in v1; self-recording and native audio deferred | offline, free, no licence burden |
| Practice | flashcards in two modes, behind a plugin framework | more games are coming in phase 2 |
| Platforms | Android + iOS from v1 | one Flutter codebase |
| Database | Drift/SQLite with tested, additive-only migrations | "new version must adopt the existing database" |

## 1. Milestones

### M0 — Foundations *(~1 week)*
Flutter project in `app/`, `very_good_analysis` lints, folder skeleton per `ARCHITECTURE.md`,
Riverpod + go_router + theme tokens + fonts, three empty tabs, CI running analyze/format/test.
**Done when:** the app builds on both platforms and CI is green on an empty test suite.

### M1 — Data layer *(~1.5 weeks)*
All Drift tables from `DATABASE.md`, DAOs, `schemaVersion = 1`, `drift_schemas/` exported and
committed, migration test harness in place (with a deliberate throwaway v1→v2 to prove the
pipeline, then reverted), `bootstrap.dart` with the pre-migration backup and recovery path.
**Done when:** migration tests run in CI and a seeded database survives a simulated upgrade.

### M2 — Word capture *(~2 weeks)* → F-001…F-008, F-040, F-041
Words list, search (FTS5), add/edit form, IPA symbol keyboard row, dictionary client with
per-field suggestion chips, offline CMUdict fallback asset + generator script, soft delete.
**Done when:** you can add 20 words by hand and by look-up, offline and online, and find them.

### M3 — Pronunciation & highlighting *(~2 weeks)* → F-020…F-025
Word detail screen, `SpeechService` + `flutter_tts` with UK/US and slow replay, the IPA
highlight editor with grapheme-safe ranges, highlight legend, re-validation on IPA edit,
Cambridge link.
**Done when:** a highlight survives an app restart and an IPA edit, and the grapheme unit tests
pass on multi-codepoint symbols.

### M4 — Lists & notes *(~1 week)* → F-042…F-045, F-003
Lists CRUD, membership, filter chips, notes per word, favourites.

### M5 — Practice framework + flashcards *(~2 weeks)* → F-060…F-067
`game_contracts.dart`, `GameRegistry`, `CardPoolProvider`s, `LeitnerScheduler`,
`PracticeSessionController`, hub, quick-test config sheet, flashcard game, summary screen,
`DummyGame` test proving a second game needs no shared-file edits.
**Done when:** daily review and a 30-cap quick test both run, and quick test provably does not
change `study_cards`.

### M6 — Settings, guide, help, backup *(~1.5 weeks)* → F-070…F-079
Settings screen, TTS controls, daily reminder, export/import `.vnb` with merge/replace,
onboarding, the six-card guide, help & feedback with the diagnostics preview, licences and
privacy screens.
**Done when:** export → wipe → import round-trips in an integration test.

### M7 — Polish & accessibility *(~1.5 weeks)* → F-090…F-097
Empty states, error states, motion, goldens in light and dark, 200% text-scale pass, semantics
labels, contrast audit, cold-start budget, 5,000-word performance check.

### M8 — Release *(~1 week)*
Store assets, privacy declarations matching `DATA-SOURCES.md` §7, signing, internal testing
track + TestFlight, then a staged production rollout.

**Realistic total: ~13–14 weeks part-time.** M2, M3 and M5 are where the real work is; M0/M1
are cheap to rush and expensive to redo, so don't.

## 2. Release scope

- **v1.0** — M0–M8 (all M-priority features, plus the S-priority ones that landed).
- **v1.1** — the C-priority items that were cut, plus whatever the first users complain about.
- **v2.0** — phase 2 below.

## 3. Phase 2 backlog (design the schema for it now, build it later)

| Item | Already prepared for |
|---|---|
| Spaced repetition SM-2 | `study_cards.ease_factor` exists; swap `ReviewScheduler` — no migration |
| Listen-and-choose game | `PracticeGame` plugin — registry line only |
| IPA match game | as above |
| Spell-from-audio game | as above |
| Record yourself and compare | `SpeechService` interface + a new `recordings` table |
| Native-speaker audio (Wikimedia Commons) | same interface; per-file licence stored |
| Vietnamese UI | l10n scaffolding from M0 |
| Widget / home-screen word of the day | reads the same DAO |
| Tags in addition to lists | additive tables |
| CSV import | backup importer generalised |

## 4. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| A migration corrupts a user's words | fatal to trust | additive-only rules, blocking migration tests, automatic pre-migration backup, non-destructive recovery screen (`DATABASE.md` §3) |
| Dictionary API disappears or rate-limits | look-up breaks | manual entry is a first-class path; CMUdict offline fallback; the client sits behind `DictionaryRepository` so a second provider is a drop-in |
| TTS voice missing on a device | no audio | detect at startup, fall back `en-GB → en-US → default`, link to OS voice settings, and say so once |
| IPA rendering breaks on some Android OEMs | the core feature looks wrong | bundle Charis SIL rather than trusting system fonts |
| Grapheme handling bugs corrupt highlights | data loss on the signature feature | `characters`-based helpers only, unit tests over multi-codepoint symbols, ranges validated on read |
| Scope creep into phase 2 games | v1 never ships | the framework exists precisely so games can wait |
