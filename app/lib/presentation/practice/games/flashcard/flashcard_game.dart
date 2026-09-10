import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_round_view.dart';

/// The v1 game: a two-sided card the user grades themselves
/// (`docs/GAMES.md` §6, F-061–F-063).
///
/// **In `presentation/`, not `application/`.** M1 laid out
/// `application/practice/games/flashcard/`, but a round view needs the shared
/// UI — `IpaText` to render highlights, `VnGap` for themed spacing — and
/// `application` may not import `presentation` (RULES §20). The
/// `layer_boundaries_test` caught it, which is the test doing exactly its job.
///
/// The *contracts* stay in `application/practice/game_contracts.dart` as
/// `GAMES.md` §2 requires. A game is presentation that implements an
/// application interface, which is the same shape as every screen in the app.
class FlashcardGame implements PracticeGame<FlashcardRound> {
  /// Creates the game.
  const new();

  /// Stored in `practice_sessions.game_id`. Never localise or change this.
  static const String gameId = 'flashcard';

  @override
  GameDescriptor get descriptor => GameDescriptor(
    id: gameId,
    title: (l10n) => l10n.gameFlashcardTitle,
    description: (l10n) => l10n.gameFlashcardDescription,
    // A named constant, not a raw codepoint. The first version guessed
    // 0xe3d0 - chosen when this file lived in `application/` and only
    // `flutter/widgets.dart` was in scope - and it rendered an envelope.
    // A raw codepoint also defeats icon tree-shaking.
    icon: Icons.style_outlined,
    supportedModes: const <PracticeMode>{
      PracticeMode.daily,
      PracticeMode.quickTest,
    },
  );

  @override
  List<FlashcardRound> buildRounds(
    GameConfig config,
    List<PracticeCardData> pool,
  ) {
    final ordered = List<PracticeCardData>.of(pool);
    // Shuffled by the *stored* seed, so a session can be replayed exactly
    // (`GAMES.md` §4). Without a seed the pool's own order is kept — the pool
    // loader has already ordered a daily review by due date, and re-shuffling
    // would throw that away.
    if (config.seed case final int seed) {
      ordered.shuffle(Random(seed));
    }

    return <FlashcardRound>[
      for (var i = 0; i < ordered.length; i++)
        FlashcardRound(
          index: i,
          card: ordered[i],
          promptSide: config.promptSide,
          isFirstRound: i == 0,
          autoPlayOnReveal: config.ttsAutoPlay,
        ),
    ];
  }

  @override
  ReviewOutcome grade(FlashcardRound round, GameAnswer answer) {
    // Self-graded: the button the user tapped *is* the result. There is
    // nothing to check it against, and pretending otherwise would invent an
    // opinion the game does not have.
    return answer.result;
  }

  @override
  Widget buildRoundView(
    BuildContext context,
    FlashcardRound round,
    GameRoundCallbacks callbacks,
  ) => FlashcardRoundView(round: round, callbacks: callbacks);
}

/// One card to answer.
@immutable
class FlashcardRound extends GameRound {
  /// Creates a round.
  const new({
    required super.index,
    required super.card,
    required this.promptSide,
    this.isFirstRound = false,
    this.autoPlayOnReveal = true,
  });

  /// Which face opens, from the user's config.
  final PromptSide promptSide;

  /// Whether to show the "Tap to reveal" hint — round 1 only (`UI-UX` §4.7).
  final bool isFirstRound;

  /// Whether revealing speaks the word without being asked (F-063).
  ///
  /// Separate from whether the play button exists: the button is always there.
  final bool autoPlayOnReveal;

  /// The text on the front, or null when the word has nothing for this side.
  ///
  /// A word with no transcription cannot be asked `ipaFirst`, and one with no
  /// definition cannot be asked `meaningFirst`. Rather than show an empty card
  /// the view falls back to the headword — see [frontIsFallback].
  String? get prompt => switch (promptSide) {
    PromptSide.wordFirst => card.word.headword.value,
    PromptSide.ipaFirst => card.word.preferredIpa?.value,
    PromptSide.meaningFirst => card.word.definition,
  };

  /// Whether the front had to fall back to the headword.
  ///
  /// The alternative — an empty card, or skipping the word — is worse: a word
  /// you have not written a definition for is exactly a word worth practising.
  bool get frontIsFallback => prompt == null || prompt!.trim().isEmpty;

  /// What the front actually shows.
  String get frontText => frontIsFallback ? card.word.headword.value : prompt!;

  /// Whether the front is showing a transcription rather than plain text.
  bool get frontIsIpa => !frontIsFallback && promptSide == PromptSide.ipaFirst;
}
