# Progress & handover

**Living status document.** Not a specification — the eight documents beside it are the
binding ones. This says where the work actually is, what is waiting on you, and how to pick
it up without rediscovering anything.

Last updated: **9 September 2026**, after M2.

---

## 1. Where we are

| Milestone | Status | Commit |
|---|---|---|
| M0 — Foundations | ✅ done | `7012ff8` |
| M1 — Data layer | ✅ done | `657022d` |
| M2 — Word capture | ✅ done | `b1d2712` |
| **M3 — Pronunciation & highlighting** | **next** | — |
| M4–M8 | not started | — |

Everything is on branch **`feat/m0-foundations`**, which is now a misnomer — see §5.

```
259 tests passing · flutter analyze clean · dart format clean
88 source files, ~10,000 lines · 16 test files · 106 l10n strings
Android release AAB builds (57.8 MB)
```

---

## 2. Picking the work back up

### The environment (this is the part that is easy to lose)

Flutter was **not** installed on this machine and is **not** available via winget. It was
downloaded from the official archive:

- **Flutter 3.47.2 / Dart 3.13.2 (stable)** at `C:\src\flutter`
- `C:\src\flutter\bin` was added to the **user** PATH (persists across sessions)
- Web and all desktop targets are disabled (`flutter config --no-enable-web` etc.)
- Android SDK and JDK 17 were already present

If `flutter --version` fails in a new shell, prepend the path:
`$env:PATH = "C:\src\flutter\bin;$env:PATH"`

### The commands that matter

```bash
cd app
flutter pub get
dart run build_runner build     # NOT --delete-conflicting-outputs; removed in build_runner 2.16
flutter gen-l10n
flutter run
```

Before pushing — CI runs exactly these, in this order:

```bash
dart format --output=none --set-exit-if-changed .
dart run tool/check_licences.dart            # permissive licences only
dart run tool/check_migration_safety.dart    # no destructive migration patterns
flutter test test/migration                  # blocking
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

Regenerating the offline pronunciation asset (rarely needed — it is committed):

```bash
dart run tool/build_ipa_fallback.dart
```

---

## 3. Waiting on you

Nothing blocks M3, but four things deserve a decision when you have a moment.

| # | Decision | Why it is here |
|---|---|---|
| 1 | **Riverpod 3, not 2** | Your stack said Riverpod 2. It is not installable alongside Drift — `riverpod_generator` 2.x needs `source_gen ^2`, `drift_dev` needs `>=3` — and 2.6.1 is 22 months unmaintained. Proceeded with 3.4.3. Recorded in `ARCHITECTURE.md` §3.1. Reversible only by dropping Drift, which breaks ADR-001. |
| 2 | **`riverpod_lint` is absent** | Impossible to install: `custom_lint` caps at `analyzer ^8`, `drift_dev` needs `>=13`. The layer rule is enforced by `test/architecture/layer_boundaries_test.dart` instead, which fails the build the same way. Re-check each milestone. |
| 3 | **Index on `study_cards(box, lapses)`** | The least-known sort takes ~80ms on 5,000 words — the slowest query in the app by 15×. An index would fix it, but that is a schema change: version bump, migration, tests. Logged as an M7 item. |
| 4 | **Branch naming** | See §5. |

Two smaller ones, mentioned once and not worth blocking on:

- `.gitignore` excludes `.metadata` (under an "IDE" heading meant for Eclipse). Flutter's
  `.metadata` is normally committed and is used by `flutter migrate`.
- `flutter_tts` triggers a Kotlin Gradle Plugin deprecation warning that future Flutter
  versions will make fatal.

---

## 4. Decisions already made and written down

All of these are in the binding docs, not just here.

- **"All words" is a filter chip, not a seeded list** — `DATABASE.md` §2. A row would be
  renameable and deletable, which it must not be.
- **`validateDatabaseSchema()` cannot ship** — it lives in `drift_dev`, a dev dependency.
  Production does a cheap table-presence check; the real validation runs in
  `test/migration/`. Corrected in `DATABASE.md` §4.
- **Enums store documented strings, not Dart names** — `quick_test`, not `quickTest`. Rules
  out drift's `textEnum()`. Timestamps are epoch **milliseconds**, ruling out drift's
  `dateTime()` (which defaults to seconds). Both asserted by tests.
- **The DI seam** — `application/repositories.dart` declares providers against domain
  interfaces; `data/composition_root.dart` supplies implementations. `ARCHITECTURE.md` §3.3.
- **`dbus` is MPL-2.0** but reaches only Linux desktop, which VocabNote does not ship.
  Exempted by name in `tool/check_licences.dart`. `DATA-SOURCES.md` §6.
- **F-002 corrected** to 21 IPA symbols, matching `UI-UX.md` §4.2.
- **Verified API shape** — a miss is HTTP 200 with `entries: []`, the accent lives in
  `pronunciations[].tags`, and `text` arrives with slashes. `DATA-SOURCES.md` §1.

---

## 5. Known gaps and loose ends

**Branch.** Everything sits on `feat/m0-foundations`, which now carries three milestones.
`RULES.md` §36 wants one milestone-sized concern per branch. Options: leave it and open one
PR for M0–M2, or split retroactively. My suggestion is to leave it, rename the branch to
something honest like `feat/m0-m2-foundations`, and start M3 on its own branch.

**Never verified, and cannot be from Windows:**

- **iOS build.** The CI job exists but has never run.
- **CI green.** No GitHub remote yet, so the workflow has never executed. Every step was run
  locally.
- **On-device rendering.** No emulator image or device available, so Charis SIL's IPA glyphs
  have never been seen rendered. Widget tests use Ahem. M7's goldens will cover it.

**Deliberately deferred, by milestone:**

- Word detail screen is still a placeholder (M3 owns it).
- No widget test for the editor screen; its logic has 23 unit tests instead.
- Look-up has not been driven end-to-end through the UI in a test.
- `recovery_screen.dart`'s *Export my data* button is wired but disabled until F-073 (M6).
- `WordSort.leastKnown` has a query and a perf test but no correctness test.

---

## 6. What M3 will be

Features **F-020–F-025**. Restated before coding, per the working agreement.

1. **`SpeechService`** in `domain/repositories/`, implemented by `FlutterTtsService`:
   `speak(text, {locale, rate, pitch})`, `stop()`, `availableLocales()`; startup detection
   falling back `en-GB → en-US → device default`, surfaced once with a link to OS voice
   settings; rate and pitch from the settings row.
2. **Word detail screen** exactly as `UI-UX.md` §4.3 — displayWord headword, part of speech,
   UK and US IPA rows each with a play button (long-press = 0.6× slow replay), highlight
   legend, definition with attribution and *View source*, example, notes list with Add, and
   *Open in Cambridge Dictionary ↗* via `url_launcher` in external application mode.
3. **`IpaText`** — already exists from M2 in `presentation/common/`, doing the tinted
   background plus 2px underline. M3 adds the large detail-screen variant and the legend.
4. **IPA highlight editor** (`UI-UX.md` §4.4) — grapheme chips with ≥48dp targets, tap to
   select and drag to extend, selection grapheme-snapped, bottom sheet with five swatches and
   a 40-char label, overlaps allowed, session-wide undo, nothing persisted until *Done*,
   selection announced as "selected ʃ ɜː".
5. **Highlight re-validation (F-023)** — on IPA change, keep ranges that still fit and list
   the rest in a confirm dialog before dropping them. Already validated defensively on read.
6. **Tests** — grapheme ranges over multi-codepoint symbols and combining marks (28 already
   exist from M0), a widget test for select → colour → save → reopen, and one proving a
   highlight survives an IPA edit that keeps its range valid.

**Already in place for M3:** `ipa_highlights` table with its CHECK constraints and cascade,
`GraphemeRange`, `HighlightsDao.replaceForTarget` (atomic, scoped to one target),
`IpaColorToken` with the five-colour palette in both themes, and `IpaText`.

---

## 7. Issue tracking

`bd` (beads) is installed on this machine but **not initialised in this repository** — there
is no database and no issues. It was left that way on purpose: initialising a tracker is a
repo-structure decision, and this file plus the milestone list in `PLAN.md` has been enough
so far.

If you want it, `bd init` in the repo root, and §3 and §5 of this file are the natural first
issues to import.
