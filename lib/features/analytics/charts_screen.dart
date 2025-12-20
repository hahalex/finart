import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../analytics/providers/analytics_provider.dart';
import '../transactions/providers/categories_provider.dart';
import 'widgets/expenses_chart_placeholder.dart';
import 'widgets/category_expense_tile.dart';
import 'widgets/category_expenses_pie_chart.dart'; // <-- импорт PieChart

/// Экран "Графики"
class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyExpenses = ref.watch(monthlyExpensesFilteredProvider);
    final categoryExpenses = ref.watch(categoryExpensesProvider);
    final categories = ref.watch(categoriesProvider);

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.yellow.shade700,
    ];

    final categoryColors = <String, Color>{};

    for (var i = 0; i < categoryExpenses.length; i++) {
      categoryColors[categoryExpenses[i].categoryId] =
          colors[i % colors.length];
    }

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

          /// График по месяцам
          ExpensesChartPlaceholder(data: monthlyExpenses),
          const SizedBox(height: 16),

          /// Кнопки выбора периода и сброса
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      ref.read(selectedDateRangeProvider.notifier).state =
                          picked;
                    }
                  },
                  child: const Text('Выбрать период'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                ),
                onPressed: () {
                  ref.read(selectedDateRangeProvider.notifier).state = null;
                },
                child: const Text('Сбросить'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// PieChart по категориям
          CategoryExpensesPieChart(
            expenses: categoryExpenses,
            categoryColors: categoryColors,
          ),
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
            final color = categoryColors[expense.categoryId] ?? Colors.grey;

            return CategoryExpenseTile(
              expense: expense,
              categoryName: category?.name ?? 'Неизвестно',
              color: color, // добавляем поле color в Tile
            );
          }),
        ],
      ),
    );
  }
}
