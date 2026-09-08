// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_dao.dart';

// ignore_for_file: type=lint
mixin _$ListsDaoMixin on DatabaseAccessor<AppDatabase> {
  $WordListsTable get wordLists => attachedDatabase.wordLists;
  $WordsTable get words => attachedDatabase.words;
  $WordListItemsTable get wordListItems => attachedDatabase.wordListItems;
  $StudyCardsTable get studyCards => attachedDatabase.studyCards;
  ListsDaoManager get managers => ListsDaoManager(this);
}

class ListsDaoManager {
  final _$ListsDaoMixin _db;
  ListsDaoManager(this._db);
  $$WordListsTableTableManager get wordLists =>
      $$WordListsTableTableManager(_db.attachedDatabase, _db.wordLists);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db.attachedDatabase, _db.words);
  $$WordListItemsTableTableManager get wordListItems =>
      $$WordListItemsTableTableManager(_db.attachedDatabase, _db.wordListItems);
  $$StudyCardsTableTableManager get studyCards =>
      $$StudyCardsTableTableManager(_db.attachedDatabase, _db.studyCards);
}
