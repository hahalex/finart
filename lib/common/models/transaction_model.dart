/// Модель финансовой операции (доход или расход)
class TransactionModel {
  /// Уникальный идентификатор операции
  final String id;

  /// Сумма операции
  final double amount;

  /// Категория
  final String categoryId;

  /// Описание (необязательно)
  final String? description;

  /// Дата и время создания
  final DateTime createdAt;

  /// Расход или доход
  final bool isExpense;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.createdAt,
    required this.isExpense,
    this.description,
  });
}
