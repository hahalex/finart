import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../providers/categories_provider.dart';
import '../utils/app_theme.dart';
import 'category_icon.dart';
import 'category_tile.dart';
import '../../features/categories/categories_screen.dart';

/// 🔹 Тип обратного вызова при выборе категории
typedef OnCategorySelected = void Function(CategoryModel category);

/// 🔹 Режим отображения пикера
enum CategoryPickerMode {
  grid, // Сетка (для форм добавления)
  list, // Список (для фильтров)
  compact, // Компактный чип (для отображения выбранной)
}

/// 🎯 Основной виджет выбора категории с поддержкой подкатегорий
class CategoryPicker extends ConsumerWidget {
  final bool isExpense;
  final CategoryModel? selectedCategory;
  final OnCategorySelected? onSelected;
  final CategoryPickerMode mode;
  final bool showSubcategories;
  final double? height;

  const CategoryPicker({
    super.key,
    required this.isExpense,
    this.selectedCategory,
    this.onSelected,
    this.mode = CategoryPickerMode.grid,
    this.showSubcategories = true,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔹 Подписка на иерархию категорий (кэшируется!)
    final hierarchyAsync = ref.watch(categoriesHierarchyProvider(isExpense));

    if (height != null) {
      return SizedBox(
        height: height,
        child: _buildContent(context, hierarchyAsync),
      );
    }
    return _buildContent(context, hierarchyAsync);
  }

  Widget _buildContent(
    BuildContext context,
    AsyncValue<Map<CategoryModel, List<CategoryModel>>> async,
  ) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (err, _) => Center(
        child: Text(
          'Ошибка загрузки: $err',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      ),
      data: (hierarchy) => _buildPicker(context, hierarchy),
    );
  }

  Widget _buildPicker(
    BuildContext context,
    Map<CategoryModel, List<CategoryModel>> hierarchy,
  ) {
    if (hierarchy.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Нет категорий',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _navigateToManage(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Создать'),
            ),
          ],
        ),
      );
    }

    switch (mode) {
      case CategoryPickerMode.grid:
        return _buildGrid(context, hierarchy);
      case CategoryPickerMode.list:
        return _buildList(context, hierarchy);
      case CategoryPickerMode.compact:
        return _buildCompact(context, hierarchy);
    }
  }

  // ============================================================================
  // 📊 GRID MODE (основной — как в банковских приложениях)
  // ============================================================================
  Widget _buildGrid(
    BuildContext context,
    Map<CategoryModel, List<CategoryModel>> hierarchy,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: hierarchy.length,
      itemBuilder: (context, index) {
        final root = hierarchy.keys.elementAt(index);
        final subs = hierarchy[root] ?? [];
        final isSelected = selectedCategory?.id == root.id;

        return CategoryTile(
          category: root,
          isSelected: isSelected,
          hasSubcategories: subs.isNotEmpty,
          onTap: () {
            if (subs.isNotEmpty && showSubcategories) {
              _showSubcategoriesBottomSheet(context, root, subs);
            } else if (onSelected != null) {
              onSelected!(root);
            }
          },
          onLongPress: subs.isNotEmpty && showSubcategories
              ? () => _showSubcategoriesBottomSheet(context, root, subs)
              : null,
        );
      },
    );
  }

  // ============================================================================
  // 📋 LIST MODE (для фильтров и аналитики)
  // ============================================================================
  Widget _buildList(
    BuildContext context,
    Map<CategoryModel, List<CategoryModel>> hierarchy,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: hierarchy.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final root = hierarchy.keys.elementAt(index);
        final subs = hierarchy[root] ?? [];
        final isSelected = selectedCategory?.id == root.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CategoryIcon(category: root, size: 24),
              title: Text(root.name),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
                  : subs.isNotEmpty
                  ? Icon(Icons.chevron_right, color: Colors.grey)
                  : null,
              onTap: () {
                if (subs.isNotEmpty && showSubcategories) {
                  _showSubcategoriesBottomSheet(context, root, subs);
                } else if (onSelected != null) {
                  onSelected!(root);
                }
              },
            ),
            // 🔹 Быстрый показ подкатегорий инлайн (опционально)
            if (subs.isNotEmpty && showSubcategories)
              Padding(
                padding: const EdgeInsets.only(left: 56, bottom: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: subs.map((sub) {
                    final isSubSelected = selectedCategory?.id == sub.id;
                    return FilterChip(
                      label: Text(
                        sub.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: isSubSelected,
                      onSelected: (val) {
                        if (val && onSelected != null) onSelected!(sub);
                      },
                      avatar: CategoryIcon(category: sub, size: 16),
                      backgroundColor: sub.colorValue.withOpacity(0.1),
                      selectedColor: sub.colorValue.withOpacity(0.2),
                      checkmarkColor: sub.colorValue,
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  // ============================================================================
  // 🎯 COMPACT MODE (для отображения выбранной категории)
  // ============================================================================
  Widget _buildCompact(
    BuildContext context,
    Map<CategoryModel, List<CategoryModel>> hierarchy,
  ) {
    if (selectedCategory == null) {
      return GestureDetector(
        onTap: () => _navigateToManage(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_outlined, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                'Выберите категорию',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onSelected != null ? () => _navigateToManage(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selectedCategory!.colorValue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedCategory!.colorValue.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIcon(category: selectedCategory!, size: 20),
            const SizedBox(width: 8),
            Text(
              selectedCategory!.name,
              style: TextStyle(
                color: selectedCategory!.colorValue,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onSelected != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // 🔽 BOTTOM SHEET: выбор подкатегории
  // ============================================================================
  void _showSubcategoriesBottomSheet(
    BuildContext context,
    CategoryModel root,
    List<CategoryModel> subcategories,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Заголовок
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    CategoryIcon(category: root, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            root.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Выберите подкатегорию',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Список подкатегорий
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemCount: subcategories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final sub = subcategories[index];
                    final isSelected = selectedCategory?.id == sub.id;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (onSelected != null) onSelected!(sub);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? sub.colorValue.withOpacity(0.15)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: sub.colorValue, width: 2)
                                : null,
                          ),
                          child: Row(
                            children: [
                              CategoryIcon(category: sub, size: 28),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  sub.name,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: sub.colorValue),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Кнопка "Выбрать корневую"
              if (onSelected != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      onSelected!(root);
                      Navigator.pop(ctx);
                    },
                    icon: Icon(Icons.arrow_back, size: 18),
                    label: const Text('Выбрать основную категорию'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 🔧 Навигация к управлению категориями
  // ============================================================================
  void _navigateToManage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CategoriesScreen(),
        settings: RouteSettings(arguments: isExpense),
      ),
    );
  }
}
