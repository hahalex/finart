// Файл: lib/features/analytics/widgets/category_expense_tile.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';

import '../../../common/utils/app_theme.dart';
import '../domain/analytics_models.dart';

class CategoryExpenseTile extends StatelessWidget {
  const CategoryExpenseTile({
    super.key,
    required this.expense,
    required this.categoryName,
    required this.color,
    required this.totalAmount,
    this.parentCategoryName,
    this.showParentCategory = false,
    this.onTap,
  });

  final CategoryExpenseData expense;
  final String categoryName;
  final String? parentCategoryName;
  final bool showParentCategory;
  final Color color;
  final double totalAmount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final percent = totalAmount == 0 ? 0.0 : expense.total / totalAmount;
    final colors = AppTheme.colorsOf(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).cardColor,
          border: Border.all(color: color.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(0.04),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 8, backgroundColor: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (showParentCategory && parentCategoryName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            parentCategoryName!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  expense.total.toStringAsFixed(0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent.clamp(0, 1),
                minHeight: 8,
                backgroundColor: colors.surfaceSoft,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
