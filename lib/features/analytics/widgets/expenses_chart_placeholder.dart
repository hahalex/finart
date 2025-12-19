import 'package:flutter/material.dart';
import '../mock_analytics.dart';

/// Заглушка графика расходов
/// Позже здесь будет fl_chart
class ExpensesChartPlaceholder extends StatelessWidget {
  const ExpensesChartPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: mockMonthlyExpenses.map((data) {
          final max = mockMonthlyExpenses
              .map((e) => e.amount)
              .reduce((a, b) => a > b ? a : b);

          final heightFactor = data.amount / max;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 120 * heightFactor,
                  width: 14,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(data.month, style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
