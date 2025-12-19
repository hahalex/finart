import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Элемент списка операций (один доход или расход)
class TransactionTile extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final bool isExpense;

  const TransactionTile({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(
          isExpense ? Icons.arrow_upward : Icons.arrow_downward,
          color: color,
        ),
      ),
      title: Text(title),
      subtitle: Text(category),
      trailing: Text(
        '${isExpense ? '-' : '+'}${amount.toStringAsFixed(2)} ₽',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
