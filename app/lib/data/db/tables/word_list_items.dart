import 'package:drift/drift.dart';
import 'package:vocabnote/data/db/converters/converters.dart';
import 'package:vocabnote/data/db/tables/word_lists.dart';
import 'package:vocabnote/data/db/tables/words.dart';

/// `word_list_items` - which words are in which lists. Many-to-many.
///
/// Both foreign keys cascade, which is precisely how "deleting a list never
/// deletes words" is guaranteed: removing a [WordLists] row removes the
/// membership rows and stops there. There is a test that asserts it.
@DataClassName('WordListItemRow')
class WordListItems extends Table {
  /// Owning list. Cascades.
  TextColumn get listId => text()
      .named('list_id')
      .references(WordLists, #id, onDelete: KeyAction.cascade)();

  /// Member word. Cascades.
  TextColumn get wordId => text()
      .named('word_id')
      .references(Words, #id, onDelete: KeyAction.cascade)();

  /// Epoch milliseconds UTC.
  IntColumn get addedAt =>
      integer().named('added_at').map(epochMillisConverter)();

  @override
  Set<Column<Object>> get primaryKey => {listId, wordId};
}
