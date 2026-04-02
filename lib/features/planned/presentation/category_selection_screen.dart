import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/models/category_model.dart';
import '../../../common/widgets/category_picker.dart';
import '../../../common/providers/categories_provider.dart';

/// 📱 Экран выбора категории (full-screen UX)
class CategorySelectionScreen extends ConsumerWidget {
  final bool isExpense;
  final String? selectedCategoryId;

  const CategorySelectionScreen({
    super.key,
    required this.isExpense,
    this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите категорию'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),

        error: (err, _) => Center(child: Text('Ошибка: $err')),

        data: (categories) {
          // 🔹 Находим выбранную категорию
          CategoryModel? selectedCategory;

          if (selectedCategoryId != null) {
            for (final c in categories) {
              if (c.id == selectedCategoryId) {
                selectedCategory = c;
                break;
              }
            }
          }

          return CategoryPicker(
            isExpense: isExpense,
            selectedCategory: selectedCategory,

            /// 🔥 КЛЮЧЕВОЕ: возвращаем результат назад
            onSelected: (category) {
              Navigator.pop(context, category);
            },

            mode: CategoryPickerMode.grid,
            showSubcategories: true,
          );
        },
      ),
    );
  }
}
