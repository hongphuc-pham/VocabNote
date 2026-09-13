# Progress & handover

**Living status document.** Not a specification — the eight documents beside it are the
binding ones. This says where the work actually is, what is waiting on you, and how to pick
it up without rediscovering anything.

Last updated: **13 September 2026**, during M7.

---

## 1. Where we are

| Milestone | Status | Where |
|---|---|---|
| M0 — Foundations | ✅ done | PR #1 (`b81d056`) |
| M1 — Data layer | ✅ done | PR #1 |
| M2 — Word capture | ✅ done | PR #1 |
| M3 — Pronunciation & highlighting | ✅ done | PR #2 (`0b82fc7`) |
| M4 — Lists & notes | ✅ done | PR #3 (`b25f154`) |
| M5 — Practice framework + flashcards | ✅ done | PR #3 |
| M6 — Settings, guide, help, backup | ✅ done | PR #4 (`540b4f9`) |
| **M7 — Polish & accessibility** | 🔨 in progress | `feat/m7-polish` |
| M8 — Release | not started | — |

```
916 tests passing (8 perf + 6 golden run apart) · 2 integration tests on the emulator
flutter analyze clean · dart format clean · licences and migration safety clean
529 l10n strings · schema version 2 (M7 changes nothing in it)
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
- The GitHub CLI (`gh`) is **not** installed; pull requests are opened on github.com.

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
dart run build_runner build && flutter gen-l10n && git diff --exit-code --stat
                                             # generated code committed and current; any
                                             # edit to a @Riverpod class moves its hash
dart run tool/check_licences.dart            # permissive licences only
dart run tool/check_migration_safety.dart    # no destructive migration patterns
flutter test test/migration                  # blocking
flutter analyze --fatal-infos --fatal-warnings
flutter test --exclude-tags perf             # the suite
flutter test --tags perf -j 1                # the timings, alone, with nothing beside them
```

On the emulator (`Pixel_9_Pro` AVD, Android 17):

```bash
emulator -avd Pixel_9_Pro -gpu swiftshader_indirect -no-snapshot-load -no-audio
flutter test integration_test/backup_round_trip_test.dart -d emulator-5554
```

Run nothing heavy beside the emulator — it has crashed under a test run or a Gradle build.

Regenerating the offline pronunciation asset (rarely needed — it is committed):

```bash
dart run tool/build_ipa_fallback.dart
```

---

## 3. Waiting on you

Nothing blocks M7. These deserve a decision when you have a moment.

| # | Decision | Why it is here |
|---|---|---|
| 1 | **Riverpod 3, not 2** | Your stack said Riverpod 2. It is not installable alongside Drift — `riverpod_generator` 2.x needs `source_gen ^2`, `drift_dev` needs `>=3` — and 2.6.1 is 22 months unmaintained. Proceeded with 3.4.3. Recorded in `ARCHITECTURE.md` §3.1. Reversible only by dropping Drift, which breaks ADR-001. |
| 2 | **`riverpod_lint` is absent** | Impossible to install: `custom_lint` caps at `analyzer ^8`, `drift_dev` needs `>=13`. The layer rule is enforced by `test/architecture/layer_boundaries_test.dart` instead, which fails the build the same way. Not re-checked at M6. |
| 3 | ~~**Index on `study_cards(box, lapses)`**~~ | ✅ Settled in M7: the index had existed since M5's v2 migration, and cannot serve this sort anyway. The real cost was the join reading every card column and discarding it; `useColumns: false` took the sort from ~100ms to ~62ms on 5,000 words, and its gate from 150ms to 100ms. No schema change. |
| 4 | **The feedback address** | *Send feedback* stays hidden until a build sets `--dart-define=FEEDBACK_EMAIL=…` (decided 11 Sep: fill it at M8). Once shipped the address is public, so it is yours to choose. Until then Help offers GitHub Issues. |
| 5 | **Play Data safety, one reading to confirm** | A feedback email the user sends from their own mail app carries the app version and device model. Google's docs exempt user-initiated transfers the user expects, but do not name this case; `DATA-SOURCES.md` §7 records it as the reading relied on. Worth a look before the M8 store listing. |
| 6 | **Cold start misses F-092, and it is one line of `bootstrap`** | Measured and then instrumented at M7 (§5): of the 5162ms between framework init and the first frame, **`resolveAppVersion()` is 4872ms — 94%**. Opening and migrating the database is 26ms, so the migration theory first recorded here was wrong. Nothing before the first frame needs the app version (About and the feedback email want it), so the fix is to make it lazy or to start it unawaited like the 30-day purge already is. **Deliberately not fixed in M7** — you timeboxed this to instrumentation, and 4.9s for one channel call wants a real phone's number before anyone changes start-up. Recorded as **not met**. |

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
- **The backup file (M6)** — a `.vnb` is a ZIP of `manifest.json` and `data.json`, rows keyed
  by SQL column name. Merge matches on id, then headword; newer wins; it never deletes.
  Replace keeps a safety copy first. `DATABASE.md` §5.
- **Onboarding is decided before `runApp` (M6)**, never by a router redirect, and is not
  shown to someone upgrading who already has words. `FEATURES.md` F-077.
- **No Cambridge line on the licences screen (M6)** — the plan had one, but it would put
  the name outside its link, which `DATA-SOURCES.md` §3 forbids.

---

## 5. Known gaps and loose ends

**Verified on a device.** The Pixel_9_Pro emulator (Android 17) has been driven at every
milestone since M3. At M6, on 11 September: onboarding on a fresh install, export through
the real share sheet, import through the real file picker (merge and replace), *Delete all
data*, and the licences pages — and `integration_test/backup_round_trip_test.dart`
(export → wipe → import, every table deep-equal) passes there. Two privacy defects were
found doing it, both fixed — see §6.

At M7, on 13 September, an accessibility pass on the same emulator: dark theme, reduce motion
(all three animation scales at 0) and the platform accessibility tree, read with
`uiautomator dump`. Onboarding announces "Page 1 of 3" and advances with animation off; the
IPA symbol row reaches a screen reader as learner names — *Insert short a as in cat*, *Insert
uh as in about* — and not as raw glyphs, which is what F-093 and `UI-UX.md` §6 ask for. The
semantics were switched on with Android's Accessibility Menu rather than TalkBack, because
TalkBack's touch exploration changes what a scripted tap does; **so the labels are verified,
but how TalkBack actually pronounces them has still not been heard by anyone.** That, like
the iPhone, waits for M8.

**Measured on the emulator at M7 (13 September) — and F-092 is not met.** Every figure below
is from `Pixel_9_Pro` on a software GPU, with nothing else running; a real phone at M8 is
what settles them (§3). Read them with that in mind, but not as an excuse: the *split* is
what matters, and the split does not point at the machine.

| What | Figure | How |
|---|---|---|
| Cold start, release APK | median **4560ms** (5 runs, all `LaunchState: COLD`) | `am start -S -W` |
| → engine + framework init | 1.82s | `--trace-startup`, profile |
| → **after framework init** | **5.70s** | same |
| → first frame / rasterized | 7.52s / 9.47s | same |
| Scrolling 5,000 words | build median **4.3ms**, raster median **14.2ms**, worst build 252.9ms | `flutter drive --profile`, 204 frames |

Three things this says, in order of how much they matter:

1. **Cold start fails F-092's 2s budget, and the cost is ours.** Roughly three quarters of
   the 7.52s to first frame falls *after* framework init — `bootstrap` plus the first build,
   not engine start-up. The software GPU shows up in the 7.52s → 9.47s raster step and comes
   nowhere near explaining it, so a faster phone scales the number down without changing
   which part is heavy. **Instrumented on 13 September, and it is one call:**

   | `bootstrap` step | cumulative | own cost |
   |---|---|---|
   | binding, error log, licences, error handlers | 8ms | 8ms |
   | database opened **and migrated** | 34ms | **26ms** |
   | `resolveAppVersion()` | 4906ms | **4872ms** |
   | onboarding flag | 4935ms | 29ms |
   | first frame | 5162ms | 227ms (the first build) |

   `resolveAppVersion()` — a `package_info_plus` platform-channel call — is **94%** of the
   window; the same run's `timeAfterFrameworkInit` was 5162ms, matching the last mark exactly,
   so nothing is hidden between the marks. Opening and migrating the database costs 26ms, so
   the migration was never the problem. Nothing before the first frame needs the app version:
   it is wanted by the About screen and the feedback email. **Not fixed in M7** — measure it
   on a phone first (§3).
2. **The 4560ms figure is a lower bound, not the answer.** `am start -W` stops timing at the
   activity's first window draw, which is `LaunchTheme`'s launch background
   (`AndroidManifest.xml:17`), and Flutter never calls `reportFullyDrawn()`. "Starts in 4.5s"
   would be flattering it.
3. **Scrolling is fine.** Both medians fit inside a 60Hz frame even on this emulator. One
   252.9ms build frame (~15 dropped) is a start-up frame, recorded and not chased.

Caveats stated so the numbers are not over-read: profile mode carries VM-service and
`ProfileInstaller` overhead and is slower than the release build it describes, and ART was
JIT-compiling framework code cold.

**Never verified, and cannot be from Windows:**

- **iOS on a device.** An unsigned iOS build passes in CI (it did on PR #3), but the app has
  never been run on an iPhone or a simulator.
- **A physical phone.** Everything so far is the emulator, on a software GPU.

**Deliberately deferred, by milestone:**

- ~~Word detail screen is still a placeholder~~ — built in M3.
- ~~The word editor screen has no widget test~~ — made testable in M4 (`b30491d`).
- ~~*Export my data* on the recovery screen is disabled~~ — built in M6: it reads the file
  raw and read-only, so it works exactly when Drift refuses it.
- Look-up has not been driven end-to-end through the UI in a test (as of M3; not re-checked).
- `WordSort.leastKnown` has a query and a perf test but no correctness test (as of M3).
- F-078 (empty states) was not re-audited as a whole at M6; the words list's empty state
  gained *See how it works*.

---

## 6. What M6 turned out to be

Features **F-070–F-077 and F-079**: the settings screen, the *How to use* guide, Help &
feedback, backup export and import, data sources & licences, the privacy note, first-run
onboarding and a small on-device error log. Built in eight slices on one branch, each
mutation-checked.

**Four things were found rather than built:**

1. **Delete all data left the words readable in the database file.** FTS5 keeps a deleted
   row's tokens in its index segments until they merge; a copy pulled off the emulator held
   the headword four times. Now the index is rebuilt and the file `VACUUM`ed afterwards, and
   a host test checks the file's bytes.
2. **The OS plugins kept copies of a backup in the app's cache** — the share sheet's copy of
   the last export, and the picker's copy of a chosen file. Both now go with *Delete all
   data*, and the picker's as soon as it has been read.
3. **Two layouts broke at 200% text on 320dp**: a licences row whose button took the whole
   width, and the typed confirmation with the keyboard up. Found by
   `test/widget/m6_large_text_test.dart`, which walks every M6 screen, sheet and dialog.
4. **From research before the slices:** the confirmation words were all capitals, which a
   screen reader may spell out letter by letter (now lower case); and the error hook lacked
   `PlatformDispatcher.onError`, which catches what escapes the zone (added).

**Deviations from the plan, all deliberate:**

- Privacy is a sheet and a section of *Data sources & licences*, not a route of its own.
- A *Dictionary look-up* switch was added under *Your data* (`UI-UX.md` §4.9).
- Merging takes the backup's settings only when this phone is still on the defaults.

## 7. What M3 turned out to be

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

**Two bugs found by actually running it**, neither catchable by the existing tests:

1. **The IPA symbol row (F-002) never appeared.** Its `FocusNode`s had no listeners, so
   `hasFocus` changing never rebuilt anything and the row that `bottomNavigationBar` selects
   was never shown. Manual IPA entry - a 🔴 hard rule (RULES §3) - was therefore impossible
   on a real phone, because no phone keyboard has ɒ. Shipped in M2, unnoticed for two
   milestones.
2. **Tapping a symbol stole focus from the field.** The code carried a comment saying "keep
   the field focused" that nothing implemented; the `InkWell` took focus, which (once bug 1
   was fixed) dismissed the row mid-word and sent the next keystroke nowhere. Fixed with
   `canRequestFocus: false` and covered by `test/widget/ipa_keyboard_row_test.dart`.

## 8. Issue tracking

`bd` (beads) is installed on this machine but **not initialised in this repository** — there
is no database and no issues. It was left that way on purpose: initialising a tracker is a
repo-structure decision, and this file plus the milestone list in `PLAN.md` has been enough
so far.

If you want it, `bd init` in the repo root, and §3 and §5 of this file are the natural first
issues to import.
