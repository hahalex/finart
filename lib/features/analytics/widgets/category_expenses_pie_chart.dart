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
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Нет данных')),
      );
    }

    final total = expenses.fold<double>(0, (sum, e) => sum + e.total);

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: expenses.map((expense) {
            final color = categoryColors[expense.categoryId] ?? Colors.grey;
            final percentage = expense.total / total * 100;

            return PieChartSectionData(
              color: color,
              value: expense.total,
              title: '${percentage.toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}
