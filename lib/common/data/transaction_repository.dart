import '../models/transaction_model.dart';

/// Репозиторий операций.
/// Временное in-memory хранилище.
/// Позже будет заменено на SQLite + API.
class TransactionRepository {
  TransactionRepository._internal();

  static final TransactionRepository _instance =
      TransactionRepository._internal();

  factory TransactionRepository() => _instance;

  final List<TransactionModel> _transactions = [];

  /// Получить все операции
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  /// Добавить операцию
  void add(TransactionModel transaction) {
    _transactions.insert(0, transaction);
  }

  /// Все расходы
  List<TransactionModel> get expenses =>
      _transactions.where((t) => t.isExpense).toList();

  /// Все доходы
  List<TransactionModel> get incomes =>
      _transactions.where((t) => !t.isExpense).toList();
}
