# Progress & handover

**Living status document.** Not a specification — the eight documents beside it are the
binding ones. This says where the work actually is, what is waiting on you, and how to pick
it up without rediscovering anything.

Last updated: **9 September 2026**, after M3.

---

## 1. Where we are

| Milestone | Status | Commit |
|---|---|---|
| M0 — Foundations | ✅ done | `7012ff8` |
| M1 — Data layer | ✅ done | `657022d` |
| M2 — Word capture | ✅ done | `b1d2712` |
| M3 — Pronunciation & highlighting | ✅ done | on `feat/m3-pronunciation` |
| **M4 — Lists & notes** | **next** | — |
| M5–M8 | not started | — |

M0–M2 sit on **`feat/m0-m2-foundations`** (renamed 9 Sep from `feat/m0-foundations`, which had
become a misnomer). M3 is being built on **`feat/m3-pronunciation`**, cut from it.

```
348 tests passing · flutter analyze clean · dart format clean
162 l10n strings · no schema change since M1
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
| 4 | ~~**Branch naming**~~ | ✅ Settled 9 Sep: renamed to `feat/m0-m2-foundations`, M3 on its own branch. |

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

**Never verified, and cannot be from Windows:**

- **iOS build.** The CI job exists but has never run.
- **CI green.** No GitHub remote yet, so the workflow has never executed. Every step was run
  locally.
- **On-device rendering.** No emulator image or device available, so Charis SIL's IPA glyphs
  have never been seen rendered. Widget tests use Ahem. M7's goldens will cover it. This now
  covers the whole of M3: the chips, the five swatches and the highlight colours have never
  been seen, and the two `<queries>` manifest fixes have never been exercised against a real
  Android.

**Deliberately deferred, by milestone:**

- ~~Word detail screen is still a placeholder~~ — built in M3.
- **The word editor screen still has no widget test, and currently cannot have one** — see §6.
  It was also never wired into the router until M3 found it.
- Look-up has not been driven end-to-end through the UI in a test.
- `recovery_screen.dart`'s *Export my data* button is wired but disabled until F-073 (M6).
- `WordSort.leastKnown` has a query and a perf test but no correctness test.

---

## 6. What M3 turned out to be

Features **F-020–F-025**, all met. Two screens (word detail, IPA highlight editor), six
controllers, one device-speech adapter behind a domain interface.

**Four things were found rather than built**, and each is worth knowing about:

1. **`WordEditorScreen` was never wired into the router.** Written in M2, it resolved to
   `PlaceholderScreen`, so *Add word* opened a placeholder and the app had no way to add a
   word through its own UI. Fixed. The new screens are tested through the real router so this
   class of gap fails a test.
2. **Two Android `<queries>` entries were missing.** Without one for `TTS_SERVICE`, package
   visibility hides the speech engine on Android 11+ and `speak()` is a **no-op with no
   error** — M3 would have looked finished and been silent on every real device. `url_launcher`
   needed the same for the Cambridge link and the mailto feedback address.
3. **A soft-deleted word rendered as a live one**, editable and speakable, because
   `watchById` deliberately still returns those rows for Undo.
4. **Autoplay lost a race with its own setting**, deciding on the first frame from the
   defaults and — since it runs once — never revisiting it.

**Deviations from the spec, both deliberate:**

- No UK/US *toggle*. `UI-UX.md` §4.3 draws two rows each with a play button, which is
  strictly better: both transcriptions stay visible for comparison. `ttsLocale` now only
  decides which accent autoplays.
- Selection in the editor is tap → tap-again → optional drag. `UI-UX.md` §4.4 specifies
  tap-and-drag, but §1 forbids hiding an action behind a gesture and a screen-reader user
  cannot pan, so the drag is the fast path over the same state rather than the only route.
  Slow replay is likewise a `CustomSemanticsAction` as well as a long-press.

**The one thing M3 could not do:** widget-test the word editor screen. `pumpAndSettle` on it
times out — something animates indefinitely on open — which is why F-023's confirm dialog has
no widget test (its logic has twelve unit tests instead, including pruning against a real
database) and, almost certainly, why that screen has been untested since M2. Undiagnosed.

## 7. Issue tracking

`bd` (beads) is installed on this machine but **not initialised in this repository** — there
is no database and no issues. It was left that way on purpose: initialising a tracker is a
repo-structure decision, and this file plus the milestone list in `PLAN.md` has been enough
so far.

If you want it, `bd init` in the repo root, and §3 and §5 of this file are the natural first
issues to import.
