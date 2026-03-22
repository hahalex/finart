import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/categories_repository_provider.dart';
import '../providers/planned_payment_service_provider.dart'; // ✅ Новый импорт
import '../data/default_categories.dart';
import 'main_navigation.dart';

/// Виджет инициализации приложения
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _initializeApp(ref), // ✅ Переименовали метод
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Если была ошибка — показываем её в консоли, но не блокируем запуск
        if (snapshot.hasError) {
          debugPrint('⚠️ Ошибка при инициализации: ${snapshot.error}');
        }

        return const MainNavigation();
      },
    );
  }

  /// Полная инициализация приложения
  /// Вызывается один раз при старте
  Future<void> _initializeApp(WidgetRef ref) async {
    // 1️⃣ Инициализация стандартных категорий (твой существующий код)
    await _initCategories(ref);

    // 2️⃣ Обработка запланированных платежей (новый функционал)
    await _processPlannedPayments(ref);
  }

  /// Инициализация стандартных категорий
  Future<void> _initCategories(WidgetRef ref) async {
    try {
      final repo = ref.read(categoriesRepositoryProvider);
      final hasCategories = await repo.hasCategories();

      if (!hasCategories) {
        for (final category in defaultCategories) {
          await repo.insertCategory(category);
        }
        debugPrint('✅ Стандартные категории добавлены');
      }
    } catch (e) {
      debugPrint('⚠️ Ошибка при инициализации категорий: $e');
      // Не прерываем запуск приложения
    }
  }

  /// Обработка "созревших" запланированных платежей
  Future<void> _processPlannedPayments(WidgetRef ref) async {
    try {
      // Получаем сервис через провайдер
      final service = ref.read(plannedPaymentServiceProvider);

      // Запускаем обработку
      await service.processDuePayments();
    } catch (e, stack) {
      // ❗ Важно: не прерываем запуск приложения, если сервис упал
      debugPrint('⚠️ Ошибка в PlannedPaymentService: $e');
      debugPrintStack(stackTrace: stack);
    }
  }
}
