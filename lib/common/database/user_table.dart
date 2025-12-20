import 'package:drift/drift.dart';

/// Таблица для хранения информации о пользователе
class UserTable extends Table {
  TextColumn get id => text()(); // Для будущей авторизации
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
