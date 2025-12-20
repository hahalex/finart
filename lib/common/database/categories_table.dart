import 'package:drift/drift.dart';

/// Таблица категорий доходов и расходов
class CategoriesTable extends Table {
  /// Уникальный идентификатор категории
  TextColumn get id => text()();

  /// Название категории
  TextColumn get name => text()();

  /// Код иконки (IconData.codePoint)
  IntColumn get iconCode => integer()();

  /// Является ли категорией расхода
  BoolColumn get isExpense => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
