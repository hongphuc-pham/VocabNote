import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabnote/application/practice/game_contracts.dart';
import 'package:vocabnote/presentation/practice/games/flashcard/flashcard_game.dart';

/// Every game the app ships (F-067).
///
/// **This is the one shared file adding a game is allowed to touch**, and the
/// edit is a single line. Everything else — the hub card, the config sheet, the
/// session row, the stats — reads the registry and needs no change.
/// `DummyGame` in the tests proves that claim by doing exactly this and nothing
/// else.
///
/// It lives in `presentation/` because a game does: a game implements an
/// application interface but is built from widgets, so `application` cannot
/// name one (RULES §20, and `context.md` §4d for how that was found).
final Provider<GameRegistry> gameRegistryProvider = Provider<GameRegistry>((
  ref,
) {
  return GameRegistry()..register(const FlashcardGame());
});
