// Файл: lib/common/models/transaction_model.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

/// Модель финансовой операции.
class TransactionModel {
  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.createdAt,
    required this.isExpense,
    this.accountId,
    this.description,
  });

  final String id;
  final double amount;
  final String categoryId;
  final String? accountId;
  final String? description;
  final DateTime createdAt;
  final bool isExpense;
}
