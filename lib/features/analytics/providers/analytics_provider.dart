import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transactions_notifier.dart';
import '../../transactions/providers/categories_provider.dart';
import '../domain/analytics_calculator.dart';
import '../domain/analytics_models.dart';

/// Расходы по месяцам
final monthlyExpensesProvider = Provider<List<MonthlyExpenseData>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return AnalyticsCalculator.expensesByMonth(transactions);
});

/// Расходы по категориям
final categoryExpensesProvider = Provider<List<CategoryExpenseData>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return AnalyticsCalculator.expensesByCategory(transactions);
});

/// Период для фильтрации
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

/// Расходы по месяцам за выбранный период
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

/// Расходы по категориям за выбранный период
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

final topExpenseCategoryNameProvider = Provider<String?>((ref) {
  final expenses = ref.watch(categoryExpensesFilteredProvider);
  final categories = ref.watch(categoriesProvider);

  if (expenses.isEmpty) return null;

  final top = expenses.reduce((a, b) => a.total > b.total ? a : b);

  final category = categories.firstWhereOrNull((c) => c.id == top.categoryId);

  return category?.name;
});
