// Файл: lib/features/planned/widgets/planned_tile.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';

import '../../../common/localization/app_strings.dart';
import '../../../common/models/planned_payment_model.dart';
import '../../../common/utils/app_theme.dart';

class PlannedTile extends StatelessWidget {
  const PlannedTile({
    super.key,
    required this.payment,
    required this.categoryName,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final PlannedPaymentModel payment;
  final String categoryName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  IconData get _recurrenceIcon {
    if (payment.recurrence.startsWith('weekdays:')) {
      return Icons.date_range_outlined;
    }
    if (payment.recurrence.startsWith('every:')) {
      return Icons.repeat_on_outlined;
    }
    return switch (payment.recurrence) {
      'daily' => Icons.repeat,
      'weekly' => Icons.calendar_view_week,
      'monthly' => Icons.calendar_today_outlined,
      'yearly' => Icons.calendar_month_outlined,
      _ => Icons.event_outlined,
    };
  }

  String _recurrenceLabel(bool isRu) {
    final parts = payment.recurrence.split(':');
    if (parts.length == 3 && parts[0] == 'every') {
      final unitLabel = switch (parts[1]) {
        'days' => isRu ? 'дн.' : 'days',
        'weeks' => isRu ? 'нед.' : 'weeks',
        'months' => isRu ? 'мес.' : 'months',
        'years' => isRu ? 'г.' : 'years',
        _ => parts[1],
      };
      return isRu
          ? 'каждые ${parts[2]} $unitLabel'
          : 'every ${parts[2]} $unitLabel';
    }

    if (parts.length == 2 && parts[0] == 'weekdays') {
      return isRu ? 'по дням недели' : 'weekdays';
    }

    if (parts.length == 2 && parts[0] == 'monthly') {
      return isRu ? '${parts[1]} числа' : 'day ${parts[1]}';
    }

    return switch (payment.recurrence) {
      'daily' => isRu ? 'ежедневно' : 'daily',
      'weekly' => isRu ? 'еженедельно' : 'weekly',
      'monthly' => isRu ? 'ежемесячно' : 'monthly',
      'yearly' => isRu ? 'ежегодно' : 'yearly',
      _ => isRu ? 'разово' : 'one-time',
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final color = payment.isExpense ? colors.expense : colors.income;
    final nextDate = payment.getNextOccurrenceOnOrAfter(DateTime.now());
    final isOverdue = payment.isActive && nextDate.isBefore(DateTime.now());

    return Dismissible(
      // Свайп влево удаляет платеж через обработчик родительского экрана.
      key: Key(payment.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        // Красная подложка показывается только во время свайпа.
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colors.expense,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          // Просроченный активный платеж получает едва заметную красную заливку.
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.04)
              : Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // Круглая иконка показывает направление: вверх — расход,
                  // вниз — доход. Цвет совпадает с суммой справа.
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              // Бейдж "Неактивен" появляется у завершенных платежей.
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                strings.isRu ? 'Неактивен' : 'Inactive',
                                style: const TextStyle(fontSize: 10),
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
                        // Метачипы под названием: регулярность и ближайшая дата.
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _MetaChip(
                            icon: _recurrenceIcon,
                            text: _recurrenceLabel(strings.isRu),
                          ),
                          _MetaChip(
                            icon: Icons.event_outlined,
                            text:
                                '${nextDate.day}.${nextDate.month}.${nextDate.year}',
                            textColor: isOverdue
                                ? colors.expense
                                : Colors.grey[700],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${payment.isExpense ? '-' : '+'}${payment.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (onEdit != null)
                      InkWell(
                        // Маленькая иконка редактирования справа открывает меню
                        // действий: изменить, завершить, удалить.
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
  const _MetaChip({required this.icon, required this.text, this.textColor});

  final IconData icon;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Нейтральный чип для коротких параметров платежа.
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
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
