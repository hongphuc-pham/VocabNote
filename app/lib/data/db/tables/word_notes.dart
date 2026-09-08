import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/converters/converters.dart';
import 'package:vocabnote/data/db/tables/words.dart';

/// `word_notes` - the user's own timestamped comments, many per word.
///
/// Note bodies are indexed for search (F-041), so a note is a first-class way
/// to find a word again.
// Notes are always fetched for one word at a time.
@TableIndex(name: 'idx_notes_word', columns: {#wordId})
@DataClassName('WordNoteRow')
class WordNotes extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  /// Owning word. Cascades, so purging a word takes its notes with it.
  TextColumn get wordId => text()
      .named('word_id')
      .references(Words, #id, onDelete: KeyAction.cascade)();

  /// What the user wrote.
  TextColumn get body => text()();

  /// Epoch milliseconds UTC.
  IntColumn get createdAt =>
      integer().named('created_at').map(epochMillisConverter)();

  /// Epoch milliseconds UTC.
  IntColumn get updatedAt =>
      integer().named('updated_at').map(epochMillisConverter)();

  /// Pinned notes sort above the rest.
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
