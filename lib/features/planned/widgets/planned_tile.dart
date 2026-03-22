import 'package:flutter/material.dart';
import '../../../../common/utils/app_theme.dart';
import '../../../../common/models/planned_payment_model.dart';

/// Карточка запланированного платежа
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
        decoration: BoxDecoration(
          color: AppTheme.expenseColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: isOverdue ? Colors.grey.withOpacity(0.08) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(
              payment.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  payment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!payment.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('✓', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(_recurrenceIcon, size: 13, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                      _recurrenceLabel,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.event, size: 13, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                      '${nextDate.day}.${nextDate.month}.${nextDate.year}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isOverdue
                            ? AppTheme.expenseColor
                            : Colors.grey[600],
                        fontWeight: isOverdue ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${payment.isExpense ? '-' : '+'}${payment.amount.toStringAsFixed(0)} ₽',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.grey[500],
                ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
