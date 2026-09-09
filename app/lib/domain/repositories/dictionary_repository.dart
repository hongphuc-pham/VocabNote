import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';

/// Looking a word up (F-004, F-005, F-006).
///
/// The only feature in the app that touches the network, and it is optional by
/// construction: the caller may ignore every result and the user may never tap
/// *Look up* at all. Manual entry is the first-class path
/// (`docs/RULES.md` §3).
abstract interface class DictionaryRepository {
  /// Looks up [word], preferring the online dictionary and falling back to the
  /// bundled offline asset.
  ///
  /// The order is: cache, then API, then offline. Returns
  /// `Ok(WordSuggestions)` with an empty [WordSuggestions.suggestions] when
  /// nothing was found anywhere - "no results" is an outcome, not a failure.
  ///
  /// Returns `Err` only when the network failed **and** the offline asset had
  /// nothing either, so the UI can show the quiet inline message from F-006
  /// while leaving the form completely usable.
  AsyncResult<WordSuggestions> lookup(String word);

  /// Looks up [word] using only the bundled asset, never the network.
  ///
  /// Used when the user has turned look-up off in settings, and by tests that
  /// must not reach the internet.
  AsyncResult<WordSuggestions> lookupOffline(String word);

  /// Empties the 24-hour response cache.
  Future<void> clearCache();
}
