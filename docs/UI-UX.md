# UI / UX design

Brief: **simple, modern, friendly.** The user is studying, often tired, often on a bus.
Every screen answers one question and offers one obvious next action.

## 1. Design principles

1. **One primary action per screen**, always reachable with a thumb.
2. **The word is the hero.** Headword and IPA get the largest type on the detail screen;
   chrome recedes.
3. **Friendly, never gamified-aggressive.** Encourage, never shame. No red "you failed",
   no streak-loss guilt, no forced notifications.
4. **Show, don't explain.** Empty states teach the feature; the guide is a backup, not a
   prerequisite.
5. **Nothing hidden behind a gesture alone.** Every swipe has a visible equivalent.
6. **Colour is meaning, never decoration.** The five highlight colours are the only saturated
   colours on a word screen.

## 2. Design tokens

### Colour (Material 3, generated from seeds; dynamic colour honoured on Android 12+)

| Token | Light | Dark | Use |
|---|---|---|---|
| `primary` seed | `#4C6FFF` | same seed | actions, selected states |
| `secondary` seed | `#FF8A5B` | same seed | streaks, encouragement accents |
| `tertiary` seed | `#16A38C` | same seed | "known" / success |
| `surface` | `#FBFAFF` | `#121318` | page background |
| `surfaceContainer` | `#F1F0F7` | `#1D1E24` | cards, sheets |
| `outlineVariant` | `#DDDCE5` | `#3A3B42` | hairlines |

**IPA highlight palette** — five tokens, distinguishable for the common colour-vision
deficiencies, and never used for anything else:

| Token | Light fill / line | Dark fill / line |
|---|---|---|
| `amber` | `#F2B70529` / `#B98400` | `#F2B7053D` / `#F2C55C` |
| `coral` | `#F2664B29` / `#C4402A` | `#F2664B3D` / `#FF9377` |
| `violet` | `#8A6BF229` / `#5B41C4` | `#8A6BF23D` / `#B8A2FF` |
| `teal` | `#16A38C29` / `#0C7565` | `#16A38C3D` / `#5DD6C0` |
| `blue` | `#3E8BF229` / `#1E63C4` | `#3E8BF23D` / `#84B8FF` |

Rendering rule: a highlight is a **tinted background plus a 2px underline**, never coloured
glyphs. Text keeps the normal on-surface colour, so contrast stays AA in both themes and a
colourblind user still sees the underline.

### Type — Inter for UI, Charis SIL for IPA

| Role | Size / weight | Notes |
|---|---|---|
| `displayWord` | 40 / 600 | headword on detail and flashcard front |
| `ipaLarge` | 30 / 400 Charis SIL | detail screen IPA, letter-spacing 0.5 |
| `ipaInline` | 16 / 400 Charis SIL | list rows |
| `titleL` | 22 / 600 | app bars, section titles |
| `body` | 16 / 400 | definitions, notes |
| `label` | 13 / 500 | chips, captions, attribution |

All sizes scale with the OS text-size setting; layouts are tested at 200%.

### Shape, space, motion

- Radius: 12 chips · 16 cards · 28 sheets and dialogs · full pills for filters
- Spacing scale: 4 · 8 · 12 · 16 · 24 · 32 (nothing else)
- Elevation: tonal surfaces only; no drop shadows except the FAB
- Motion: 200ms `easeOutCubic` for enter, 150ms for exit; card flip 320ms `easeInOutCubic`;
  **all animation is skipped when `MediaQuery.disableAnimations` is true**

## 3. Navigation

Three bottom tabs, plus settings in the app bar. Flat and obvious — no drawer, no nested tabs.

```
[ Words ]   [ Practice ]   [ Lists ]                     ⚙ (app bar)
```

Routes: `/words`, `/words/:id`, `/words/:id/edit`, `/words/:id/ipa`, `/lists`, `/lists/:id`,
`/practice`, `/practice/:gameId/run`, `/practice/summary/:sessionId`, `/settings`,
`/settings/guide`, `/settings/help`, `/settings/backup`, `/settings/licences`, `/onboarding`.

## 4. Screens

### 4.1 Words (home)
- App bar: title *My words*, search icon (expands to an inline field), settings icon.
- Filter chips row: `All · Favourites · Due today · No IPA yet · <list names>`.
- Rows: headword (titleL) · IPA inline with the user's highlights rendered · a note-count and
  a small box-level dot on the right. 72dp tall, whole row tappable.
- FAB: `+ Add word`.
- Empty state: friendly illustration, "Your first word goes here", one-line explanation,
  **Add a word** button and a secondary **See how it works** link into the guide.

### 4.2 Add / edit word
Single scrolling form, save in the app bar (enabled once the headword is non-empty).

1. **Word** — autofocus. Under it, a quiet button: **Look up** *(optional — typing it yourself
   helps you remember)*.
2. **Look-up results** appear as a dismissible card with **per-field suggestion chips**
   (IPA UK · IPA US · part of speech · definition · example). Tapping a chip fills that field
   and nothing else. A chip never overwrites text the user has already typed without a confirm.
   The card footer carries the attribution line and a *View source* link.
3. **IPA (UK)** and **IPA (US)** — each with the IPA symbol keyboard row docked above the
   keyboard: `ˈ ˌ ː ə ɜ æ ɑ ɒ ʌ ʊ ɪ i u ʃ ʒ tʃ dʒ θ ð ŋ ɹ`. Slashes are shown as fixed affixes,
   not typed.
4. **Part of speech** (chips: noun/verb/adj/adv/other) · **Definition** · **Example**
5. **Note** — one box for a first note; more can be added from detail.
6. **Add to lists** — multi-select chips.

### 4.3 Word detail
```
┌──────────────────────────────────────┐
│  ← cough                    ★  ⋯     │
│                                      │
│   cough                              │   displayWord
│   verb                               │
│                                      │
│   UK  /kɒf/     [▶]                  │   ipaLarge, highlights rendered
│   US  /kɔːf/    [▶]                  │   long-press ▶ = 0.6× slow
│   ── amber: I say /f/ too softly ─── │   highlight legend, tappable
│                                      │
│   [ Edit IPA highlights ]            │
│                                      │
│   Definition                         │
│   To expel air from the lungs…       │
│   Wiktionary · CC BY-SA 4.0 · source │
│                                      │
│   Example                            │
│   "She coughed all night."           │
│                                      │
│   My notes                    + Add  │
│   • 3 Sep — mouth more open          │
│                                      │
│   [ Open in Cambridge Dictionary ↗ ] │
└──────────────────────────────────────┘
```

### 4.4 IPA highlight editor (the signature screen)
- The IPA string is rendered as large, individually hit-testable **grapheme chips** with
  generous spacing so a fingertip can land on one symbol.
- Tap a symbol to select it; drag to extend the run; the selection is announced for
  screen readers as "selected ʃ ɜː".
- A bottom sheet holds the five colour swatches, an optional label field (40 chars) and
  **Delete highlight**.
- Overlapping highlights are allowed; the newest wins visually and both appear in the legend.
- Undo is available for the whole session; nothing is written until *Done*.

### 4.5 Lists
Grid of coloured cards: name, word count, a due-today badge. Long-press to reorder.
Detail = a filtered Words screen with **Practise this list** in the app bar.

### 4.6 Practice hub
- A goal ring at the top: *12 of 20 today*, with encouraging copy, never a warning.
- One card per registered game. The flashcard card shows two buttons:
  **Daily review (7 due)** and **Quick test**.
- Games below `minCards` render greyed with "Add 4 words to unlock".
- Quick-test config is a **bottom sheet**: source (All / list / Favourites), size
  (5 · 10 · 20 · All — the *All* chip shows "max 30"), prompt side, autoplay toggle, **Start**.

### 4.7 Flashcard run
- Slim progress bar; `3/10` and a close button (confirms before abandoning a daily session).
- Front: the prompt side, centred, with the play button. "Tap to reveal" hint on round 1 only.
- Back: word · IPA with highlights · definition · first note.
- Grading: three wide buttons — **Again** (outline), **Good** (filled), **Easy** (tonal) —
  each showing its next interval ("2d") so the schedule is never mysterious.
- Swipe left = Again, right = Good, as an alternative to tapping, never the only way.

### 4.8 Summary
Score ring, time, words to review again, **Add missed words to a list**, **Practise again**,
**Done**. Copy is warm: "Nice work — 8 of 10." Missed words are "worth another look", not wrong.

### 4.9 Settings
```
Appearance      Theme · Text size hint
Pronunciation   Voice (UK/US) · Speed · Pitch · Autoplay on open · Test voice ▶
Practice        Daily goal · Prompt side · Daily reminder (off by default)
Your data       Export backup · Import backup · Storage used · Delete all data
Help            How to use  ▸        ← always present (F-071)
                Help & feedback ▸    ← always present (F-072)
About           Version · Data sources & licences · Privacy
```

### 4.10 How to use (guide)
Six cards, each an illustration + a sentence + a *Try it* button that deep-links to the real
screen: add a word · fill it from the dictionary · write the IPA yourself · highlight the sound
you struggle with · leave a note for yourself · practise daily. Card 3 carries the honest line
about text-to-speech being a synthesised reference.

### 4.11 Help & feedback
Searchable FAQ (12 short answers), then:
- **Send feedback** → composes an email. The pre-filled body (app version, OS version, device
  model) is **shown in a preview dialog first**, with "nothing else is included".
- **Report a problem on GitHub** → opens Issues.
- **Rate the app** → store listing.

## 5. Copy guidelines

- Second person, present tense, contractions. "You haven't added any words yet."
- No jargon in the UI: *sounds* not *phonemes*, *practice* not *SRS*, *backup* not *export dump*.
- Errors say what happened and what to do: "Couldn't reach the dictionary. You can still type
  the IPA yourself, or try again later."
- Never blame: "worth another look", not "incorrect".
- Buttons are verbs: **Add word**, **Start practice**, **Save highlight**.

## 6. Accessibility (blocking, not optional)

- Contrast ≥ 4.5:1 for text, ≥ 3:1 for UI edges, verified in both themes.
- Touch targets ≥ 48×48dp, including IPA symbol chips.
- Every icon-only button has a `Semantics` label; the flip card announces its state.
- The IPA is exposed to screen readers as spoken symbol names, not raw glyphs.
- Full keyboard/switch traversal order defined on every screen.
- Layout tested at 200% text scale and at 320dp width — no clipping, no overflow.
- `MediaQuery.disableAnimations` disables the flip and all transitions.
