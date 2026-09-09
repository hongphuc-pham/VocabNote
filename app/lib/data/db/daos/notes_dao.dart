import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/app_database.dart';
import 'package:vocabnote/data/db/tables/word_notes.dart';

part 'notes_dao.g.dart';

/// Reads and writes `word_notes` - the user's own comments (F-003).
///
/// Every write here fires the FTS triggers that keep note bodies searchable,
/// which is why notes are inserted through Drift rather than raw SQL.
@DriftAccessor(tables: <Type>[WordNotes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  /// Creates the DAO.
  new(super.attachedDatabase);

  /// Watches the notes for one word, pinned first then newest first.
  Stream<List<WordNoteRow>> watchForWord(String wordId) =>
      (select(wordNotes)
            ..where((n) => n.wordId.equals(wordId))
            ..orderBy(<OrderClauseGenerator<WordNotes>>[
              (n) => OrderingTerm.desc(n.pinned),
              (n) => OrderingTerm.desc(n.createdAt),
            ]))
          .watch();

  /// One-shot version of [watchForWord].
  Future<List<WordNoteRow>> getForWord(String wordId) =>
      watchForWord(wordId).first;

  /// Reads one note.
  Future<WordNoteRow?> getById(String id) =>
      (select(wordNotes)..where((n) => n.id.equals(id))).getSingleOrNull();

  /// Inserts a note.
  Future<void> insertNote(WordNotesCompanion note) =>
      into(wordNotes).insert(note);

  /// Applies a partial update to one note.
  Future<int> patchNote(String id, WordNotesCompanion patch) =>
      (update(wordNotes)..where((n) => n.id.equals(id))).write(patch);

  /// Permanently deletes one note.
  ///
  /// Notes are not soft-deleted: they are small, individually authored, and a
  /// user removing one note from a word they are keeping means it, unlike
  /// deleting a whole word.
  Future<int> deleteNote(String id) =>
      (delete(wordNotes)..where((n) => n.id.equals(id))).go();

  /// Counts notes per word, for the count shown on each list row (F-040).
  ///
  /// One query for the whole list rather than one per row, so a 5,000-word
  /// list does not become 5,000 queries.
  Stream<Map<String, int>> watchCountsByWord() {
    final count = wordNotes.id.count();
    final query = selectOnly(wordNotes)
      ..addColumns(<Expression<Object>>[wordNotes.wordId, count])
      ..groupBy(<Expression<Object>>[wordNotes.wordId]);

    return query.watch().map(
      (rows) => <String, int>{
        for (final row in rows)
          row.read(wordNotes.wordId)!: row.read(count) ?? 0,
      },
    );
  }
}
