import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/data/dictionary/dictionary_cache.dart';
import 'package:vocabnote/data/dictionary/free_dictionary_client.dart';
import 'package:vocabnote/data/dictionary/offline_ipa_source.dart';
import 'package:vocabnote/data/dictionary/suggestion_mapper.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';
import 'package:vocabnote/domain/repositories/dictionary_repository.dart';

/// Cache, then API, then the bundled asset (F-004, F-005, F-006).
class DictionaryRepositoryImpl implements DictionaryRepository {
  /// Creates the repository.
  new({required this._client, required this._cache, required this._offline});

  final FreeDictionaryClient _client;
  final DictionaryCache _cache;
  final OfflineIpaSource _offline;

  @override
  AsyncResult<WordSuggestions> lookup(String word) async {
    final trimmed = word.trim();
    if (trimmed.isEmpty) {
      return const Err<WordSuggestions, AppFailure>(
        ValidationFailure(field: 'headword', reason: 'empty'),
      );
    }

    // 1. A cached response. Spends none of the 1,000/hour budget, and makes
    //    re-editing a word work with no network at all.
    final cached = await _cache.read(trimmed);
    if (cached != null) {
      final suggestions = mapResponseToSuggestions(cached, headword: trimmed);
      if (!suggestions.isEmpty) {
        return Ok<WordSuggestions, AppFailure>(suggestions);
      }
    }

    // 2. The API.
    final response = await _client.lookup(trimmed);

    final value = response.valueOrNull;
    if (value != null) {
      // A miss is HTTP 200 with `entries: []`, not a 404 - so an empty
      // response is cached too, and then falls through to the offline source.
      await _cache.write(trimmed, value);

      final suggestions = mapResponseToSuggestions(value, headword: trimmed);
      if (!suggestions.isEmpty) {
        return Ok<WordSuggestions, AppFailure>(suggestions);
      }
    }

    // 3. The bundled asset. Reached when the API was unreachable, or answered
    //    with nothing usable.
    final offline = await _offline.suggestionsFor(trimmed);
    if (!offline.isEmpty) {
      return Ok<WordSuggestions, AppFailure>(offline);
    }

    // Nothing anywhere. If the network was the reason, say so - the UI shows
    // the quiet inline message and the form stays usable (F-006).
    final failure = response.failureOrNull;
    if (failure is NetworkFailure) {
      return Err<WordSuggestions, AppFailure>(failure);
    }

    // The API genuinely has no entry for this word, and neither do we. That is
    // not an error: the user types it themselves, which is the normal path.
    return Ok<WordSuggestions, AppFailure>(
      WordSuggestions(headword: trimmed, source: offline.source),
    );
  }

  @override
  AsyncResult<WordSuggestions> lookupOffline(String word) async {
    final trimmed = word.trim();
    if (trimmed.isEmpty) {
      return const Err<WordSuggestions, AppFailure>(
        ValidationFailure(field: 'headword', reason: 'empty'),
      );
    }
    return Ok<WordSuggestions, AppFailure>(
      await _offline.suggestionsFor(trimmed),
    );
  }

  @override
  Future<void> clearCache() => _cache.clear();
}
