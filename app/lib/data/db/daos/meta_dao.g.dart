// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_dao.dart';

// ignore_for_file: type=lint
mixin _$MetaDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppMetaTable get appMeta => attachedDatabase.appMeta;
  MetaDaoManager get managers => MetaDaoManager(this);
}

class MetaDaoManager {
  final _$MetaDaoMixin _db;
  MetaDaoManager(this._db);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db.attachedDatabase, _db.appMeta);
}
