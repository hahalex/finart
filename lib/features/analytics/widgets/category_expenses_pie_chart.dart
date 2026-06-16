// Файл: lib/features/analytics/widgets/category_expenses_pie_chart.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../common/localization/app_strings.dart';
import '../../../common/utils/app_theme.dart';
import '../domain/analytics_models.dart';

class CategoryExpensesPieChart extends StatelessWidget {
  const CategoryExpensesPieChart({
    super.key,
    required this.expenses,
    required this.categoryColors,
    required this.onCategoryTap,
  });

  final List<CategoryExpenseData> expenses;
  final Map<String, Color> categoryColors;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    if (expenses.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
        ),
        child: Center(child: Text(strings.noData)),
      );
    }

    final total = expenses.fold<double>(0, (sum, e) => sum + e.total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              strings.top10Categories,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 55,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) {
                      return;
                    }
                    final index = response?.touchedSection?.touchedSectionIndex;
                    if (index == null) {
                      return;
                    }
                    if (index >= 0 && index < expenses.length) {
                      onCategoryTap(expenses[index].categoryId);
                    }
                  },
                ),
                sections: expenses.map((expense) {
                  final color =
                      categoryColors[expense.categoryId] ??
                      AppTheme.unknownCategoryColor;
                  final percent = total == 0 ? 0 : expense.total / total * 100;

                  return PieChartSectionData(
                    color: color,
                    value: expense.total,
                    title: percent >= 6 ? '${percent.toStringAsFixed(0)}%' : '',
                    radius: 68,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: expenses.map((expense) {
              final color =
                  categoryColors[expense.categoryId] ??
                  AppTheme.unknownCategoryColor;
              final percent = total == 0 ? 0 : expense.total / total * 100;

              return InkWell(
                onTap: () => onCategoryTap(expense.categoryId),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.withOpacity(0.14),
                    border: Border.all(
                      color: color.withOpacity(
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.35
                            : 0.22,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: color),
                      const SizedBox(width: 6),
                      Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
