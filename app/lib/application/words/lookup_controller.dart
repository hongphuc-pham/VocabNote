import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/domain/entities/word_suggestion.dart';

part 'lookup_controller.freezed.dart';
part 'lookup_controller.g.dart';

/// What the look-up card is showing (`docs/UI-UX.md` §4.2).
@freezed
sealed class LookupState with _$LookupState {
  /// Nothing has been looked up yet, or the card was dismissed.
  const factory idle() = LookupIdle;

  /// A request is in flight.
  const factory loading(String headword) = LookupLoading;

  /// Results arrived. May still be empty - "no results" is an outcome.
  const factory results(WordSuggestions suggestions) = LookupResults;

  /// The look-up failed.
  ///
  /// Rendered as a quiet inline message, never a dialog: the form must stay
  /// completely usable and the user can type the IPA themselves (F-006).
  const factory failed(AppFailure failure) = LookupFailed;
}

/// Runs dictionary look-ups for the add/edit form (F-004, F-005, F-006).
///
/// Only ever started by an explicit *Look up* tap - never automatically, never
/// as the user types. That is both a rate-limit courtesy and the privacy
/// promise: the only thing that leaves the device is a word the user asked us
/// to look up (`docs/DATA-SOURCES.md` §7).
@riverpod
class Lookup extends _$Lookup {
  @override
  LookupState build() => const LookupState.idle();

  /// Looks [headword] up.
  Future<void> lookup(String headword) async {
    final trimmed = headword.trim();
    if (trimmed.isEmpty) {
      state = const LookupState.idle();
      return;
    }

    state = LookupState.loading(trimmed);

    final result = await ref.read(dictionaryRepositoryProvider).lookup(trimmed);

    // The user may have dismissed the card or changed the word while the
    // request was in flight; a stale response must not reopen it.
    final current = state;
    if (current is! LookupLoading || current.headword != trimmed) return;

    state = result.fold(LookupState.results, LookupState.failed);
  }

  /// Hides the results card.
  void dismiss() => state = const LookupState.idle();
}
