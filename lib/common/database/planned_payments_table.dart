import 'package:drift/drift.dart';

/// Таблица запланированных/повторяющихся платежей
class PlannedPaymentsTable extends Table {
  /// Уникальный ID (текстовый, как в других таблицах)
  TextColumn get id => text()();

  /// ID пользователя (для будущей авторизации)
  TextColumn get userId => text().nullable()();

  /// Название платежа (например, "Подписка Яндекс.Плюс")
  TextColumn get title => text()();

  /// Сумма
  RealColumn get amount => real()();

  /// ID категории (ссылка на CategoriesTable)
  TextColumn get categoryId => text()();

  /// Тип: true = расход, false = доход (как в TransactionsTable)
  BoolColumn get isExpense => boolean()();

  /// Дата первого/следующего платежа
  DateTimeColumn get startDate => dateTime()();

  /// Периодичность: 'none', 'daily', 'weekly', 'monthly', 'yearly'
  TextColumn get recurrence => text()();

  /// Активен ли платёж (можно "выключить", не удаляя)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Дата создания записи
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
