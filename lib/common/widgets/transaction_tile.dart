import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final bool isExpense;

  // 🔹 NEW: параметры для отображения категории
  final IconData? categoryIcon;
  final Color? categoryColor;

  const TransactionTile({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
    this.categoryIcon,
    this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // 🔹 Иконка категории с цветным фоном
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: (categoryColor ?? Colors.grey).withOpacity(0.15),
        child: Icon(
          categoryIcon ?? Icons.category_outlined,
          color: categoryColor ?? Colors.grey,
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        category,
        style: TextStyle(
          color: categoryColor ?? Colors.grey[600],
          fontSize: 13,
        ),
      ),
      trailing: Text(
        '${isExpense ? '-' : '+'}${amount.toStringAsFixed(2)} ₽',
        style: TextStyle(
          color: isExpense ? AppTheme.expenseColor : AppTheme.incomeColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
