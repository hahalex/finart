import '../database/app_database.dart';
import '../models/planned_payment_model.dart';
import 'planned_repository.dart';

/// Быстрый тест репозитория
Future<void> testPlannedRepository(AppDatabase db) async {
  final repo = PlannedRepository(db);

  // 1. Вставляем
  final testPayment = PlannedPaymentModel(
    id: 'repo_test_${DateTime.now().millisecondsSinceEpoch}',
    title: 'Тест из репозитория',
    amount: 499.0,
    categoryId: 'entertainment', // ⚠️ убедись, что категория существует
    isExpense: true,
    startDate: DateTime.now().add(const Duration(days: 5)),
    recurrence: 'monthly',
    createdAt: DateTime.now(),
  );

  await repo.insertPlannedPayment(testPayment);
  print('✅ Вставлено через репозиторий');

  // 2. Читаем
  final all = await repo.getAllPlannedPayments();
  print('✅ Всего записей: ${all.length}');

  // 3. Фильтруем активные
  final active = await repo.getDuePayments(
    until: DateTime.now().add(const Duration(days: 10)),
  );
  print('✅ Активных в ближайшие 10 дней: ${active.length}');

  for (final p in active) {
    print(
      '   📌 ${p.title} — ${p.amount}₽ (${p.getNextPaymentDate().toIso8601String()})',
    );
  }
}
