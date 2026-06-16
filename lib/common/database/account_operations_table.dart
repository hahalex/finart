// Файл: lib/common/database/account_operations_table.dart.
// Назначение: описывает таблицы Drift и структуру локальной базы данных.

import 'package:drift/drift.dart';

class AccountOperationsTable extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  TextColumn get plannedPaymentId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
