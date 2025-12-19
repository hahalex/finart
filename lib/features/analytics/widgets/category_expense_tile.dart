import 'package:flutter/material.dart';
import '../mock_analytics.dart';

/// Элемент списка расходов по категории
class CategoryExpenseTile extends StatelessWidget {
  final CategoryExpense expense;

  const CategoryExpenseTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.category),
      trailing: Text(
        '${expense.amount.toStringAsFixed(0)} ₽',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
