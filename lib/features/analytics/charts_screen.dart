import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../common/providers/categories_provider.dart';
import '../analytics/providers/analytics_provider.dart';
import 'widgets/expenses_chart_placeholder.dart';
import 'widgets/category_expense_tile.dart';
import 'widgets/category_expenses_pie_chart.dart';

/// Экран "Графики"
class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsType = ref.watch(analyticsTypeProvider);
    final period = ref.watch(analyticsPeriodProvider);
    final categoryMode = ref.watch(categoryDisplayModeProvider);

    final chartData = ref.watch(chartDataProvider);
    final categoryExpenses = ref.watch(categoryExpensesProvider);

    final categories = ref.watch(allCategoriesProvider).value ?? [];

    // ===========================
    // UI helpers
    // ===========================

    String getTitle() {
      final isExpense = analyticsType == AnalyticsType.expense;

      switch (period) {
        case AnalyticsPeriod.day:
          return isExpense ? 'Расходы по дням' : 'Доходы по дням';

        case AnalyticsPeriod.week:
          return isExpense ? 'Расходы по неделям' : 'Доходы по неделям';

        case AnalyticsPeriod.month:
          return isExpense ? 'Расходы по месяцам' : 'Доходы по месяцам';
      }
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
    ];

    final categoryColors = <String, Color>{};
    for (var i = 0; i < categoryExpenses.length; i++) {
      categoryColors[categoryExpenses[i].categoryId] =
          colors[i % colors.length];
    }

    // ===========================
    // UI
    // ===========================

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===========================
          // ДОХОДЫ / РАСХОДЫ
          // ===========================
          SegmentedButton<AnalyticsType>(
            segments: const [
              ButtonSegment(
                value: AnalyticsType.expense,
                label: Text('Расходы'),
              ),
              ButtonSegment(value: AnalyticsType.income, label: Text('Доходы')),
            ],
            selected: {analyticsType},
            onSelectionChanged: (value) {
              ref.read(analyticsTypeProvider.notifier).state = value.first;
            },
          ),

          const SizedBox(height: 16),

          // ===========================
          // ПЕРИОД (КНОПКА)
          // ===========================
          ElevatedButton(
            onPressed: () {
              final next = switch (period) {
                AnalyticsPeriod.day => AnalyticsPeriod.week,
                AnalyticsPeriod.week => AnalyticsPeriod.month,
                AnalyticsPeriod.month => AnalyticsPeriod.day,
              };

              ref.read(analyticsPeriodProvider.notifier).state = next;
            },
            child: Text(getTitle()),
          ),

          const SizedBox(height: 16),

          // ===========================
          // ГРАФИК
          // ===========================
          ExpensesChartPlaceholder(data: chartData),

          const SizedBox(height: 16),

          // ===========================
          // ВЫБОР ДАТ
          // ===========================
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
                  child: const Text('Период'),
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
                child: const Text('Сброс'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ===========================
          // ФИЛЬТР КАТЕГОРИЙ
          // ===========================
          SegmentedButton<CategoryDisplayMode>(
            segments: const [
              ButtonSegment(value: CategoryDisplayMode.all, label: Text('Все')),
              ButtonSegment(
                value: CategoryDisplayMode.parentOnly,
                label: Text('Категории'),
              ),
              ButtonSegment(
                value: CategoryDisplayMode.subcategoriesOnly,
                label: Text('Подкатегории'),
              ),
            ],
            selected: {categoryMode},
            onSelectionChanged: (value) {
              ref.read(categoryDisplayModeProvider.notifier).state =
                  value.first;
            },
          ),

          const SizedBox(height: 16),

          // ===========================
          // PIE CHART
          // ===========================
          CategoryExpensesPieChart(
            expenses: categoryExpenses,
            categoryColors: categoryColors,
          ),

          const SizedBox(height: 16),

          // ===========================
          // СПИСОК КАТЕГОРИЙ
          // ===========================
          Text(
            analyticsType == AnalyticsType.expense
                ? 'Расходы по категориям'
                : 'Доходы по категориям',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          ...categoryExpenses.map((expense) {
            final category = categories.firstWhereOrNull(
              (c) => c.id == expense.categoryId,
            );

            final parentCategory = category?.parentId == null
                ? null
                : categories.firstWhereOrNull(
                    (c) => c.id == category!.parentId,
                  );

            final color = categoryColors[expense.categoryId] ?? Colors.grey;

            final totalAmount = categoryExpenses.fold<double>(
              0,
              (sum, e) => sum + e.total,
            );

            return CategoryExpenseTile(
              expense: expense,
              categoryName: category?.name ?? 'Неизвестно',
              parentCategoryName: parentCategory?.name,
              showParentCategory:
                  categoryMode == CategoryDisplayMode.subcategoriesOnly &&
                  category?.isSubcategory == true,
              color: color,
              totalAmount: totalAmount,
            );
          }),
        ],
      ),
    );
  }
}
