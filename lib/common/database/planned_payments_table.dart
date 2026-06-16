// Файл: lib/common/database/planned_payments_table.dart.
// Назначение: описывает таблицы Drift и структуру локальной базы данных.

import 'package:drift/drift.dart';

/// Таблица запланированных и повторяющихся платежей.
class PlannedPaymentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text()();
  TextColumn get accountId => text().nullable()();
  TextColumn get paymentType =>
      text().withDefault(const Constant('standard'))();
  BoolColumn get isExpense => boolean()();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get recurrence => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
