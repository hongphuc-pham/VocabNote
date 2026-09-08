import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';
import 'package:vocabnote/domain/entities/practice_session.dart';
import 'package:vocabnote/domain/entities/study_card.dart';
import 'package:vocabnote/domain/entities/word.dart';

/// A word, its study state and its highlights - one practice card.
///
/// Denormalised for the session so a running game never queries: everything a
/// round needs is loaded up front (`docs/GAMES.md` section 2).
class PracticeCardData {
  /// Creates a card.
  const new({
    required this.word,
    required this.card,
    this.highlights = const <IpaHighlight>[],
  });

  /// The word being practised.
  final Word word;

  /// Its scheduling state.
  final StudyCard card;

  /// Its highlights, for the reverse of the flashcard.
  final List<IpaHighlight> highlights;
}

/// How a pool is chosen (`docs/GAMES.md` section 2, `CardSelection`).
enum CardSelection {
  /// Cards due now, soonest first.
  due,

  /// A random sample.
  random,

  /// Lowest box first, then most lapses.
  weakest,

  /// Most recently added first.
  newest,
}

/// Persistence for practice (`docs/GAMES.md` section 3).
///
/// The session runner owns all of this; games never touch the database.
abstract interface class PracticeRepository {
  /// The hard ceiling on a quick test, from `docs/GAMES.md` section 4.
  ///
  /// Enforced here as well as in `GameConfig`, so neither layer is the only
  /// thing between a user and a 500-card session.
  static const int quickTestMaxCards = 30;

  /// Loads a pool of cards.
  ///
  /// [limit] is clamped to [quickTestMaxCards] when [mode] is
  /// [PracticeMode.quickTest].
  AsyncResult<List<PracticeCardData>> loadPool({
    required CardSelection selection,
    required PracticeMode mode,
    required int limit,
    CardSourceKind source = CardSourceKind.all,
    String? sourceId,
    int? seed,
  });

  /// Watches how many cards are due - the "Daily review (N due)" count.
  ResultStream<int> watchDueCount();

  /// Creates the study card that belongs to a new word.
  AsyncResult<void> createCardForWord(String wordId);

  /// Opens a session row and returns it.
  AsyncResult<PracticeSession> startSession(PracticeSession session);

  /// Records one graded round.
  ///
  /// Writing the answer and moving the schedule are one call so they cannot
  /// diverge - and the schedule is only touched when the session's
  /// `affectsScheduling` is true.
  AsyncResult<void> recordAnswer({
    required PracticeAnswer answer,
    required bool affectsScheduling,
    StudyCard? updatedCard,
  });

  /// Closes a session with its totals.
  AsyncResult<PracticeSession> endSession({
    required String sessionId,
    required DateTime endedAt,
    required int totalRounds,
    required int correctRounds,
  });

  /// Reads a finished session, for the summary screen.
  AsyncResult<PracticeSession?> getSession(String id);

  /// The answers in a session, in order.
  AsyncResult<List<PracticeAnswer>> answersForSession(String sessionId);

  /// Recent finished sessions, for the streak and the goal ring.
  ResultStream<List<PracticeSession>> watchRecentSessions({int limit});
}
