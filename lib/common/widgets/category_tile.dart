// Файл: lib/common/widgets/category_tile.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../models/category_model.dart';
import 'category_icon.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final bool hasSubcategories;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CategoryTile({
    super.key,
    required this.category,
    this.isSelected = false,
    this.hasSubcategories = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          // Плитка категории: выбранная категория получает цветную заливку
          // и толстую рамку, обычная — нейтральную поверхность.
          decoration: BoxDecoration(
            color: isSelected
                ? category.colorValue.withOpacity(0.15)
                : (isDark ? colors.surfaceSoft : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: category.colorValue, width: 2)
                : Border.all(
                    color: isDark ? colors.border : Colors.grey.shade200,
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  CategoryIcon(category: category, size: 32),
                  if (hasSubcategories)
                    Container(
                      // Маленькая иконка папки показывает, что у категории
                      // есть подкатегории и по нажатию откроется выбор ниже.
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? colors.border : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.folder_open,
                        size: 12,
                        color: isDark
                            ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.78)
                            : Colors.grey.shade700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? category.colorValue
                      : (isDark
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.grey.shade800),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
