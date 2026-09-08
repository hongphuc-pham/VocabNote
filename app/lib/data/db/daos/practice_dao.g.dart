// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_dao.dart';

// ignore_for_file: type=lint
mixin _$PracticeDaoMixin on DatabaseAccessor<AppDatabase> {
  $WordsTable get words => attachedDatabase.words;
  $StudyCardsTable get studyCards => attachedDatabase.studyCards;
  $PracticeSessionsTable get practiceSessions =>
      attachedDatabase.practiceSessions;
  $PracticeAnswersTable get practiceAnswers => attachedDatabase.practiceAnswers;
  $WordListsTable get wordLists => attachedDatabase.wordLists;
  $WordListItemsTable get wordListItems => attachedDatabase.wordListItems;
  PracticeDaoManager get managers => PracticeDaoManager(this);
}

class PracticeDaoManager {
  final _$PracticeDaoMixin _db;
  PracticeDaoManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db.attachedDatabase, _db.words);
  $$StudyCardsTableTableManager get studyCards =>
      $$StudyCardsTableTableManager(_db.attachedDatabase, _db.studyCards);
  $$PracticeSessionsTableTableManager get practiceSessions =>
      $$PracticeSessionsTableTableManager(
        _db.attachedDatabase,
        _db.practiceSessions,
      );
  $$PracticeAnswersTableTableManager get practiceAnswers =>
      $$PracticeAnswersTableTableManager(
        _db.attachedDatabase,
        _db.practiceAnswers,
      );
  $$WordListsTableTableManager get wordLists =>
      $$WordListsTableTableManager(_db.attachedDatabase, _db.wordLists);
  $$WordListItemsTableTableManager get wordListItems =>
      $$WordListItemsTableTableManager(_db.attachedDatabase, _db.wordListItems);
}
