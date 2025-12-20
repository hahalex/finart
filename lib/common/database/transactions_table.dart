import 'package:drift/drift.dart';

/// Таблица финансовых операций (доходы и расходы)
class TransactionsTable extends Table {
  /// Уникальный идентификатор операции
  TextColumn get id => text()();

  /// Сумма операции
  RealColumn get amount => real()();

  /// ID категории
  TextColumn get categoryId => text()();

  /// Описание (необязательно)
  TextColumn get description => text().nullable()();

  /// Дата и время создания
  DateTimeColumn get createdAt => dateTime()();

  /// Расход или доход
  BoolColumn get isExpense => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
