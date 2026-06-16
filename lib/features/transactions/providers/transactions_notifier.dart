// Файл: lib/features/transactions/providers/transactions_notifier.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../common/models/account_operation_model.dart';
import '../../../common/models/transaction_model.dart';
import '../../../common/providers/accounts_provider.dart';
import '../../../common/providers/accounts_repository_provider.dart';
import '../../../common/providers/notification_service_provider.dart';
import '../../../common/providers/notification_settings_provider.dart';
import '../../../common/providers/planned_repository_provider.dart';
import '../../../common/repositories/accounts_repository.dart';
import '../../../common/providers/transactions_repository_provider.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>((ref) {
      return TransactionsNotifier(ref);
    });

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionsNotifier(this.ref) : super([]) {
    _loadTransactions();
  }

  final Ref ref;

  Future<void> _loadTransactions() async {
    final repo = ref.read(transactionsRepositoryProvider);
    final transactions = await repo.getAllTransactions();
    state = transactions.where(_belongsToEntries).toList();
  }

  Future<void> reload() => _loadTransactions();

  Future<void> addTransaction({
    required double amount,
    required String categoryId,
    required bool isExpense,
    String? accountId,
    String? description,
    DateTime? createdAt,
  }) async {
    final transaction = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: categoryId,
      accountId: accountId,
      createdAt: createdAt ?? DateTime.now(),
      isExpense: isExpense,
      description: description,
    );

    if (!_belongsToEntries(transaction)) {
      await _addAccountOnlyOperation(transaction);
      return;
    }

    final repo = ref.read(transactionsRepositoryProvider);
    await repo.insertTransaction(transaction);
    await _applyAccountDelta(transaction.accountId, _signedAmount(transaction));

    state = [...state, transaction];
    ref.invalidate(accountsProvider);
  }

  Future<void> removeTransaction(String id) async {
    final repo = ref.read(transactionsRepositoryProvider);
    final existing = state.firstWhereOrNull(
      (transaction) => transaction.id == id,
    );
    await repo.deleteTransaction(id);
    if (existing != null) {
      await _applyAccountDelta(existing.accountId, -_signedAmount(existing));
    }

    state = state.where((t) => t.id != id).toList();
    ref.invalidate(accountsProvider);
  }

  Future<void> editTransaction(TransactionModel updated) async {
    final repo = ref.read(transactionsRepositoryProvider);
    final existing = state.firstWhereOrNull(
      (transaction) => transaction.id == updated.id,
    );

    if (!_belongsToEntries(updated)) {
      if (existing != null) {
        await repo.deleteTransaction(existing.id);
        await _applyAccountDelta(existing.accountId, -_signedAmount(existing));
      }
      await _addAccountOnlyOperation(updated);
      state = state
          .where((transaction) => transaction.id != updated.id)
          .toList();
      ref.invalidate(accountsProvider);
      return;
    }

    await repo.updateTransaction(updated);
    if (existing != null) {
      await _applyAccountDelta(existing.accountId, -_signedAmount(existing));
    }
    await _applyAccountDelta(updated.accountId, _signedAmount(updated));

    state = [
      for (final transaction in state)
        if (transaction.id == updated.id) updated else transaction,
    ];
    ref.invalidate(accountsProvider);
  }

  double _signedAmount(TransactionModel transaction) {
    return transaction.isExpense ? -transaction.amount : transaction.amount;
  }

  Future<void> _applyAccountDelta(String? accountId, double delta) async {
    if (accountId == null || delta == 0) return;
    await ref
        .read(accountsRepositoryProvider)
        .adjustAccountBalance(accountId, delta);
  }

  bool _belongsToEntries(TransactionModel transaction) {
    return transaction.accountId == null ||
        transaction.accountId == AccountsRepository.mainAccountId;
  }

  Future<void> _addAccountOnlyOperation(TransactionModel transaction) async {
    final accountId = transaction.accountId;
    if (accountId == null) return;
    final type = transaction.isExpense
        ? AccountOperationType.withdraw
        : AccountOperationType.topUp;
    await ref
        .read(accountsRepositoryProvider)
        .applyManualOperation(
          accountId: accountId,
          type: type,
          amount: transaction.amount,
          note: transaction.description,
          createdAt: transaction.createdAt,
        );
    ref.invalidate(accountsProvider);
    ref.invalidate(accountOperationsProvider(accountId));
    await _syncAccountNotifications();
  }

  Future<void> _syncAccountNotifications() async {
    final settings = ref.read(notificationSettingsProvider);
    if (!settings.creditPaymentDayEnabled &&
        !settings.creditDebtClosedEnabled) {
      return;
    }
    final accounts = await ref
        .read(accountsRepositoryProvider)
        .getAllAccounts(includeArchived: true);
    final plannedPayments = await ref
        .read(plannedRepositoryProvider)
        .getAllPlannedPayments();
    await ref
        .read(notificationServiceProvider)
        .syncAll(
          settings: settings,
          plannedPayments: plannedPayments
              .where((payment) => payment.isActive)
              .toList(),
          accounts: accounts,
        );
  }
}
