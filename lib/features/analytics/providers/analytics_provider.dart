import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers/categories_provider.dart';
import '../../transactions/providers/transactions_notifier.dart';
import '../widgets/expenses_chart_placeholder.dart';
import '../domain/analytics_calculator.dart';
import '../domain/analytics_models.dart';

// ============================================================================
// 📊 ENUMS ДЛЯ УПРАВЛЕНИЯ АНАЛИТИКОЙ
// ============================================================================

enum AnalyticsType { expense, income }

enum AnalyticsPeriod { day, week, month }

enum CategoryDisplayMode { parentOnly, subcategoriesOnly, all }

// ============================================================================
// 🎛 STATE PROVIDERS (UI FILTERS)
// ============================================================================

/// Доходы / Расходы
final analyticsTypeProvider = StateProvider<AnalyticsType>(
  (ref) => AnalyticsType.expense,
);

/// День / Неделя / Месяц
final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>(
  (ref) => AnalyticsPeriod.week,
);

/// Родительские / Подкатегории / Все
final categoryDisplayModeProvider = StateProvider<CategoryDisplayMode>(
  (ref) => CategoryDisplayMode.all,
);

/// Выбранный период дат
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// ============================================================================
// 📈 ОСНОВНЫЕ ДАННЫЕ ДЛЯ ГРАФИКА
// ============================================================================

final chartDataProvider = Provider<List<ChartPoint>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final type = ref.watch(analyticsTypeProvider);
  final period = ref.watch(analyticsPeriodProvider);
  final range = ref.watch(selectedDateRangeProvider);

  final filtered = transactions.where((t) {
    final matchesType = type == AnalyticsType.expense
        ? t.isExpense
        : !t.isExpense;

    final matchesRange =
        range == null ||
        (!t.createdAt.isBefore(range.start) && !t.createdAt.isAfter(range.end));

    return matchesType && matchesRange;
  }).toList();

  switch (period) {
    case AnalyticsPeriod.day:
      return AnalyticsCalculator.expensesByDay(filtered);

    case AnalyticsPeriod.week:
      return AnalyticsCalculator.expensesByWeek(filtered);

    case AnalyticsPeriod.month:
      return AnalyticsCalculator.expensesByMonth(filtered);
  }
});

// ============================================================================
// 🥧 PIE / СПИСОК КАТЕГОРИЙ
// ============================================================================

final categoryExpensesProvider = Provider<List<CategoryExpenseData>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final categories = ref.watch(allCategoriesProvider).value ?? [];

  final analyticsType = ref.watch(analyticsTypeProvider);

  final displayMode = ref.watch(categoryDisplayModeProvider);

  final range = ref.watch(selectedDateRangeProvider);

  // 1. фильтр по типу
  var filtered = transactions.where((tx) {
    final matchesType = analyticsType == AnalyticsType.expense
        ? tx.isExpense
        : !tx.isExpense;

    if (!matchesType) return false;

    if (range != null) {
      if (tx.createdAt.isBefore(range.start)) {
        return false;
      }

      if (tx.createdAt.isAfter(range.end)) {
        return false;
      }
    }

    return true;
  }).toList();

  // 2. фильтр по категориям
  final allowedCategoryIds = categories
      .where((category) {
        switch (displayMode) {
          case CategoryDisplayMode.all:
            return true;

          case CategoryDisplayMode.parentOnly:
            return !category.isSubcategory;

          case CategoryDisplayMode.subcategoriesOnly:
            return category.isSubcategory;
        }
      })
      .map((e) => e.id)
      .toSet();

  filtered = filtered
      .where((tx) => allowedCategoryIds.contains(tx.categoryId))
      .toList();

  // 3. группировка по категориям
  return AnalyticsCalculator.expensesByCategory(filtered);
});

// ============================================================================
// 🏆 ТОП КАТЕГОРИЯ
// ============================================================================

final topCategoryNameProvider = Provider<String?>((ref) {
  final expenses = ref.watch(categoryExpensesProvider);

  final categories = ref.watch(allCategoriesProvider).value ?? [];

  if (expenses.isEmpty) return null;

  final top = expenses.reduce((a, b) => a.total > b.total ? a : b);

  final category = categories.firstWhereOrNull((c) => c.id == top.categoryId);

  return category?.name;
});

// ============================================================================
// 🏆 ТОП 3 КАТЕГОРИИ
// ============================================================================

final top3CategoryNamesProvider = Provider<List<String>>((ref) {
  final expenses = ref.watch(categoryExpensesProvider);

  final categories = ref.watch(allCategoriesProvider).value ?? [];

  if (expenses.isEmpty) return [];

  final sorted = [...expenses]..sort((a, b) => b.total.compareTo(a.total));

  return sorted.take(3).map((expense) {
    final category = categories.firstWhereOrNull(
      (c) => c.id == expense.categoryId,
    );

    return category?.name ?? 'Неизвестно';
  }).toList();
});

// ============================================================================
// 📊 ПРОЦЕНТ ТОП КАТЕГОРИИ
// ============================================================================

final topCategoryPercentProvider = Provider<double?>((ref) {
  final expenses = ref.watch(categoryExpensesProvider);

  if (expenses.isEmpty) return null;

  final total = expenses.fold<double>(0, (sum, e) => sum + e.total);

  final top = expenses.reduce((a, b) => a.total > b.total ? a : b);

  return total > 0 ? (top.total / total * 100).clamp(0, 100) : 0;
});
