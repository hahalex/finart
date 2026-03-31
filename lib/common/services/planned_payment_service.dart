import 'dart:developer';

// ✅ ТОЛЬКО этот импорт — НЕ .g.dart!
import '../database/app_database.dart';
import '../models/planned_payment_model.dart';
import '../models/transaction_model.dart';
import '../repositories/planned_repository.dart';
import '../repositories/transactions_repository.dart';

/// Сервис обработки запланированных платежей
class PlannedPaymentService {
  final PlannedRepository _plannedRepo;
  final TransactionsRepository _transactionsRepo;
  final AppDatabase _db;

  PlannedPaymentService({
    required PlannedRepository plannedRepository,
    required TransactionsRepository transactionsRepository,
    required AppDatabase database,
  }) : _plannedRepo = plannedRepository,
       _transactionsRepo = transactionsRepository,
       _db = database;

  /// Основная логика: проверить и обработать "созревшие" платежи
  Future<void> processDuePayments() async {
    log('🔄 PlannedPaymentService: проверка запланированных платежей...');

    final now = DateTime.now();
    final duePayments = await _plannedRepo.getDuePayments(until: now);

    if (duePayments.isEmpty) {
      log('✅ Нет платежей для обработки');
      return;
    }

    log('📋 Найдено платежей для обработки: ${duePayments.length}');

    for (final payment in duePayments) {
      try {
        await _processSinglePayment(payment, now);
        log('✅ Обработан: ${payment.title}');
      } catch (e, stack) {
        log('❌ Ошибка при обработке ${payment.title}: $e', stackTrace: stack);
      }
    }

    log('🎉 Обработка завершена');
  }

  /// Обработка одного запланированного платежа
  Future<void> _processSinglePayment(
    PlannedPaymentModel payment,
    DateTime now,
  ) async {
    // 1. Создаём реальную транзакцию
    final transaction = TransactionModel(
      id: 'txn_${payment.id}_${now.millisecondsSinceEpoch}',
      amount: payment.amount,
      categoryId: payment.categoryId,
      description: 'Авто: ${payment.title}',
      createdAt: now,
      isExpense: payment.isExpense,
    );

    await _transactionsRepo.insertTransaction(transaction);
    log('💸 Создана транзакция: ${transaction.description}');

    // 2. Если платёж повторяющийся — обновляем дату следующего
    if (payment.recurrence != 'none') {
      final nextDate = _calculateNextDate(
        payment.startDate,
        payment.recurrence,
      );

      await _plannedRepo.updatePlannedPayment(
        payment.copyWith(startDate: nextDate),
      );
      log('📅 Следующая дата для ${payment.title}: $nextDate');
    } else {
      // 3. Если одноразовый — деактивируем после исполнения
      await _plannedRepo.deactivatePlannedPayment(payment.id);
      log('🔕 Деактивирован одноразовый платёж: ${payment.title}');
    }
  }

  /// Расчёт следующей даты на основе периодичности
  DateTime _calculateNextDate(DateTime current, String recurrence) {
    switch (recurrence) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(current.year, current.month + 1, current.day);
      case 'yearly':
        return DateTime(current.year + 1, current.month, current.day);
      default:
        return current;
    }
  }
}
