import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../providers/selected_month_provider.dart';

/// Навигационная панель для переключения месяцев
class MonthNavigation extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onMonthTap;

  const MonthNavigation({
    super.key,
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = getMonthName(selectedMonth);
    final year = selectedMonth.year;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Кнопка "Назад"
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: onPrevious,
            tooltip: 'Предыдущий месяц',
          ),

          // Кликабельное название месяца (как Март 2026)
          GestureDetector(
            onTap: onMonthTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$monthName $year',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Кнопка "Вперёд"
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 28),
            onPressed: onNext,
            tooltip: 'Следующий месяц',
          ),
        ],
      ),
    );
  }
}
