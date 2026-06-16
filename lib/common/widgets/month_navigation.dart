// Файл: lib/common/widgets/month_navigation.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../providers/selected_month_provider.dart';
import '../utils/app_theme.dart';

class MonthNavigation extends StatelessWidget {
  const MonthNavigation({
    super.key,
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
    required this.onMonthTap,
    this.leading,
    this.trailing,
  });

  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onMonthTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final strings = AppStrings.of(context);
    final monthName = getMonthName(
      selectedMonth,
      languageCode: strings.isRu ? 'ru' : 'en',
    );
    final year = selectedMonth.year;

    return Container(
      // Общая верхняя панель месяца. Нижняя граница отделяет ее от контента,
      // а leading/trailing позволяют экранам вставлять свои кнопки по краям.
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            // Левый слот фиксированной ширины: например, кнопка "Счета".
            // Даже если кнопки нет, центр месяца остается ровным.
            width: 44,
            height: 44,
            child: leading == null
                ? const SizedBox.shrink()
                : Center(child: leading),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  // Стрелка назад перелистывает месяц.
                  icon: const Icon(Icons.chevron_left, size: 24),
                  onPressed: onPrevious,
                  tooltip: strings.isRu ? 'Предыдущий месяц' : 'Previous month',
                ),
                Flexible(
                  child: GestureDetector(
                    // Нажатие по центральной плашке открывает выбор месяца.
                    onTap: onMonthTap,
                    child: Container(
                      // Мягкая primary-заливка выделяет текущий месяц как кнопку.
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colors.primary.withValues(alpha: 0.12),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$monthName $year',
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  // Стрелка вперед перелистывает месяц.
                  icon: const Icon(Icons.chevron_right, size: 24),
                  onPressed: onNext,
                  tooltip: strings.isRu ? 'Следующий месяц' : 'Next month',
                ),
              ],
            ),
          ),
          SizedBox(
            // Правый слот фиксированной ширины: например, кнопка платежей.
            width: 44,
            height: 44,
            child: trailing == null
                ? const SizedBox.shrink()
                : Center(child: trailing),
          ),
        ],
      ),
    );
  }
}
