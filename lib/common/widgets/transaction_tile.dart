import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../utils/app_theme.dart';
import '../../features/transactions/edit_transaction_sheet.dart';
import '../../features/transactions/providers/transactions_notifier.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionModel transaction;
  final String title;
  final String category;
  final double amount;
  final bool isExpense;
  final IconData? categoryIcon;
  final Color? categoryColor;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
    this.categoryIcon,
    this.categoryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Удалить транзакцию?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Нет'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Да'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref
            .read(transactionsProvider.notifier)
            .removeTransaction(transaction.id);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => EditTransactionSheet(transaction: transaction),
          );
        },
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: (categoryColor ?? Colors.grey).withOpacity(0.15),
            child: Icon(
              categoryIcon ?? Icons.category_outlined,
              color: categoryColor ?? Colors.grey,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(category),
          trailing: Text(
            '${isExpense ? '-' : '+'}${amount.toStringAsFixed(2)} ₽',
            style: TextStyle(
              color: isExpense ? AppTheme.expenseColor : AppTheme.incomeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
