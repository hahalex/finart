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
        return Icons.calendar_today_outlined;
      case 'yearly':
        return Icons.calendar_month_outlined;
      default:
        return Icons.event_outlined;
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

    final isOverdue = payment.isActive && nextDate.isBefore(DateTime.now());

    return Dismissible(
      key: Key(payment.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.expenseColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: isOverdue
              ? Colors.red.withOpacity(0.04)
              : Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT ICON
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    payment.isExpense
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: color,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // CENTER CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE + STATUS
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              payment.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          if (!payment.isActive)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Неактивен',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        categoryName,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _MetaChip(
                            icon: _recurrenceIcon,
                            text: _recurrenceLabel,
                          ),
                          _MetaChip(
                            icon: Icons.event_outlined,
                            text:
                                '${nextDate.day}.${nextDate.month}.${nextDate.year}',
                            textColor: isOverdue
                                ? AppTheme.expenseColor
                                : Colors.grey[700],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // RIGHT SIDE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${payment.isExpense ? '-' : '+'}${payment.amount.toStringAsFixed(0)} ₽',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (onEdit != null)
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: onEdit,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? textColor;

  const _MetaChip({required this.icon, required this.text, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: textColor ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
