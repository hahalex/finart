import 'package:flutter/material.dart';
import '../domain/analytics_models.dart';

/// Временный график расходов по месяцам
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

    final max = data.map((e) => e.total).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final heightFactor = item.total / max;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: (120 * heightFactor).toDouble(),
                  width: 14,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.month}.${item.year}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
