import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../common/models/transaction_model.dart';

/// Провайдер списка финансовых операций
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>(
      (ref) => TransactionsNotifier(),
    );

/// Управляет списком операций (доходы и расходы)
class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionsNotifier() : super([]);

  final _uuid = const Uuid();

  /// Добавить новую операцию
  void addTransaction({
    required double amount,
    required String categoryId,
    required bool isExpense,
    String? description,
  }) {
    final transaction = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      categoryId: categoryId,
      isExpense: isExpense,
      createdAt: DateTime.now(),
      description: description,
    );

    state = [...state, transaction];
  }

  /// Удалить операцию (на будущее)
  void removeTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  /// Очистить все операции (debug)
  void clear() {
    state = [];
  }
}
