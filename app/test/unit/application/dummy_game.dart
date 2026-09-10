import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/repositories/practice_repository.dart';

/// A throwaway second game, existing only to prove F-067 (RULES §34).
///
/// The claim it tests: *adding a game requires exactly one `PracticeGame`
/// class, one round widget and one registry line — no changes to the hub, the
/// config sheet, session storage or stats.*
///
/// **It lives in `test/`, not `lib/`, on purpose.** A dummy that shipped would
/// slowly acquire special cases in the hub and the runner until F-067 was true
/// only for it. Kept here, it can only use what any third-party game could.
///
/// If this file ever needs an import from `presentation/`, or a database, or a
/// navigator, then the framework has leaked and F-067 is already false — the
/// compile error is the point.
class DummyGame implements PracticeGame<DummyRound> {
  /// The registered id.
  static const String gameId = 'dummy';

  /// The *Good* button, so a test can tap it without matching on copy.
  static const Key goodKey = Key('dummy-good');

  @override
  GameDescriptor get descriptor => GameDescriptor(
    id: gameId,
    // Not localised: this game never reaches a user, so inventing two ARB
    // entries for it would put test-only strings in the shipped bundle.
    title: (l10n) => 'Dummy',
    description: (l10n) => 'A game that exists only in tests.',
    icon: const IconData(0x1F600),
    supportedModes: const <PracticeMode>{
      PracticeMode.daily,
      PracticeMode.quickTest,
    },
  );

  @override
  List<DummyRound> buildRounds(GameConfig config, List<PracticeCardData> pool) {
    final ordered = List<PracticeCardData>.of(pool);
    if (config.seed case final int seed) {
      ordered.shuffle(Random(seed));
    }
    return <DummyRound>[
      for (var i = 0; i < ordered.length; i++)
        DummyRound(index: i, card: ordered[i]),
    ];
  }

  @override
  ReviewOutcome grade(DummyRound round, GameAnswer answer) => answer.result;

  @override
  Widget buildRoundView(
    BuildContext context,
    DummyRound round,
    GameRoundCallbacks callbacks,
  ) {
    return GestureDetector(
      key: goodKey,
      onTap: () => callbacks.onAnswer(
        const GameAnswer(
          result: ReviewOutcome.good,
          elapsed: Duration(seconds: 1),
        ),
      ),
      child: Text(round.card.word.headword.value),
    );
  }
}

/// One round of [DummyGame].
class DummyRound extends GameRound {
  /// Creates a round.
  const new({required super.index, required super.card});
}
