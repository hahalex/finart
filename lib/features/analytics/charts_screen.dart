import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../analytics/providers/analytics_provider.dart';
import '../transactions/providers/categories_provider.dart';
import 'widgets/expenses_chart_placeholder.dart';
import 'widgets/category_expense_tile.dart';

/// Экран "Графики"
class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyExpenses = ref.watch(monthlyExpensesProvider);
    final categoryExpenses = ref.watch(categoryExpensesProvider);
    final categories = ref.watch(categoriesProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Заголовок
          Text(
            'Расходы по месяцам',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          /// График
          ExpensesChartPlaceholder(data: monthlyExpenses),

          const SizedBox(height: 24),

          /// Подзаголовок
          Text(
            'Расходы по категориям',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          /// Список категорий
          ...categoryExpenses.map((expense) {
            final category = categories.firstWhereOrNull(
              (c) => c.id == expense.categoryId,
            );

            return CategoryExpenseTile(
              expense: expense,
              categoryName: category?.name ?? 'Неизвестно',
            );
          }),
        ],
      ),
    );
  }
}
