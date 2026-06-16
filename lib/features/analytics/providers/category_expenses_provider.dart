// Файл: lib/features/analytics/providers/category_expenses_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/providers/transactions_notifier.dart';
import '../domain/analytics_calculator.dart';
import '../domain/analytics_models.dart';

/// Расходы по категориям
final categoryExpensesProvider = Provider<List<CategoryExpenseData>>((ref) {
  final transactions = ref.watch(transactionsProvider);

  return AnalyticsCalculator.expensesByCategory(transactions);
});
