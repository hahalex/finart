import 'app_database.dart';
import 'planned_payments_table.dart';

/// Тестовая функция для проверки таблицы planned_payments
/// Запускается вручную из main.dart при отладке
Future<void> testPlannedPayments(AppDatabase db) async {
  try {
    print('🧪 Запуск теста planned_payments...');

    // 1. Вставляем тестовую запись
    await db
        .into(db.plannedPaymentsTable)
        .insert(
          PlannedPaymentsTableCompanion.insert(
            id: 'test_${DateTime.now().millisecondsSinceEpoch}', // уникальный ID
            title: 'Тестовая подписка',
            amount: 299.0,
            categoryId:
                'food', // ⚠️ Убедись, что такая категория уже есть в БД!
            isExpense: true,
            startDate: DateTime.now().add(const Duration(days: 3)),
            recurrence: 'monthly',
            // userId пока null, пока нет авторизации
          ),
        );
    print('✅ Запись вставлена');

    // 2. Читаем все записи
    final payments = await db.select(db.plannedPaymentsTable).get();
    print('✅ Найдено записей: ${payments.length}');

    for (final p in payments) {
      print(
        '   📌 ${p.title}: ${p.amount}₽, ${p.recurrence}, активен: ${p.isActive}',
      );
    }

    // 3. (Опционально) Удаляем тестовые записи после проверки
    // await (db.delete(db.plannedPaymentsTable)
    //   ..where((t) => t.id.startsWith('test_'))).go();
    // print('🧹 Тестовые данные удалены');
  } catch (e, stack) {
    print('❌ Ошибка в тесте: $e');
    print('Stack: $stack');
    rethrow;
  }
}
