# Data sources, licences and compliance

Rule: **nothing ships in this app unless we can name its licence and satisfy it.**
Everything below was checked in September 2026; re-verify before each public release
(`docs/RULES.md` §7 release checklist).

---

## 1. Online dictionary look-up — **FreeDictionaryAPI.com**

| | |
|---|---|
| Endpoint | `GET https://freedictionaryapi.com/api/v1/entries/en/{word}` |
| Auth | none, no API key |
| Rate limit | 1,000 requests / hour / IP, resets hourly UTC; `429` when exceeded |
| Underlying data | **Wiktionary**, extracted with `wiktextract` |
| Licence | **CC BY-SA 4.0** |
| Provides | definitions, part of speech, pronunciations (IPA), examples, source page links |

### What CC BY-SA 4.0 obliges us to do
1. **Attribute.** A visible credit wherever the content is shown, plus a fuller credit in
   *Settings → Data sources & licences*, and on the store listing / landing page.
2. **Link back.** The API returns the source Wiktionary page URL — store it on the word
   (`words.source_attribution`) and expose it as a *View source* link on the word detail.
3. **Name the licence** and link to `https://creativecommons.org/licenses/by-sa/4.0/`.
4. **ShareAlike.** Applies to the *dictionary text*, not to our Dart code. We do not relicense
   or claim ownership of the text; the user's own notes and highlights remain the user's.
5. **No implied endorsement.** Do not suggest Wiktionary or FreeDictionaryAPI endorses the app.

### Implementation requirements
- Store `source = 'api'` and `source_attribution = 'Wiktionary via FreeDictionaryAPI.com — CC BY-SA 4.0'`
  plus the source URL on every field accepted from the API.
- Show a small "Wiktionary · CC BY-SA 4.0" line under any API-derived definition.
- Respect the rate limit: debounce the search box, one request per explicit *Look up* tap,
  in-memory + on-disk cache per word (24h), exponential back-off on `429`.
- Send a descriptive `User-Agent` (`VocabNote/<version> (github.com/<repo>)`) — courteous and
  expected by community APIs.
- Content the user typed themselves is `source = 'manual'` and carries **no** attribution,
  because it is theirs.

### Rejected alternative — `dictionaryapi.dev`
Popular and convenient, but its data provenance traces back to scraped **Google Dictionary**
content (Oxford-licensed) and the site publishes no licence or terms. That is exactly the risk
we were asked to avoid, so it is **not** used. Recorded here so nobody "helpfully" swaps it in.

---

## 2. Offline IPA fallback — **CMUdict**

| | |
|---|---|
| Source | `github.com/cmusphinx/cmudict` (Carnegie Mellon University, 1993–2014) |
| Licence | Unrestricted for research **and commercial** use; asks that the origin be acknowledged |
| Coverage | ~134k North-American English entries, ARPAbet phonemes |

- A build script (`tool/build_ipa_fallback.dart`) converts ARPAbet → IPA and emits
  `assets/data/ipa_fallback.json.gz`. The script, the mapping table and the source revision
  are committed so the asset is reproducible.
- Words filled from it get `source = 'offline'` and `source_attribution = 'CMU Pronouncing Dictionary (CMU)'`.
- Acknowledge CMU in *Settings → Data sources & licences*.
- Caveat surfaced in the UI: this is **US** pronunciation only, and it is a broad transcription
  — the UK field stays empty and the user can type it.

---

## 3. Cambridge Dictionary — **link only**

Cambridge publishes no free public API, and scraping their pages breaches their terms, breaks
whenever their markup changes, and risks store removal. So:

- **Allowed:** `url_launcher` opening `https://dictionary.cambridge.org/dictionary/english/<word>`
  in the user's external browser, labelled "Open in Cambridge Dictionary".
- **Forbidden, in code review terms — reject any PR that:** fetches a `dictionary.cambridge.org`
  URL programmatically; parses their HTML; caches or stores their definitions, examples or
  audio; embeds their site in an in-app WebView styled to look like part of VocabNote; or uses
  their name, logo or wordmark as branding. The word "Cambridge" may appear only as the plain
  text of the link, and nothing about the app may suggest affiliation.

---

## 4. Audio — device text-to-speech (`flutter_tts`)

- Uses the OS speech engine (Google TTS / Samsung TTS on Android, AVSpeechSynthesizer on iOS).
  No content is bundled, so **no licence obligation**, no storage cost, and it works offline.
- Voice selection is limited to what the user's device has installed. If no `en-GB` voice
  exists, fall back to `en-US` and say so once, with a link to the OS voice settings.

**Known limitation, stated honestly in the app.** TTS is a synthesised reference, not a native
speaker. It is a good model for stress, rhythm and vowel targets, and it is reliable for every
word including names and rare terms — but it can miss the natural connected speech of a human
recording. The *How to use* guide says this in one plain sentence rather than overselling it.

Phase 2 (`F-028`) may add real recordings from **Wikimedia Commons** (CC BY-SA / CC0 depending
on the file — each file's licence must be read and stored per-file, not assumed). Both sit
behind `SpeechService`, so no screen changes.

---

## 5. Fonts

| Font | Use | Licence |
|---|---|---|
| **Inter** | all UI text | SIL Open Font License 1.1 |
| **Charis SIL** | IPA rendering | SIL Open Font License 1.1 |

Both are bundled as assets rather than fetched from Google Fonts, so the app works offline and
the licence position is unambiguous. OFL requires the licence text to be distributed with the
fonts — ship `assets/fonts/OFL.txt` for each and surface it in the licences screen.

Charis SIL is used specifically because generic system fonts render IPA symbols and combining
diacritics inconsistently across Android OEMs — and IPA fidelity is the point of this app.

---

## 6. Dart/Flutter packages

Permissive licences only: **MIT, BSD-2/3, Apache-2.0, OFL**. No GPL/AGPL/LGPL, no
source-available or "free for non-commercial" licences.

- `flutter pub deps --json` feeds a licence report generated in CI; a new non-permissive
  licence fails the build.
- The in-app licences screen uses Flutter's `showLicensePage()` (which aggregates package
  licences automatically) **plus** our own section for the data sources above, which
  `showLicensePage` does not know about.

---

## 7. Privacy statement (what the app actually does)

- No account, no sign-in, no server owned by us.
- No analytics, no ads, no tracking SDKs, no advertising ID.
- The only outbound requests: (a) a word you explicitly look up, sent to
  `freedictionaryapi.com`; (b) URLs you explicitly tap open in your browser.
- Feedback is composed in the user's own mail app; the pre-filled diagnostics (app version, OS
  version, device model) are visible to the user before they press send, and nothing else is
  attached.
- Everything else — words, IPA, highlights, notes, practice history — stays in the app's
  private database on the device and leaves only when the user exports a backup.

This is the text that must match both the store privacy declarations (Play Data Safety, Apple
App Privacy) and `F-076` in the app. If one changes, all three change in the same PR.

---

## 8. Sources checked

- Free Dictionary API (Wiktionary/wiktextract, CC BY-SA 4.0, 1,000 req/h): https://freedictionaryapi.com/
- dictionaryapi.dev (no published licence; Google Dictionary provenance): https://dictionaryapi.dev/
- CMUdict licence: https://github.com/cmusphinx/cmudict
- CC BY-SA 4.0: https://creativecommons.org/licenses/by-sa/4.0/
- SIL Open Font License 1.1: https://openfontlicense.org/
