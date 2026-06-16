// Файл: lib/common/database/accounts_table.dart.
// Назначение: описывает таблицы Drift и структуру локальной базы данных.

import 'package:drift/drift.dart';

class AccountsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  RealColumn get balance => real().withDefault(const Constant(0))();
  RealColumn get creditLimit => real().nullable()();
  RealColumn get interestRateAnnual => real().nullable()();
  IntColumn get billingDay => integer().nullable()();
  IntColumn get paymentDay => integer().nullable()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
