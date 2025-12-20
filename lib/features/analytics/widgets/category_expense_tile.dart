import 'package:flutter/material.dart';
import '../domain/analytics_models.dart';

/// Элемент списка расходов по категории
class CategoryExpenseTile extends StatelessWidget {
  final CategoryExpenseData expense;
  final String categoryName;

  const CategoryExpenseTile({
    super.key,
    required this.expense,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(categoryName),
      trailing: Text(
        '${expense.total.toStringAsFixed(0)} ₽',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
