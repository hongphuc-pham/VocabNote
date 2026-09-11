/// Where the *How to use* guide's *Try it* buttons go (F-071).
library;

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/router/routes.dart';
import 'package:vocabnote/domain/repositories/word_query.dart';
import 'package:vocabnote/domain/repositories/word_repository.dart';

part 'guide_targets.g.dart';

/// The words the guide's cards can point at.
///
/// A card about highlighting is most use when it opens a word the user
/// already has; with nothing to open, it starts where they would have to -
/// adding one.
@immutable
class GuideTargets {
  /// Creates the targets.
  const new({this.newestWordId, this.newestTranscribedWordId});

  /// A library with no words yet.
  static const GuideTargets none = GuideTargets();

  /// The most recently added word, if any.
  final String? newestWordId;

  /// The most recently added word that has a transcription, if any.
  final String? newestTranscribedWordId;

  /// Card 1-3: adding a word, filling it, writing its IPA - all the add form.
  String get addWord => Routes.wordAdd;

  /// Card 4: the IPA editor of a transcribed word; else the editor of the
  /// newest word, to give it some IPA first; else the add form.
  String get highlight {
    final transcribed = newestTranscribedWordId;
    if (transcribed != null) return Routes.wordIpaOf(transcribed);
    final newest = newestWordId;
    if (newest != null) return Routes.wordEditOf(newest);
    return Routes.wordAdd;
  }

  /// Card 5: the newest word, where its notes are; else the add form.
  String get note {
    final newest = newestWordId;
    return newest == null ? Routes.wordAdd : Routes.wordDetailOf(newest);
  }

  /// Card 6: the practice hub.
  String get practise => Routes.practice;
}

/// The guide's targets, kept current.
///
/// Watched rather than read once, so a word added from one card's *Try it*
/// is the word the next card opens. Twenty recent words is plenty to find a
/// transcribed one; a library with none in its last twenty is sent to add
/// IPA to its newest word, which is the right advice anyway.
@riverpod
Stream<GuideTargets> guideTargets(Ref ref) => ref
    .watch(wordRepositoryProvider)
    .watchWords(const WordQuery(limit: 20))
    .map((result) {
      final entries = result.valueOrNull ?? const <WordListEntry>[];
      return GuideTargets(
        newestWordId: entries.firstOrNull?.word.id,
        newestTranscribedWordId: entries
            .where((entry) => !entry.word.hasNoIpa)
            .firstOrNull
            ?.word
            .id,
      );
    });
