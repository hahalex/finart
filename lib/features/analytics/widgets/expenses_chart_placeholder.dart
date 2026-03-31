import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Универсальная точка графика
class ChartPoint {
  final String label;
  final double value;

  const ChartPoint({required this.label, required this.value});
}

/// Красивый bar chart для дней / недель / месяцев
class ExpensesChartPlaceholder extends StatelessWidget {
  final List<ChartPoint> data;

  const ExpensesChartPlaceholder({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
        ),
        child: const Center(child: Text('Нет данных')),
      );
    }

    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      height: 260,
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
      child: BarChart(
        BarChartData(
          maxY: maxY,

          alignment: BarChartAlignment.spaceAround,

          gridData: FlGridData(
            show: true,
            horizontalInterval: maxY / 4,
            drawVerticalLine: false,
          ),

          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()} ₽',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[index].label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.value,
                  width: 18,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
