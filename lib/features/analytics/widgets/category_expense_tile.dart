import 'package:flutter/material.dart';
import '../domain/analytics_models.dart';

/// Элемент списка расходов по категории
class CategoryExpenseTile extends StatelessWidget {
  final CategoryExpenseData expense;
  final String categoryName;
  final Color color;

  const CategoryExpenseTile({
    super.key,
    required this.expense,
    required this.categoryName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color, radius: 8),
      title: Text(categoryName),
      trailing: Text(
        '${expense.total.toStringAsFixed(0)} ₽',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
