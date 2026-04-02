import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/models/recommendation_model.dart';
import '../../../common/providers/categories_provider.dart';
import '../../transactions/providers/transactions_notifier.dart';
import '../widgets/expenses_chart_placeholder.dart';
import '../domain/analytics_calculator.dart';
import '../domain/analytics_models.dart';

// ============================================================================
// 📊 ENUMS
// ============================================================================

enum AnalyticsType { expense, income }

enum AnalyticsPeriod { day, week, month }

enum CategoryDisplayMode { parentOnly, subcategoriesOnly, all }

/// Новый период для страницы отчетов
enum ReportPeriod { year, halfYear, quarter, currentMonth, custom }

// ============================================================================
// 🎛 UI STATE
// ============================================================================

final analyticsTypeProvider = StateProvider<AnalyticsType>(
  (ref) => AnalyticsType.expense,
);

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>(
  (ref) => AnalyticsPeriod.week,
);

final categoryDisplayModeProvider = StateProvider<CategoryDisplayMode>(
  (ref) => CategoryDisplayMode.all,
);

/// Новый выбранный период для отчётов
final selectedReportPeriodProvider = StateProvider<ReportPeriod>(
  (ref) => ReportPeriod.quarter,
);

/// Кастомный диапазон через календарь
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// ============================================================================
// 📅 EFFECTIVE DATE RANGE
// ============================================================================

final effectiveReportRangeProvider = Provider<DateTimeRange>((ref) {
  final selectedPeriod = ref.watch(selectedReportPeriodProvider);
  final customRange = ref.watch(selectedDateRangeProvider);

  final now = DateTime.now();

  DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  switch (selectedPeriod) {
    case ReportPeriod.year:
      return DateTimeRange(
        start: startOfDay(DateTime(now.year - 1, now.month, now.day)),
        end: endOfDay(now),
      );

    case ReportPeriod.halfYear:
      return DateTimeRange(
        start: startOfDay(DateTime(now.year, now.month - 6, now.day)),
        end: endOfDay(now),
      );

    case ReportPeriod.quarter:
      return DateTimeRange(
        start: startOfDay(DateTime(now.year, now.month - 3, now.day)),
        end: endOfDay(now),
      );

    case ReportPeriod.currentMonth:
      return DateTimeRange(
        start: startOfDay(DateTime(now.year, now.month, 1)),
        end: endOfDay(now),
      );

    case ReportPeriod.custom:
      return customRange ??
          DateTimeRange(
            start: startOfDay(DateTime(now.year, now.month - 3, now.day)),
            end: endOfDay(now),
          );
  }
});

// ============================================================================
// 📈 FILTERED TRANSACTIONS
// ============================================================================

final filteredTransactionsProvider = Provider((ref) {
  final transactions = ref.watch(transactionsProvider);
  final type = ref.watch(analyticsTypeProvider);
  final range = ref.watch(effectiveReportRangeProvider);

  return transactions.where((tx) {
    final matchesType = type == AnalyticsType.expense
        ? tx.isExpense
        : !tx.isExpense;

    final matchesRange =
        !tx.createdAt.isBefore(range.start) && !tx.createdAt.isAfter(range.end);

    return matchesType && matchesRange;
  }).toList();
});

// ============================================================================
// 📊 CHART DATA
// ============================================================================

final chartDataProvider = Provider<List<ChartPoint>>((ref) {
  final filtered = ref.watch(filteredTransactionsProvider);
  final period = ref.watch(analyticsPeriodProvider);

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
// 🥧 CATEGORY EXPENSES
// ============================================================================

final categoryExpensesProvider = Provider<List<CategoryExpenseData>>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  final categories = ref.watch(allCategoriesProvider).value ?? [];
  final displayMode = ref.watch(categoryDisplayModeProvider);

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

  final filtered = transactions
      .where((tx) => allowedCategoryIds.contains(tx.categoryId))
      .toList();

  return AnalyticsCalculator.expensesByCategory(filtered);
});

// ============================================================================
// 💰 TOTALS (теперь по выбранному периоду)
// ============================================================================

final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final range = ref.watch(effectiveReportRangeProvider);

  return AnalyticsCalculator.totalIncome(
    transactions,
    from: range.start,
    to: range.end,
  );
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final range = ref.watch(effectiveReportRangeProvider);

  return AnalyticsCalculator.totalExpense(
    transactions,
    from: range.start,
    to: range.end,
  );
});

final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);

  return income - expense;
});

// ============================================================================
// 🏆 TOP CATEGORY
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
// 🏆 TOP 3
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
// 📊 TOP CATEGORY PERCENT
// ============================================================================

final topCategoryPercentProvider = Provider<double?>((ref) {
  final expenses = ref.watch(categoryExpensesProvider);

  if (expenses.isEmpty) return null;

  final total = expenses.fold<double>(0, (sum, e) => sum + e.total);

  final top = expenses.reduce((a, b) => a.total > b.total ? a : b);

  return total > 0 ? (top.total / total * 100).clamp(0, 100) : 0;
});

// ============================================================================
// 💡 RECOMMENDATIONS
// ============================================================================

final recommendationsProvider = Provider<List<Recommendation>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final categories = ref.watch(allCategoriesProvider).value ?? [];
  final categoryExpenses = ref.watch(categoryExpensesProvider);
  final range = ref.watch(effectiveReportRangeProvider);

  return AnalyticsCalculator.generateRecommendations(
    transactions,
    categoryExpenses,
    categories,
    from: range.start,
    to: range.end,
  );
});
