import 'package:flutter/material.dart';

/// Карточка статистики для отчёта
class ReportStatCard extends StatelessWidget {
  final String title;
  final double value;

  const ReportStatCard({super.key, required this.title, required this.value});

  Color _valueColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (title == 'Доходы') {
      return Colors.green;
    }

    if (title == 'Расходы') {
      return Colors.red;
    }

    if (title == 'Баланс') {
      return value >= 0 ? Colors.green : Colors.red;
    }

    return scheme.primary;
  }

  IconData _icon() {
    switch (title) {
      case 'Доходы':
        return Icons.arrow_downward_rounded;
      case 'Расходы':
        return Icons.arrow_upward_rounded;
      case 'Баланс':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.analytics_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _valueColor(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(_icon(), color: color, size: 24),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              '${value.toStringAsFixed(0)} ₽',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
