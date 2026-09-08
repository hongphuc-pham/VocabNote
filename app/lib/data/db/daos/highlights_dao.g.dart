// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlights_dao.dart';

// ignore_for_file: type=lint
mixin _$HighlightsDaoMixin on DatabaseAccessor<AppDatabase> {
  $WordsTable get words => attachedDatabase.words;
  $IpaHighlightsTable get ipaHighlights => attachedDatabase.ipaHighlights;
  HighlightsDaoManager get managers => HighlightsDaoManager(this);
}

class HighlightsDaoManager {
  final _$HighlightsDaoMixin _db;
  HighlightsDaoManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db.attachedDatabase, _db.words);
  $$IpaHighlightsTableTableManager get ipaHighlights =>
      $$IpaHighlightsTableTableManager(_db.attachedDatabase, _db.ipaHighlights);
}
