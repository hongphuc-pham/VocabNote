// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'words_dao.dart';

// ignore_for_file: type=lint
mixin _$WordsDaoMixin on DatabaseAccessor<AppDatabase> {
  $WordsTable get words => attachedDatabase.words;
  $WordNotesTable get wordNotes => attachedDatabase.wordNotes;
  $WordListsTable get wordLists => attachedDatabase.wordLists;
  $WordListItemsTable get wordListItems => attachedDatabase.wordListItems;
  $StudyCardsTable get studyCards => attachedDatabase.studyCards;
  WordsDaoManager get managers => WordsDaoManager(this);
}

class WordsDaoManager {
  final _$WordsDaoMixin _db;
  WordsDaoManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db.attachedDatabase, _db.words);
  $$WordNotesTableTableManager get wordNotes =>
      $$WordNotesTableTableManager(_db.attachedDatabase, _db.wordNotes);
  $$WordListsTableTableManager get wordLists =>
      $$WordListsTableTableManager(_db.attachedDatabase, _db.wordLists);
  $$WordListItemsTableTableManager get wordListItems =>
      $$WordListItemsTableTableManager(_db.attachedDatabase, _db.wordListItems);
  $$StudyCardsTableTableManager get studyCards =>
      $$StudyCardsTableTableManager(_db.attachedDatabase, _db.studyCards);
}
