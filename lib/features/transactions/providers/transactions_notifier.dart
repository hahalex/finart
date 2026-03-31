import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../common/models/transaction_model.dart';
import '../../../common/providers/transactions_repository_provider.dart';

/// Provider операций
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>((ref) {
      return TransactionsNotifier(ref);
    });

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  final Ref ref;

  TransactionsNotifier(this.ref) : super([]) {
    _loadTransactions();
  }

  /// Загрузка операций из БД
  Future<void> _loadTransactions() async {
    final repo = ref.read(transactionsRepositoryProvider);
    final transactions = await repo.getAllTransactions();
    state = transactions;
  }

  /// Добавление операции
  Future<void> addTransaction({
    required double amount,
    required String categoryId,
    required bool isExpense,
    String? description,
  }) async {
    final transaction = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      isExpense: isExpense,
      description: description,
    );

    final repo = ref.read(transactionsRepositoryProvider);
    await repo.insertTransaction(transaction);

    // Обновляем состояние
    state = [...state, transaction];
  }

  /// Удаление операции
  Future<void> removeTransaction(String id) async {
    final repo = ref.read(transactionsRepositoryProvider);
    await repo.deleteTransaction(id);

    state = state.where((t) => t.id != id).toList();
  }

  /// Редактирование операции
  Future<void> editTransaction(TransactionModel updated) async {
    final repo = ref.read(transactionsRepositoryProvider);

    await repo.updateTransaction(updated);

    state = [
      for (final transaction in state)
        if (transaction.id == updated.id) updated else transaction,
    ];
  }
}
