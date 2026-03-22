import 'package:flutter/material.dart';
import '../../../../common/utils/app_theme.dart';
import '../../../../common/models/planned_payment_model.dart';

/// Карточка запланированного платежа (аналог TransactionTile)
class PlannedTile extends StatelessWidget {
  final PlannedPaymentModel payment;
  final String categoryName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlannedTile({
    super.key,
    required this.payment,
    required this.categoryName,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  /// Иконка для типа периодичности
  IconData get _recurrenceIcon {
    switch (payment.recurrence) {
      case 'daily':
        return Icons.repeat;
      case 'weekly':
        return Icons.calendar_view_week;
      case 'monthly':
        return Icons.calendar_today;
      case 'yearly':
        return Icons.calendar_month;
      default:
        return Icons.event;
    }
  }

  /// Текст для периодичности
  String get _recurrenceLabel {
    switch (payment.recurrence) {
      case 'daily':
        return 'ежедневно';
      case 'weekly':
        return 'еженедельно';
      case 'monthly':
        return 'ежемесячно';
      case 'yearly':
        return 'ежегодно';
      default:
        return 'разово';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = payment.isExpense
        ? AppTheme.expenseColor
        : AppTheme.incomeColor;
    final nextDate = payment.getNextPaymentDate();
    final isOverdue = !payment.isActive || nextDate.isBefore(DateTime.now());

    return Dismissible(
      key: Key(payment.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: isOverdue ? Colors.grey.withOpacity(0.1) : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(
              payment.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
            ),
          ),
          title: Row(
            children: [
              Text(
                payment.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (!payment.isActive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'завершено',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(categoryName, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(_recurrenceIcon, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _recurrenceLabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.event, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'След: ${nextDate.day}.${nextDate.month}.${nextDate.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${payment.isExpense ? '-' : '+'}${payment.amount.toStringAsFixed(2)} ₽',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
