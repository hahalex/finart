import 'package:flutter/material.dart';
import '../domain/analytics_models.dart';

/// Красивый элемент списка по категории
class CategoryExpenseTile extends StatelessWidget {
  final CategoryExpenseData expense;
  final String categoryName;
  final String? parentCategoryName;
  final bool showParentCategory;
  final Color color;

  /// Общая сумма для вычисления %
  final double totalAmount;

  const CategoryExpenseTile({
    super.key,
    required this.expense,
    required this.categoryName,
    required this.color,
    required this.totalAmount,
    this.parentCategoryName,
    this.showParentCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalAmount == 0 ? 0.0 : expense.total / totalAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).cardColor,
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
                '${expense.total.toStringAsFixed(0)} ₽',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
