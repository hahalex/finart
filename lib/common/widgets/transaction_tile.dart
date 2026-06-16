// Файл: lib/common/widgets/transaction_tile.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/transactions/edit_transaction_sheet.dart';
import '../../features/transactions/providers/transactions_notifier.dart';
import '../models/transaction_model.dart';
import '../utils/app_theme.dart';

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
    final colors = AppTheme.colorsOf(context);
    final amountColor = isExpense
        ? (Theme.of(context).brightness == Brightness.light
              ? colors.secondary
              : colors.expense)
        : colors.income;
    final categoryTint = categoryColor ?? AppTheme.unknownCategoryColor;

    return Dismissible(
      // Свайп влево показывает красный фон удаления и требует подтверждение.
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Удалить транзакцию?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Нет'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
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
        // Красная подложка видна только во время свайпа.
        color: colors.expense,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onLongPress: () {
          // Долгое нажатие открывает нижнюю панель редактирования операции.
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => EditTransactionSheet(transaction: transaction),
          );
        },
        child: Container(
          // Карточка операции: общий фон/граница/тень берутся из AppTheme,
          // поэтому вид совпадает с остальными карточками приложения.
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: AppTheme.surfaceCardDecoration(
            context,
            radius: AppTheme.radiusMd,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            leading: CircleAvatar(
              // Иконка категории подсвечивается полупрозрачным цветом категории.
              radius: 20,
              backgroundColor: categoryTint.withOpacity(0.15),
              child: Icon(
                categoryIcon ?? Icons.category_outlined,
                color: categoryTint,
              ),
            ),
            title: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.mutedTextOf(context),
              ),
            ),
            trailing: Text(
              // Сумма справа: минус для расходов, плюс для доходов.
              '${isExpense ? '-' : '+'}${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
