import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/ipa_highlights.dart';
import 'package:vocabnote/domain/entities/ipa_highlight.dart';

part 'highlights_dao.g.dart';

/// Reads and writes `ipa_highlights` - the signature feature (F-022).
@DriftAccessor(tables: <Type>[IpaHighlights])
class HighlightsDao extends DatabaseAccessor<AppDatabase>
    with _$HighlightsDaoMixin {
  /// Creates the DAO.
  new(super.attachedDatabase);

  /// Watches every highlight on one word, both transcriptions.
  ///
  /// Ordered by start offset so the legend reads left to right, matching the
  /// order the colours appear in the transcription.
  Stream<List<IpaHighlightRow>> watchForWord(String wordId) =>
      (select(ipaHighlights)
            ..where((h) => h.wordId.equals(wordId))
            ..orderBy(<OrderClauseGenerator<IpaHighlights>>[
              (h) => OrderingTerm.asc(h.target),
              (h) => OrderingTerm.asc(h.startGrapheme),
            ]))
          .watch();

  /// One-shot version of [watchForWord].
  ///
  /// A real query, **not** `watchForWord(...).first`: that opens a stream
  /// subscription and waits for Drift to deliver the first event on a timer,
  /// which is both wasteful and — under a widget test's fake clock — never.
  Future<List<IpaHighlightRow>> getForWord(String wordId) =>
      (select(ipaHighlights)
            ..where((h) => h.wordId.equals(wordId))
            ..orderBy(<OrderClauseGenerator<IpaHighlights>>[
              (h) => OrderingTerm.asc(h.target),
              (h) => OrderingTerm.asc(h.startGrapheme),
            ]))
          .get();

  /// Watches the highlights for one word and one transcription.
  Stream<List<IpaHighlightRow>> watchForTarget(
    String wordId,
    HighlightTarget target,
  ) =>
      (select(ipaHighlights)
            ..where((h) => h.wordId.equals(wordId))
            ..where((h) => h.target.equalsValue(target))
            ..orderBy(<OrderClauseGenerator<IpaHighlights>>[
              (h) => OrderingTerm.asc(h.startGrapheme),
            ]))
          .watch();

  /// Replaces every highlight for one word and target in a single transaction.
  ///
  /// This is what *Done* in the highlight editor calls. The editor keeps its
  /// whole session in memory with undo, and nothing is written until the user
  /// commits (`docs/UI-UX.md` section 4.4) - so the write is naturally a
  /// replace, and doing it atomically means a crash mid-save cannot leave half
  /// the user's colours behind.
  ///
  /// Scoped to one [target]: saving UK highlights must never disturb US ones.
  Future<void> replaceForTarget(
    String wordId,
    HighlightTarget target,
    List<IpaHighlightsCompanion> highlights,
  ) async {
    await transaction(() async {
      await (delete(ipaHighlights)
            ..where((h) => h.wordId.equals(wordId))
            ..where((h) => h.target.equalsValue(target)))
          .go();
      if (highlights.isNotEmpty) {
        await batch((batch) => batch.insertAll(ipaHighlights, highlights));
      }
    });
  }

  /// Inserts one highlight.
  Future<void> insertHighlight(IpaHighlightsCompanion highlight) =>
      into(ipaHighlights).insert(highlight);

  /// Deletes one highlight.
  Future<int> deleteHighlight(String id) =>
      (delete(ipaHighlights)..where((h) => h.id.equals(id))).go();

  /// Deletes highlights by id - used when the user confirms dropping the ones
  /// an IPA edit invalidated (F-023).
  Future<int> deleteHighlights(List<String> ids) async {
    if (ids.isEmpty) return 0;
    return await (delete(ipaHighlights)..where((h) => h.id.isIn(ids))).go();
  }

  /// Watches every highlight in the database, grouped by word.
  ///
  /// The words list renders inline IPA in colour on every row (F-040). Loading
  /// them per row would be one query per visible word; this is one query for
  /// the whole screen. Highlights are small and there are at most a handful per
  /// word, so holding them all is cheaper than paging them.
  Stream<Map<String, List<IpaHighlightRow>>> watchGroupedByWord() =>
      (select(ipaHighlights)..orderBy(<OrderClauseGenerator<IpaHighlights>>[
            (h) => OrderingTerm.asc(h.startGrapheme),
          ]))
          .watch()
          .map((rows) {
            final grouped = <String, List<IpaHighlightRow>>{};
            for (final row in rows) {
              grouped
                  .putIfAbsent(row.wordId, () => <IpaHighlightRow>[])
                  .add(row);
            }
            return grouped;
          });

  /// The highlights on each of [wordIds], grouped by word, in one query.
  ///
  /// For a practice pool, which is resolved before a session starts. A
  /// one-shot read rather than [watchGroupedByWord]`.first`: that loaded every
  /// highlight in the library to use thirty words' worth, and awaiting `.first`
  /// on a watch stream never completes under a widget test's fake clock.
  Future<Map<String, List<IpaHighlightRow>>> groupedByWords(
    Set<String> wordIds,
  ) async {
    if (wordIds.isEmpty) return <String, List<IpaHighlightRow>>{};

    final rows =
        await (select(ipaHighlights)
              ..where((h) => h.wordId.isIn(wordIds))
              ..orderBy(<OrderClauseGenerator<IpaHighlights>>[
                (h) => OrderingTerm.asc(h.startGrapheme),
              ]))
            .get();

    final grouped = <String, List<IpaHighlightRow>>{};
    for (final row in rows) {
      grouped.putIfAbsent(row.wordId, () => <IpaHighlightRow>[]).add(row);
    }
    return grouped;
  }

  /// Watches which words have at least one highlight.
  ///
  /// Lets the words list decide whether to render coloured IPA without loading
  /// every highlight for every row.
  Stream<Set<String>> watchWordIdsWithHighlights() {
    final query = selectOnly(ipaHighlights, distinct: true)
      ..addColumns(<Expression<Object>>[ipaHighlights.wordId]);
    return query.watch().map(
      (rows) => rows.map((r) => r.read(ipaHighlights.wordId)!).toSet(),
    );
  }
}
