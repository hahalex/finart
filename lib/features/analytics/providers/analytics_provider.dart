import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers/categories_provider.dart';
import '../../transactions/providers/transactions_notifier.dart';
import '../domain/analytics_calculator.dart';
import '../domain/analytics_models.dart';

// ============================================================================
// 📊 АНАЛИТИКА: Провайдеры данных
// ============================================================================

/// 🔹 Расходы по месяцам
final monthlyExpensesProvider = Provider<List<MonthlyExpenseData>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return AnalyticsCalculator.expensesByMonth(transactions);
});

/// 🔹 Расходы по категориям
final categoryExpensesProvider = Provider<List<CategoryExpenseData>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return AnalyticsCalculator.expensesByCategory(transactions);
});

/// 🔹 Период для фильтрации
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// 🔹 Расходы по месяцам за выбранный период
final monthlyExpensesFilteredProvider = Provider<List<MonthlyExpenseData>>((
  ref,
) {
  final transactions = ref.watch(transactionsProvider);
  final range = ref.watch(selectedDateRangeProvider);
  return AnalyticsCalculator.expensesByMonthFiltered(
    transactions,
    from: range?.start,
    to: range?.end,
  );
});

/// 🔹 Расходы по категориям за выбранный период
final categoryExpensesFilteredProvider = Provider<List<CategoryExpenseData>>((
  ref,
) {
  final transactions = ref.watch(transactionsProvider);
  final range = ref.watch(selectedDateRangeProvider);
  return AnalyticsCalculator.expensesByCategoryFiltered(
    transactions,
    from: range?.start,
    to: range?.end,
  );
});

// ============================================================================
// 🏆 ТОП-КАТЕГОРИЯ: Исправленная версия (без AsyncNotifier)
// ============================================================================

/// 🔹 Название топ-категории расходов
///
/// Использует .value ?? [] для безопасного извлечения списка категорий из AsyncValue.
/// Если категории ещё не загружены — вернёт null (экран может показать "Загрузка...").
final topExpenseCategoryNameProvider = Provider<String?>((ref) {
  final expenses = ref.watch(categoryExpensesFilteredProvider);

  // 🔹 Извлекаем список категорий из AsyncValue
  // Если данные ещё не загружены (value == null) — используем пустой список
  final categories = ref.watch(allCategoriesProvider).value ?? [];

  if (expenses.isEmpty) return null;

  // Находим категорию с максимальными расходами
  final top = expenses.reduce((a, b) => a.total > b.total ? a : b);

  // Ищем название категории по ID
  final category = categories.firstWhereOrNull((c) => c.id == top.categoryId);

  return category?.name;
});

// ============================================================================
// 🔄 ДОПОЛНИТЕЛЬНЫЕ ПРОВАЙДЕРЫ (опционально)
// ============================================================================

/// 🔹 Топ-3 категории расходов (названия)
final top3ExpenseCategoryNamesProvider = Provider<List<String>>((ref) {
  final expenses = ref.watch(categoryExpensesFilteredProvider);
  final categories = ref.watch(allCategoriesProvider).value ?? [];

  if (expenses.isEmpty) return [];

  // Сортируем по убыванию суммы и берём топ-3
  final sorted = [...expenses]..sort((a, b) => b.total.compareTo(a.total));
  final top3 = sorted.take(3);

  return top3.map((expense) {
    final category = categories.firstWhereOrNull(
      (c) => c.id == expense.categoryId,
    );
    return category?.name ?? 'Неизвестно';
  }).toList();
});

/// 🔹 Процент расходов по топ-категории
final topExpenseCategoryPercentProvider = Provider<double?>((ref) {
  final expenses = ref.watch(categoryExpensesFilteredProvider);

  if (expenses.isEmpty) return null;

  final total = expenses.fold<double>(0, (sum, e) => sum + e.total);
  final top = expenses.reduce((a, b) => a.total > b.total ? a : b);

  return total > 0 ? (top.total / total * 100).clamp(0, 100) : 0;
});
