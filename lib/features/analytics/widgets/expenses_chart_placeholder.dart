// Файл: lib/features/analytics/widgets/expenses_chart_placeholder.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../common/localization/app_strings.dart';

class ChartPoint {
  final String label;
  final double value;
  final String? tooltip;
  final bool isAnomaly;

  const ChartPoint({
    required this.label,
    required this.value,
    this.tooltip,
    this.isAnomaly = false,
  });
}

enum AnalyticsChartView { bar, area }

class ExpensesChartPlaceholder extends StatelessWidget {
  const ExpensesChartPlaceholder({
    super.key,
    required this.data,
    required this.chartView,
    required this.color,
    this.trendValue,
  });

  final List<ChartPoint> data;
  final AnalyticsChartView chartView;
  final Color color;
  final double? trendValue;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    if (data.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
        ),
        child: Center(child: Text(strings.noData)),
      );
    }

    final highestPoint = data
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final maxY = highestPoint == 0 ? 1.0 : highestPoint * 1.2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartWidth = _chartWidth(constraints.maxWidth);
          final chart = SizedBox(
            width: chartWidth,
            child: switch (chartView) {
              AnalyticsChartView.bar => _buildBarChart(maxY),
              AnalyticsChartView.area => _buildLineChart(maxY, isArea: true),
            },
          );

          if (chartWidth <= constraints.maxWidth) {
            return chart;
          }

          return ScrollConfiguration(
            behavior: const _ChartScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: chart,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarChart(double maxY) {
    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceBetween,
        gridData: _grid(maxY),
        borderData: FlBorderData(show: false),
        titlesData: _titles(),
        extraLinesData: _extraLines(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final point = data[group.x.toInt()];
              return BarTooltipItem(
                '${point.tooltip ?? point.label}\n${point.value.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                width: data.length > 24 ? 14 : 18,
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          );
        }).toList(),
      ),
      swapAnimationDuration: const Duration(milliseconds: 350),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  Widget _buildLineChart(double maxY, {required bool isArea}) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: _grid(maxY),
        borderData: FlBorderData(show: false),
        titlesData: _titles(),
        extraLinesData: _extraLines(),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final index = spot.x.toInt();
              final point = data[index];
              return LineTooltipItem(
                '${point.tooltip ?? point.label}\n${point.value.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: data.length <= 16 || data.any((point) => point.isAnomaly),
              getDotPainter: (spot, percent, bar, index) {
                final point = data[index];
                final dotColor = point.isAnomaly ? Colors.redAccent : color;
                final radius = point.isAnomaly ? 4.2 : 2.8;
                return FlDotCirclePainter(
                  radius: radius,
                  color: dotColor,
                  strokeWidth: 1.4,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: isArea,
              color: color.withOpacity(isArea ? 0.2 : 0),
            ),
          ),
        ],
      ),
    );
  }

  FlGridData _grid(double maxY) {
    return FlGridData(
      show: true,
      horizontalInterval: maxY / 4,
      drawVerticalLine: false,
    );
  }

  FlTitlesData _titles() {
    final labelStep = _labelStep();

    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
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
            if (index % labelStep != 0 && index != data.length - 1) {
              return const SizedBox();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                data[index].label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _chartWidth(double availableWidth) {
    final perPointWidth = chartView == AnalyticsChartView.bar ? 34.0 : 28.0;
    final computedWidth = data.length * perPointWidth;
    return computedWidth < availableWidth ? availableWidth : computedWidth;
  }

  int _labelStep() {
    if (data.length <= 8) return 1;
    if (data.length <= 16) return 2;
    if (data.length <= 24) return 3;
    if (data.length <= 36) return 4;
    return 6;
  }

  ExtraLinesData _extraLines() {
    if (trendValue == null || trendValue == 0) {
      return ExtraLinesData();
    }

    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: trendValue!,
          color: color.withOpacity(0.55),
          strokeWidth: 1.4,
          dashArray: [6, 4],
        ),
      ],
    );
  }
}

class _ChartScrollBehavior extends ScrollBehavior {
  const _ChartScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      child: child,
    );
  }
}
