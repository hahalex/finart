// Файл: lib/common/widgets/category_picker.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/categories/categories_screen.dart';
import '../localization/app_strings.dart';
import '../models/category_model.dart';
import '../providers/categories_provider.dart';
import '../utils/app_theme.dart';
import 'category_icon.dart';
import 'category_tile.dart';

typedef OnCategorySelected = void Function(CategoryModel category);

enum CategoryPickerMode { grid, list, compact }

class CategoryPicker extends ConsumerWidget {
  const CategoryPicker({
    super.key,
    required this.isExpense,
    this.selectedCategory,
    this.onSelected,
    this.mode = CategoryPickerMode.grid,
    this.showSubcategories = true,
    this.height,
  });

  final bool isExpense;
  final CategoryModel? selectedCategory;
  final OnCategorySelected? onSelected;
  final CategoryPickerMode mode;
  final bool showSubcategories;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootsAsync = ref.watch(
      isExpense ? expenseCategoriesProvider : incomeCategoriesProvider,
    );

    final child = rootsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (roots) => _buildPicker(context, ref, roots),
    );

    if (height != null) {
      // В формах выбора операции высота ограничивается снаружи,
      // чтобы сетка категорий не вытесняла кнопку сохранения.
      return SizedBox(height: height, child: child);
    }
    return child;
  }

  Widget _buildPicker(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> roots,
  ) {
    final strings = AppStrings.of(context);

    if (roots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // Пустое состояние: мягкая иконка категории и кнопка создания.
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.colorsOf(context).surfaceSoft,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Icon(
                Icons.category_outlined,
                size: 34,
                color: AppTheme.mutedTextOf(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.isRu ? 'Нет категорий' : 'No categories',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              // Переход к экрану управления категориями.
              onPressed: () => _navigateToManage(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text(strings.isRu ? 'Создать' : 'Create'),
            ),
          ],
        ),
      );
    }

    switch (mode) {
      case CategoryPickerMode.grid:
        return _buildGrid(context, ref, roots);
      case CategoryPickerMode.list:
        return _buildList(context, ref, roots);
      case CategoryPickerMode.compact:
        return _buildCompact(context);
    }
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> roots,
  ) {
    return GridView.builder(
      // Сетка используется на экране добавления операции: три категории в ряд
      // дают быстрый выбор большим пальцем.
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: roots.length,
      itemBuilder: (context, index) {
        final root = roots[index];
        final isSelected = selectedCategory?.id == root.id;

        return Consumer(
          builder: (context, ref, _) {
            final subsAsync = ref.watch(subcategoriesProvider(root.id));
            final hasSubcategories =
                (subsAsync.valueOrNull ?? const <CategoryModel>[]).isNotEmpty;

            return CategoryTile(
              category: root,
              isSelected: isSelected,
              hasSubcategories: hasSubcategories,
              onTap: () async {
                // Если у основной категории есть подкатегории, открываем
                // нижний лист; иначе выбираем категорию сразу.
                final subs = hasSubcategories
                    ? await ref.read(subcategoriesProvider(root.id).future)
                    : const <CategoryModel>[];
                if (subs.isNotEmpty && showSubcategories) {
                  _showSubcategoriesBottomSheet(context, root);
                } else if (onSelected != null) {
                  onSelected!(root);
                }
              },
              onLongPress: hasSubcategories && showSubcategories
                  ? () => _showSubcategoriesBottomSheet(context, root)
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> roots,
  ) {
    final colors = AppTheme.colorsOf(context);

    return ListView.separated(
      // Списочный режим удобен в длинных формах и показывает подкатегории
      // сразу под родительской категорией.
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: roots.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: colors.border),
      itemBuilder: (context, index) {
        final root = roots[index];
        final isSelected = selectedCategory?.id == root.id;

        return Consumer(
          builder: (context, ref, _) {
            final subsAsync = ref.watch(subcategoriesProvider(root.id));
            final subs = subsAsync.valueOrNull ?? const <CategoryModel>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CategoryIcon(category: root, size: 24),
                  title: Text(root.name),
                  subtitle: root.aiTag?.trim().isNotEmpty == true
                      ? Text(
                          'AI: ${root.aiTag}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.mutedTextOf(context)),
                        )
                      : null,
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: colors.primary)
                      : subs.isNotEmpty
                      ? Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.mutedTextOf(context),
                        )
                      : null,
                  onTap: () {
                    if (subs.isNotEmpty && showSubcategories) {
                      _showSubcategoriesBottomSheet(context, root);
                    } else if (onSelected != null) {
                      onSelected!(root);
                    }
                  },
                ),
                if (subsAsync.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(left: 56, bottom: 8),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (subs.isNotEmpty && showSubcategories)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 56,
                      right: 16,
                      bottom: 12,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: subs.map((sub) {
                        final isSubSelected = selectedCategory?.id == sub.id;
                        return FilterChip(
                          label: Text(
                            sub.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          selected: isSubSelected,
                          onSelected: (value) {
                            if (value && onSelected != null) onSelected!(sub);
                          },
                          avatar: CategoryIcon(category: sub, size: 16),
                          backgroundColor: sub.colorValue.withOpacity(0.10),
                          selectedColor: sub.colorValue.withOpacity(0.18),
                          checkmarkColor: sub.colorValue,
                          side: BorderSide(
                            color: isSubSelected
                                ? sub.colorValue.withOpacity(0.5)
                                : colors.border,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCompact(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);

    if (selectedCategory == null) {
      return GestureDetector(
        onTap: () => _navigateToManage(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.category_outlined,
                color: AppTheme.mutedTextOf(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                strings.isRu ? 'Выберите категорию' : 'Choose a category',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedTextOf(context),
                ),
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
          color: selectedCategory!.colorValue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: selectedCategory!.colorValue.withOpacity(0.28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIcon(category: selectedCategory!, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                selectedCategory!.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selectedCategory!.colorValue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onSelected != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppTheme.mutedTextOf(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSubcategoriesBottomSheet(BuildContext context, CategoryModel root) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SubcategoriesSheet(
        root: root,
        selectedCategory: selectedCategory,
        onSelected: onSelected,
      ),
    );
  }

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

class _SubcategoriesSheet extends ConsumerWidget {
  const _SubcategoriesSheet({
    required this.root,
    required this.selectedCategory,
    required this.onSelected,
  });

  final CategoryModel root;
  final CategoryModel? selectedCategory;
  final OnCategorySelected? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final subsAsync = ref.watch(subcategoriesProvider(root.id));

    return DraggableScrollableSheet(
      initialChildSize: 0.56,
      minChildSize: 0.34,
      maxChildSize: 0.86,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLg),
          ),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: root.colorValue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: CategoryIcon(category: root, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          root.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.isRu
                              ? 'Выберите подкатегорию или основную категорию'
                              : 'Choose a subcategory or the main category',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.mutedTextOf(context)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: subsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (subcategories) => ListView.separated(
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
                          Navigator.pop(context);
                          if (onSelected != null) onSelected!(sub);
                        },
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? sub.colorValue.withOpacity(0.18)
                                : colors.surfaceSoft,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? sub.colorValue.withOpacity(0.56)
                                  : colors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CategoryIcon(category: sub, size: 28),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                          ),
                                    ),
                                    if (sub.aiTag?.trim().isNotEmpty ==
                                        true) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'AI: ${sub.aiTag}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.mutedTextOf(
                                                context,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ],
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
            ),
            if (onSelected != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onSelected!(root);
                    },
                    icon: const Icon(
                      Icons.subdirectory_arrow_left_rounded,
                      size: 18,
                    ),
                    label: Text(
                      strings.isRu
                          ? 'Выбрать основную категорию'
                          : 'Choose main category',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
