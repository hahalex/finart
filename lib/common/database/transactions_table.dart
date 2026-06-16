// Файл: lib/common/database/transactions_table.dart.
// Назначение: описывает таблицы Drift и структуру локальной базы данных.

import 'package:drift/drift.dart';

/// Таблица финансовых операций.
class TransactionsTable extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text()();
  TextColumn get accountId => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isExpense => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
