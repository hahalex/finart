import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../domain/analytics_models.dart';

/// График расходов по месяцам с fl_chart
class ExpensesChartPlaceholder extends StatelessWidget {
  final List<MonthlyExpenseData> data;

  const ExpensesChartPlaceholder({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Нет данных')),
      );
    }

    final maxY = data.map((e) => e.total).reduce((a, b) => a > b ? a : b) * 1.1;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: (maxY / 5),
                getTitlesWidget: (value, _) => Text('${value.toInt()} ₽'),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length)
                    return const SizedBox();
                  final item = data[index];
                  return Text(
                    '${item.month}.${item.year}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.total,
                  width: 14,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
