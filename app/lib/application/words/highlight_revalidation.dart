/// Keeping highlights honest when the transcription changes (F-023).
library;

import 'package:meta/meta.dart';
// Riverpod 3 ships its own AsyncResult; ours is the Result-based one.
import 'package:riverpod_annotation/riverpod_annotation.dart' hide AsyncResult;
import 'package:vocabnote/application/repositories.dart';
import 'package:vocabnote/core/extensions/grapheme.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';

part 'highlight_revalidation.g.dart';

/// Splits [highlights] against the new transcriptions (F-023).
///
/// A range is measured in grapheme clusters over one exact string, so
/// shortening `kɒf` to `kɒ` invalidates anything reaching the third symbol —
/// while lengthening it invalidates nothing, which is why a longer
/// transcription silently keeps every colour.
///
/// Clearing a transcription entirely drops all of its highlights: there is
/// nothing left for them to point at.
///
/// Deliberately **not** clamping a range to fit. A highlight shortened to
/// whatever still fits would be a colour on symbols the user never chose,
/// which is worse than losing it and being told so.
///
/// A free function rather than a static one so it stays trivially callable
/// from a test with no container and no database.
HighlightRevalidation revalidateHighlights({
  required List<IpaHighlight> highlights,
  required String? ipaUk,
  required String? ipaUs,
}) {
  final lengths = <HighlightTarget, int>{
    HighlightTarget.ipaUk: ipaUk?.graphemeLength ?? 0,
    HighlightTarget.ipaUs: ipaUs?.graphemeLength ?? 0,
  };

  final kept = <IpaHighlight>[];
  final dropped = <IpaHighlight>[];
  for (final highlight in highlights) {
    final length = lengths[highlight.target] ?? 0;
    if (length > 0 && highlight.fits(length)) {
      kept.add(highlight);
    } else {
      dropped.add(highlight);
    }
  }
  return HighlightRevalidation(kept: kept, dropped: dropped);
}

/// Which highlights survive a transcription edit and which do not.
@immutable
class HighlightRevalidation {
  /// Creates a split.
  const new({required this.kept, required this.dropped});

  /// Highlights whose range still fits the new transcription.
  final List<IpaHighlight> kept;

  /// Highlights whose range no longer fits, and which the user must be asked
  /// about before they are removed.
  final List<IpaHighlight> dropped;

  /// Whether anything would be lost.
  bool get hasLosses => dropped.isNotEmpty;
}

/// Checks and prunes highlights around a transcription edit.
@Riverpod(keepAlive: true)
class HighlightRevalidator extends _$HighlightRevalidator {
  @override
  void build() {}

  /// What would happen to [wordId]'s highlights under new transcriptions.
  ///
  /// Read before the word is saved, so the user can be asked first — the whole
  /// point of F-023 is that colours are never dropped silently.
  AsyncResult<HighlightRevalidation> check({
    required String wordId,
    required String? ipaUk,
    required String? ipaUs,
  }) async {
    final stored = await ref.read(wordRepositoryProvider).getHighlights(wordId);

    return stored.map(
      (highlights) => revalidateHighlights(
        highlights: highlights,
        ipaUk: ipaUk,
        ipaUs: ipaUs,
      ),
    );
  }

  /// Writes [revalidation]'s survivors, removing the rest.
  ///
  /// One replace per transcription, each atomic and scoped, so a failure on one
  /// cannot half-prune the other.
  AsyncResult<void> prune({
    required String wordId,
    required HighlightRevalidation revalidation,
  }) async {
    if (!revalidation.hasLosses) return const Ok<void, AppFailure>(null);

    final repository = ref.read(wordRepositoryProvider);
    for (final target in HighlightTarget.values) {
      // Only touch a transcription that actually lost something. Rewriting the
      // other one would be a pointless delete-and-reinsert of rows that are
      // already correct.
      final lostHere = revalidation.dropped.any((h) => h.target == target);
      if (!lostHere) continue;

      final result = await repository.replaceHighlights(
        wordId: wordId,
        target: target,
        highlights: revalidation.kept
            .where((highlight) => highlight.target == target)
            .toList(),
      );
      if (result.isErr) return result;
    }
    return const Ok<void, AppFailure>(null);
  }
}
