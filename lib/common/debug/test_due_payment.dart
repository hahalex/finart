// Файл: lib/common/debug/test_due_payment.dart.
// Назначение: используется для локальной отладки сценариев разработки.

// import '../database/app_database.dart';
// import '../models/planned_payment_model.dart';
// import '../repositories/planned_repository.dart';

// /// Тест: создаёт "созревший" платёж (дата в прошлом)
// /// Чтобы проверить авто-генерацию транзакций
// Future<void> testDuePayment(AppDatabase db) async {
//   print('🧪 Тест: создание "созревшего" платежа...');

//   final repo = PlannedRepository(db);

//   // Создаём платёж с датой ВЧЕРА (чтобы он сразу "созрел")
//   final duePayment = PlannedPaymentModel(
//     id: 'due_test_${DateTime.now().millisecondsSinceEpoch}',
//     title: '🔥 Тест авто-транзакции',
//     amount: 250.0,
//     categoryId:
//         'food', // ⚠️ ВАЖНО: используй ID категории, которая ТОЧНО есть в БД!
//     isExpense: true,
//     startDate: DateTime.now().subtract(const Duration(days: 1)), // ВЧЕРА!
//     recurrence: 'monthly', // Повторяющийся, чтобы проверить обновление даты
//     createdAt: DateTime.now(),
//   );

//   // 1. Вставляем запланированный платёж
//   await repo.insertPlannedPayment(duePayment);
//   print('✅ Вставлен "созревший" платёж: ${duePayment.title}');

//   // 2. (Опционально) Можно сразу запустить сервис для теста:
//   // Но лучше проверить через AppInitializer при запуске приложения
//   // final service = PlannedPaymentService(...);
//   // await service.processDuePayments();

//   // 3. Показываем, что записали
//   final all = await repo.getAllPlannedPayments();
//   final due = await repo.getDuePayments(until: DateTime.now());

//   print('📊 Всего запланированных: ${all.length}');
//   print('📊 Готовых к обработке: ${due.length}');

//   for (final p in due) {
//     print('   ⏰ ${p.title} — ${p.amount}₽ (дата: ${p.startDate})');
//   }
// }
