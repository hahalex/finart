import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../domain/analytics_models.dart';

class CategoryExpensesPieChart extends StatelessWidget {
  final List<CategoryExpenseData> expenses;
  final Map<String, Color> categoryColors;

  const CategoryExpensesPieChart({
    super.key,
    required this.expenses,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
        ),
        child: const Center(child: Text('Нет данных')),
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
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 55,
                startDegreeOffset: -90,

                sections: expenses.map((expense) {
                  final color =
                      categoryColors[expense.categoryId] ?? Colors.grey;

                  final percent = total == 0 ? 0 : expense.total / total * 100;

                  return PieChartSectionData(
                    color: color,
                    value: expense.total,
                    title: '${percent.toStringAsFixed(0)}%',
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

          // ==========================
          // ЛЕГЕНДА
          // ==========================
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: expenses.map((expense) {
              final color = categoryColors[expense.categoryId] ?? Colors.grey;

              final percent = total == 0 ? 0 : expense.total / total * 100;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withOpacity(0.12),
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
