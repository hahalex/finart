// Файл: lib/common/widgets/category_icon.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryIcon extends StatelessWidget {
  final CategoryModel category;
  final double size;
  final bool showColorIndicator;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 24,
    this.showColorIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Icon(category.iconData, size: size, color: category.colorValue),
        if (showColorIndicator)
          Container(
            // Маленькая точка дублирует цвет категории, когда сама иконка
            // находится рядом с другим текстом или на светлом фоне.
            width: size * 0.35,
            height: size * 0.35,
            decoration: BoxDecoration(
              color: category.colorValue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).cardColor,
                width: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}
