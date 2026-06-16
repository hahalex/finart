// Файл: lib/common/services/planned_payment_service.dart.
// Назначение: содержит прикладной сервис с бизнес-логикой, фоновой обработкой или интеграциями.

import 'dart:developer';

import '../database/app_database.dart';
import '../models/planned_payment_model.dart';
import '../models/transaction_model.dart';
import '../models/account_operation_model.dart';
import '../repositories/accounts_repository.dart';
import '../repositories/planned_repository.dart';
import '../repositories/transactions_repository.dart';
import '../utils/recurrence_rule.dart';

class PlannedPaymentService {
  PlannedPaymentService({
    required PlannedRepository plannedRepository,
    required TransactionsRepository transactionsRepository,
    required AccountsRepository accountsRepository,
    required AppDatabase database,
  }) : _plannedRepo = plannedRepository,
       _transactionsRepo = transactionsRepository,
       _accountsRepo = accountsRepository,
       _db = database;

  final PlannedRepository _plannedRepo;
  final TransactionsRepository _transactionsRepo;
  final AccountsRepository _accountsRepo;
  final AppDatabase _db;

  Future<void> processDuePayments() async {
    log('PlannedPaymentService: checking due planned payments');

    final now = DateTime.now();
    final duePayments = await _plannedRepo.getDuePayments(until: now);
    if (duePayments.isEmpty) {
      log('PlannedPaymentService: no due payments');
      return;
    }

    for (final payment in duePayments) {
      try {
        await _processSinglePayment(payment, now);
      } catch (error, stack) {
        log(
          'PlannedPaymentService: failed to process ${payment.title}: $error',
          stackTrace: stack,
        );
      }
    }
  }

  Future<void> _processSinglePayment(
    PlannedPaymentModel payment,
    DateTime now,
  ) async {
    final rule = RecurrenceRule.parse(payment.recurrence);
    var dueDate = payment.startDate;
    var generatedCount = 0;

    await _db.transaction(() async {
      do {
        final isTransfer = payment.paymentType.isTransfer;
        final transaction = TransactionModel(
          id: 'txn_${payment.id}_${dueDate.millisecondsSinceEpoch}',
          amount: payment.amount,
          categoryId: payment.categoryId,
          accountId: AccountsRepository.mainAccountId,
          description: 'Auto: ${payment.title}',
          createdAt: dueDate,
          isExpense: isTransfer ? true : payment.isExpense,
        );

        await _transactionsRepo.insertTransaction(transaction);

        final linkedAccountId = payment.accountId;
        if (linkedAccountId != null &&
            linkedAccountId != AccountsRepository.mainAccountId) {
          final delta = isTransfer
              ? payment.amount
              : payment.isExpense
              ? payment.amount
              : -payment.amount;
          await _accountsRepo.adjustAccountBalance(linkedAccountId, delta);
          await _accountsRepo.addOperation(
            accountId: linkedAccountId,
            type: AccountOperationType.autoPayment,
            amount: payment.amount,
            note: payment.title,
            plannedPaymentId: payment.id,
            createdAt: dueDate,
          );
        }
        generatedCount++;

        if (rule.isOneTime) break;

        final nextDate = rule.nextAfter(dueDate);
        if (!nextDate.isAfter(dueDate)) break;
        dueDate = nextDate;
      } while (!dueDate.isAfter(now) && generatedCount < 366);

      if (rule.isOneTime) {
        await _plannedRepo.deactivatePlannedPayment(payment.id);
      } else {
        await _plannedRepo.updatePlannedPayment(
          payment.copyWith(startDate: dueDate),
        );
      }
    });

    log(
      'PlannedPaymentService: generated $generatedCount transactions for ${payment.title}',
    );
  }
}
