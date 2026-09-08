# Practice game framework

Requirement: flashcards ship in v1, but more games follow. **Adding a game must not require
touching the practice hub, the config sheet, session persistence, stats or the database.**
So practice is a registry of small plugins behind one set of contracts.

## 1. Responsibilities, split three ways

| Concern | Owner | Why separate |
|---|---|---|
| *Which cards do I practise?* | `CardPoolProvider` | Every game wants "due today" or "30 random from a list" — write it once. |
| *What does a round look like and what counts as correct?* | `PracticeGame` | The only thing a new game must implement. |
| *When does this card come back?* | `ReviewScheduler` | Leitner now, SM-2 later, without rewriting any game. |

## 2. Contracts (`application/practice/game_contracts.dart`)

```dart
enum PracticeMode { daily, quickTest }
enum PromptSide   { wordFirst, ipaFirst, meaningFirst }
enum RoundResult  { again, good, easy, skipped }

/// Static description used by the hub to render a game card.
class GameDescriptor {
  final String id;                       // stable, stored in practice_sessions.game_id
  final String titleKey;                 // l10n key
  final String descriptionKey;
  final IconData icon;
  final Set<PracticeMode> supportedModes;
  final int minCards;                    // hub greys the game out below this
  final int maxQuickTestCards;           // 30
  final bool requiresIpa;                // hub filters the pool accordingly
  final bool requiresAudio;
}

/// Everything the user chose in the config sheet. Serialised into
/// practice_sessions.config_json — readers must tolerate unknown keys.
@freezed
class GameConfig with _$GameConfig {
  const factory GameConfig({
    required String gameId,
    required PracticeMode mode,
    required CardSource source,          // all | list(id) | favourites
    required CardSelection selection,    // due | random | weakest | newest
    required int limit,                  // <= 30 in quickTest
    @Default(PromptSide.wordFirst) PromptSide promptSide,
    @Default(true) bool ttsAutoPlay,
    int? seed,                           // stored so a test can be repeated
  }) = _GameConfig;
}

/// A word plus its study state, denormalised for the session.
class PracticeCard {
  final Word word;
  final StudyCard study;
  final List<IpaHighlight> highlights;
}

// CardSource   = all | list(listId) | favourites   (sealed class)
// CardSelection = due | random | weakest | newest      (enum)
abstract interface class CardPoolProvider {
  Future<List<PracticeCard>> load(GameConfig config);
}

/// One question. Games subclass this with whatever they need.
abstract class GameRound {
  final int index;
  final PracticeCard card;
}

class GameAnswer {
  final RoundResult result;
  final Duration elapsed;
  final Object? payload;                 // e.g. the option a user tapped
}

abstract interface class PracticeGame<R extends GameRound> {
  GameDescriptor get descriptor;

  /// Turn a pool into an ordered list of rounds. Pure; no I/O.
  List<R> buildRounds(GameConfig config, List<PracticeCard> pool);

  /// Decide the outcome. Pure; no I/O. Self-graded games just echo the tap.
  RoundResult grade(R round, GameAnswer answer);

  /// The round UI. Calls onAnswer(GameAnswer) exactly once.
  Widget buildRoundView(BuildContext context, R round, GameRoundCallbacks cb);
}

abstract interface class ReviewScheduler {
  StudyCard apply(StudyCard current, RoundResult result, DateTime now);
}

class GameRegistry {
  void register(PracticeGame game);
  List<GameDescriptor> available(int wordCount);
  PracticeGame byId(String id);
}
```

## 3. The runner (written once, shared by all games)

`PracticeSessionController` is a Riverpod notifier that:

1. resolves the `CardPoolProvider` for `config.selection`
2. calls `game.buildRounds(...)`
3. opens a `practice_sessions` row with `affects_scheduling = mode == daily`
4. per round: renders `game.buildRoundView`, receives the answer, calls `game.grade`,
   writes a `practice_answers` row, and — **only if `affects_scheduling`** — applies
   `ReviewScheduler` to the `study_cards` row
5. closes the session and hands a `SessionSummary` to the shared summary screen

Games never touch the database, never navigate, never own a progress bar.

## 4. Modes

### Daily review (`PracticeMode.daily`)
- Selection: `due` → `WHERE due_at <= now AND suspended = 0`, ordered by `due_at`, then random.
- Limit: the user's daily goal (default 20). If nothing is due, the hub offers "Nothing due —
  practise 10 at random instead?" which starts a **quick test** (schedule untouched).
- `affects_scheduling = true`.

### Quick test (`PracticeMode.quickTest`)
- Source: All words / a specific list / Favourites.
- Size: 5 · 10 · 20 · **All (max 30)**. The 30 cap is enforced in `GameConfig` construction
  *and* in the query, and is unit-tested with a 500-word fixture.
- Selection: `random` with a stored `seed` so a session can be replayed or debugged.
- `affects_scheduling = false` — a casual test must never damage a carefully built schedule.
  Answers are still recorded for stats.

## 5. Scheduling — `LeitnerScheduler` (v1)

| Box | Interval on *good* |
|---|---|
| 0 | same day, +10 min |
| 1 | 1 day |
| 2 | 2 days |
| 3 | 4 days |
| 4 | 7 days |
| 5 | 15 days |
| 6 | 30 days |

- `again` → box 0, `lapses++`, due in 10 minutes
- `good`  → box + 1 (max 6)
- `easy`  → box + 2 (max 6)
- `due_at = now + interval`, jittered ±10% so decks don't clump on one day
- `repetitions++`, `last_result`, `last_reviewed_at` always written

`Sm2Scheduler` (phase 2) uses `ease_factor`, which already exists in the schema — swapping it
in is a single provider override with **no migration**.

## 6. v1 game: `FlashcardGame`

- `descriptor.id = 'flashcard'`, modes `{daily, quickTest}`, `minCards = 4`, `requiresIpa = false`
- `buildRounds` → one `FlashcardRound` per card, shuffled by `seed`
- `grade` → self-graded: the tapped button *is* the result
- `buildRoundView` → front (prompt side per config, with the play button) → flip → back
  (word + IPA with the user's highlights + definition + first note) → Again / Good / Easy

## 7. Adding game #2 — the checklist

1. New folder `application/practice/games/<name>/`
2. `class XGame implements PracticeGame<XRound>` with a `GameDescriptor`
3. A round widget under `presentation/practice/games/<name>/`
4. One line in `game_registry.dart`
5. l10n strings for title + description
6. Tests: `buildRounds` determinism under a fixed seed, `grade` truth table, one widget test

If step 2–6 required editing any shared file other than the registry and l10n, the framework
is wrong — fix the framework, not the game. `DummyGame` in `test/unit/practice/` exists purely
to keep this honest and must stay green.
