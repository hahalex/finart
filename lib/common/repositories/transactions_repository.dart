// Файл: lib/common/repositories/transactions_repository.dart.
// Назначение: изолирует доступ к данным и операции чтения/записи в локальное хранилище.

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/transaction_model.dart';

/// Репозиторий для работы с финансовыми операциями
class TransactionsRepository {
  final AppDatabase _db;

  TransactionsRepository(this._db);

  /// Получить все операции
  Future<List<TransactionModel>> getAllTransactions() async {
    final rows = await _db.select(_db.transactionsTable).get();

    return rows.map((row) {
      return TransactionModel(
        id: row.id,
        amount: row.amount,
        categoryId: row.categoryId,
        accountId: row.accountId,
        description: row.description,
        createdAt: row.createdAt,
        isExpense: row.isExpense,
      );
    }).toList();
  }

  /// Добавить операцию
  Future<void> insertTransaction(TransactionModel transaction) async {
    await _db
        .into(_db.transactionsTable)
        .insert(
          TransactionsTableCompanion.insert(
            id: transaction.id,
            amount: transaction.amount,
            categoryId: transaction.categoryId,
            accountId: Value(transaction.accountId),
            description: Value(transaction.description),
            createdAt: transaction.createdAt,
            isExpense: transaction.isExpense,
          ),
        );
  }

  /// Удалить операцию
  Future<void> deleteTransaction(String id) async {
    await (_db.delete(
      _db.transactionsTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Обновить операцию
  Future<void> updateTransaction(TransactionModel transaction) async {
    await (_db.update(
      _db.transactionsTable,
    )..where((tbl) => tbl.id.equals(transaction.id))).write(
      TransactionsTableCompanion(
        amount: Value(transaction.amount),
        categoryId: Value(transaction.categoryId),
        accountId: Value(transaction.accountId),
        description: Value(transaction.description),
        isExpense: Value(transaction.isExpense),
        createdAt: Value(transaction.createdAt),
      ),
    );
  }
}
