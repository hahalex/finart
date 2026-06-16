// Файл: lib/common/repositories/planned_repository.dart.
// Назначение: изолирует доступ к данным и операции чтения/записи в локальное хранилище.

import 'package:drift/drift.dart'; // Для Value

import '../database/app_database.dart'; // ✅ Только этот импорт! Не .g.dart
import '../models/planned_payment_model.dart';

class PlannedRepository {
  final AppDatabase _db;

  PlannedRepository(this._db);

  Future<List<PlannedPaymentModel>> getAllPlannedPayments() async {
    final rows = await _db.select(_db.plannedPaymentsTable).get();
    return rows
        .map(
          (row) => PlannedPaymentModel(
            id: row.id,
            userId: row.userId,
            title: row.title,
            amount: row.amount,
            categoryId: row.categoryId,
            accountId: row.accountId,
            paymentType: _paymentTypeFromDb(row.paymentType),
            isExpense: row.isExpense,
            startDate: row.startDate,
            recurrence: row.recurrence,
            isActive: row.isActive,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  Future<List<PlannedPaymentModel>> getDuePayments({DateTime? until}) async {
    var query = _db.select(_db.plannedPaymentsTable)
      ..where((t) => t.isActive.equals(true));

    if (until != null) {
      query = query..where((t) => t.startDate.isSmallerOrEqualValue(until));
    }

    final rows = await query.get();
    return rows
        .map(
          (row) => PlannedPaymentModel(
            id: row.id,
            userId: row.userId,
            title: row.title,
            amount: row.amount,
            categoryId: row.categoryId,
            accountId: row.accountId,
            paymentType: _paymentTypeFromDb(row.paymentType),
            isExpense: row.isExpense,
            startDate: row.startDate,
            recurrence: row.recurrence,
            isActive: row.isActive,
            createdAt: row.createdAt,
          ),
        )
        .toList();
  }

  Future<void> insertPlannedPayment(PlannedPaymentModel payment) async {
    await _db
        .into(_db.plannedPaymentsTable)
        .insert(
          PlannedPaymentsTableCompanion(
            id: Value(payment.id),
            userId: payment.userId != null
                ? Value(payment.userId)
                : const Value.absent(),
            title: Value(payment.title),
            amount: Value(payment.amount),
            categoryId: Value(payment.categoryId),
            accountId: Value(payment.accountId),
            paymentType: Value(payment.paymentType.name),
            isExpense: Value(payment.isExpense),
            startDate: Value(payment.startDate),
            recurrence: Value(payment.recurrence),
            isActive: Value(payment.isActive),
            createdAt: Value(payment.createdAt),
          ),
        );
  }

  Future<void> updatePlannedPayment(PlannedPaymentModel payment) async {
    await (_db.update(
      _db.plannedPaymentsTable,
    )..where((t) => t.id.equals(payment.id))).write(
      PlannedPaymentsTableCompanion(
        title: Value(payment.title),
        amount: Value(payment.amount),
        categoryId: Value(payment.categoryId),
        accountId: Value(payment.accountId),
        paymentType: Value(payment.paymentType.name),
        isExpense: Value(payment.isExpense),
        startDate: Value(payment.startDate),
        recurrence: Value(payment.recurrence),
        isActive: Value(payment.isActive),
      ),
    );
  }

  Future<void> deletePlannedPayment(String id) async {
    await (_db.delete(
      _db.plannedPaymentsTable,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<void> deactivatePlannedPayment(String id) async {
    await (_db.update(_db.plannedPaymentsTable)..where((t) => t.id.equals(id)))
        .write(const PlannedPaymentsTableCompanion(isActive: Value(false)));
  }

  PlannedPaymentType _paymentTypeFromDb(String value) {
    return PlannedPaymentType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => PlannedPaymentType.standard,
    );
  }
}
