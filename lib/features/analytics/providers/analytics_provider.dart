import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transactions_notifier.dart';
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
