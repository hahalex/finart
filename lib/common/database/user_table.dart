// Файл: lib/common/database/user_table.dart.
// Назначение: описывает таблицы Drift и структуру локальной базы данных.

import 'package:drift/drift.dart';

class UserTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get avatarPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
