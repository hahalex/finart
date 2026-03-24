import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/category_model.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/widgets/category_icon.dart';
import '../../common/utils/app_theme.dart';
import 'category_form_dialog.dart';

// TODO убрать все подкатегории - предупреждуения о том что нужно выбрать родительскую категорию достаточно

// ============================================================================
// 📋 ЭКРАН: Управление категориями
// ============================================================================

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense =
        ModalRoute.of(context)?.settings.arguments as bool? ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(isExpense ? 'Категории расходов' : 'Категории доходов'),
        centerTitle: true,
        actions: [
          // 🔹 Переключатель: расходы/доходы
          IconButton(
            icon: Icon(isExpense ? Icons.trending_down : Icons.trending_up),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesScreen(),
                  settings: RouteSettings(arguments: !isExpense),
                ),
              );
            },
            tooltip: isExpense ? 'Показать доходы' : 'Показать расходы',
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Поиск
          _buildSearchBar(context, ref, isExpense),

          // 🔹 Секция с «осиротевшими» подкатегориями
          _buildOrphanedSubcategoriesSection(context, ref, isExpense),

          // 🔹 Кнопка "Все подкатегории"
          _buildSubcategoriesSectionButton(context, ref, isExpense),

          // 🔹 Основной список категорий
          Expanded(child: _buildCategoriesList(context, ref, isExpense)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryForm(context, ref, isExpense, null),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  /// 🔍 Поиск по категориям
  Widget _buildSearchBar(BuildContext context, WidgetRef ref, bool isExpense) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Поиск категории...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          isDense: true,
        ),
        onChanged: (query) {
          // TODO: реализовать фильтрацию через провайдер
        },
      ),
    );
  }

  /// 📋 Список категорий
  Widget _buildCategoriesList(
    BuildContext context,
    WidgetRef ref,
    bool isExpense,
  ) {
    final hierarchyAsync = ref.watch(categoriesHierarchyProvider(isExpense));

    return hierarchyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (err, _) => Center(
        child: Text(
          'Ошибка: $err',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (hierarchy) {
        if (hierarchy.isEmpty) {
          return _buildEmptyState(context, ref, isExpense);
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: hierarchy.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final root = hierarchy.keys.elementAt(index);
            final subs = hierarchy[root] ?? [];
            return _buildCategoryItem(context, ref, root, subs, isExpense);
          },
        );
      },
    );
  }

  /// 🔹 Секция: Подкатегории без назначенного родителя
  Widget _buildOrphanedSubcategoriesSection(
    BuildContext context,
    WidgetRef ref,
    bool isExpense,
  ) {
    final orphansAsync = ref.watch(
      FutureProvider<List<CategoryModel>>((ref) async {
        final repo = ref.watch(categoriesRepositoryProvider);
        return repo.getOrphanedSubcategories(isExpense);
      }),
    );

    return orphansAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (orphans) {
        if (orphans.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Подкатегории без родителя (${orphans.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...orphans.map(
                (sub) =>
                    _buildOrphanedSubcategoryTile(context, ref, sub, isExpense),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 Секция: Все подкатегории (кнопка для перехода к полному списку)
  Widget _buildSubcategoriesSectionButton(
    BuildContext context,
    WidgetRef ref,
    bool isExpense,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: OutlinedButton.icon(
        onPressed: () => _navigateToAllSubcategories(context, ref, isExpense),
        icon: const Icon(Icons.subdirectory_arrow_right, size: 18),
        label: const Text('Все подкатегории'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  /// 🔹 Навигация к списку всех подкатегорий
  void _navigateToAllSubcategories(
    BuildContext context,
    WidgetRef ref,
    bool isExpense,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, scrollController) => AllSubcategoriesSheet(
          isExpense: isExpense,
          onClose: () => Navigator.pop(ctx),
          scrollController: scrollController,
        ),
      ),
    );
  }

  /// 🔹 Плитка «осиротевшей» подкатегории
  Widget _buildOrphanedSubcategoryTile(
    BuildContext context,
    WidgetRef ref,
    CategoryModel subcategory,
    bool isExpense,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: subcategory.colorValue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subcategory.colorValue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(subcategory.iconData, size: 24, color: subcategory.colorValue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subcategory.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Нет родителя',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) => _handleOrphanAction(
              context,
              ref,
              subcategory,
              value,
              isExpense,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'assign_parent',
                child: Text('🔗 Назначить родителя'),
              ),
              const PopupMenuItem(
                value: 'make_root',
                child: Text('🌱 Сделать корневой'),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Text('✏️ Редактировать'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('🗑️ Удалить')),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Обработка действий для «осиротевших» подкатегорий
  void _handleOrphanAction(
    BuildContext context,
    WidgetRef ref,
    CategoryModel subcategory,
    String action,
    bool isExpense,
  ) async {
    final repo = ref.read(categoriesRepositoryProvider);

    try {
      switch (action) {
        case 'assign_parent':
          await _showAssignParentDialog(context, ref, subcategory, isExpense);
          break;
        case 'make_root':
          await repo.updateCategory(subcategory.copyWith(parentId: null));
          ref.invalidate(categoriesHierarchyProvider);
          ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
          break;
        case 'edit':
          _showCategoryForm(context, ref, isExpense, subcategory);
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirm(context, subcategory);
          if (confirmed) {
            await repo.deleteCategory(subcategory.id);
            ref.invalidate(categoriesHierarchyProvider);
            ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
          }
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: AppTheme.expenseColor,
        ),
      );
    }
  }

  /// 🔹 Диалог назначения родителя
  Future<void> _showAssignParentDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryModel subcategory,
    bool isExpense,
  ) async {
    final roots = await ref
        .read(categoriesRepositoryProvider)
        .getRootCategories(isExpense);

    if (roots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала создайте корневую категорию')),
      );
      return;
    }

    CategoryModel? selectedParent;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Назначить родителя'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: roots.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final root = roots[index];
              final isSelected = selectedParent?.id == root.id;
              return ListTile(
                leading: Icon(root.iconData, color: root.colorValue),
                title: Text(root.name),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () => selectedParent = root,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: selectedParent == null
                ? null
                : () async {
                    final repo = ref.read(categoriesRepositoryProvider);
                    await repo.updateCategory(
                      subcategory.copyWith(parentId: selectedParent!.id),
                    );
                    ref.invalidate(categoriesHierarchyProvider);
                    ref
                        .read(categoriesCacheInvalidatorProvider.notifier)
                        .state++;
                    if (context.mounted) Navigator.pop(ctx);
                  },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  /// 🧱 Карточка категории с подкатегориями
  Widget _buildCategoryItem(
    BuildContext context,
    WidgetRef ref,
    CategoryModel root,
    List<CategoryModel> subs,
    bool isExpense,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showCategoryForm(context, ref, isExpense, root),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: root.colorValue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: root.colorValue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryIcon(category: root, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          root.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (root.isCustom)
                          Text(
                            'Пользовательская',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (root.isArchived)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Архив',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) =>
                        _handleMenuAction(context, ref, root, value, isExpense),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('✏️ Редактировать'),
                      ),
                      if (!root.isArchived)
                        const PopupMenuItem(
                          value: 'archive',
                          child: Text('🗄️ В архив'),
                        ),
                      if (root.isArchived)
                        const PopupMenuItem(
                          value: 'restore',
                          child: Text('♻️ Восстановить'),
                        ),
                      if (root.isCustom)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('🗑️ Удалить'),
                        ),
                      const PopupMenuItem(
                        value: 'add_sub',
                        child: Text('➕ Добавить подкатегорию'),
                      ),
                    ],
                  ),
                ],
              ),
              if (subs.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...subs.map(
                  (sub) => _buildSubcategoryItem(context, ref, sub, isExpense),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Подкатегория (упрощённый вид)
  Widget _buildSubcategoryItem(
    BuildContext context,
    WidgetRef ref,
    CategoryModel sub,
    bool isExpense,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 8),
      child: Row(
        children: [
          CategoryIcon(category: sub, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(sub.name, style: const TextStyle(fontSize: 14))),
          if (sub.isArchived)
            Text(
              'архив',
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18),
            onSelected: (value) =>
                _handleMenuAction(context, ref, sub, value, isExpense),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('✏️ Редактировать'),
              ),
              if (!sub.isArchived)
                const PopupMenuItem(
                  value: 'archive',
                  child: Text('🗄️ В архив'),
                ),
              if (sub.isArchived)
                const PopupMenuItem(
                  value: 'restore',
                  child: Text('♻️ Восстановить'),
                ),
              if (sub.isCustom)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('🗑️ Удалить'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Пустое состояние
  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isExpense) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Нет категорий', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Создайте первую категорию',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showCategoryForm(context, ref, isExpense, null),
            icon: const Icon(Icons.add),
            label: const Text('Создать категорию'),
          ),
        ],
      ),
    );
  }

  /// 🔹 Обработка действий из меню
  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
    String action,
    bool isExpense,
  ) async {
    final repo = ref.read(categoriesRepositoryProvider);

    try {
      switch (action) {
        case 'edit':
          _showCategoryForm(context, ref, isExpense, category);
          break;
        case 'archive':
          await repo.archiveCategory(category.id);
          ref.invalidate(categoriesHierarchyProvider);
          ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
          break;
        case 'restore':
          await repo.updateCategory(category.copyWith(isArchived: false));
          ref.invalidate(categoriesHierarchyProvider);
          ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirm(context, category);
          if (confirmed) {
            await repo.deleteCategory(category.id);
            ref.invalidate(categoriesHierarchyProvider);
            ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
          }
          break;
        case 'add_sub':
          _showCategoryForm(context, ref, isExpense, null, parent: category);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: AppTheme.expenseColor,
        ),
      );
    }
  }

  /// 🔹 Подтверждение удаления
  Future<bool> _showDeleteConfirm(
    BuildContext context,
    CategoryModel category,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Удалить категорию?'),
            content: Text('«${category.name}» будет удалена безвозвратно.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.expenseColor,
                ),
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 🔹 Показать форму создания/редактирования
  void _showCategoryForm(
    BuildContext context,
    WidgetRef ref,
    bool isExpense,
    CategoryModel? category, {
    CategoryModel? parent,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => CategoryFormDialog(
        isExpense: isExpense,
        category: category,
        parentCategory: parent,
        onSave: (newCategory) async {
          final repo = ref.read(categoriesRepositoryProvider);
          if (category == null) {
            await repo.insertCategory(newCategory);
          } else {
            await repo.updateCategory(newCategory);
          }
          ref.invalidate(categoriesHierarchyProvider);
          ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
        },
      ),
    );
  }
}

// ============================================================================
// 🔽 BOTTOM SHEET: Список всех подкатегорий (ВЫНЕСЕН В ТОП-ЛЕВЕЛ)
// ============================================================================

class AllSubcategoriesSheet extends ConsumerWidget {
  final bool isExpense;
  final VoidCallback onClose;
  final ScrollController scrollController;

  const AllSubcategoriesSheet({
    super.key,
    required this.isExpense,
    required this.onClose,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(
      FutureProvider<List<CategoryModel>>((ref) async {
        final repo = ref.watch(categoriesRepositoryProvider);
        return repo.getAllSubcategories(isExpense);
      }),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Все подкатегории',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isExpense ? 'Расходы' : 'Доходы',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
          ),
          const Divider(height: 1),

          // Список
          Expanded(
            child: subsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (err, _) => Center(child: Text('Ошибка: $err')),
              data: (subs) {
                if (subs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.subdirectory_arrow_right,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Нет подкатегорий',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: subs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final sub = subs[index];
                    return _SubcategoryRow(
                      sub: sub,
                      isExpense: isExpense,
                      onClose: onClose,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🧱 ВИДЖЕТ: Строка подкатегории (отдельный класс для чистоты кода)
// ============================================================================

class _SubcategoryRow extends ConsumerWidget {
  final CategoryModel sub;
  final bool isExpense;
  final VoidCallback onClose;

  const _SubcategoryRow({
    required this.sub,
    required this.isExpense,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sub.colorValue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sub.colorValue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(sub.iconData, size: 24, color: sub.colorValue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                FutureBuilder<CategoryModel?>(
                  future: ref
                      .read(categoriesRepositoryProvider)
                      .getCategoryById(sub.parentId ?? ''),
                  builder: (context, snapshot) {
                    final parent = snapshot.data;
                    return Text(
                      parent != null
                          ? 'Родитель: ${parent.name}'
                          : 'Родитель: не найден ⚠️',
                      style: TextStyle(
                        color: parent != null
                            ? Colors.grey[600]
                            : Colors.amber[700],
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) =>
                _handleSubAction(context, ref, sub, value, isExpense, onClose),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('✏️ Редактировать'),
              ),
              const PopupMenuItem(
                value: 'change_parent',
                child: Text('🔗 Сменить родителя'),
              ),
              const PopupMenuItem(
                value: 'make_root',
                child: Text('🌱 Сделать корневой'),
              ),
              if (sub.isCustom)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('🗑️ Удалить'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSubAction(
    BuildContext context,
    WidgetRef ref,
    CategoryModel sub,
    String action,
    bool isExpense,
    VoidCallback onClose,
  ) async {
    final repo = ref.read(categoriesRepositoryProvider);

    try {
      switch (action) {
        case 'edit':
          onClose(); // Закрыть шторку перед открытием диалога
          // Используем небольшой отложенный вызов, чтобы навигация успела завершиться
          Future.delayed(const Duration(milliseconds: 300), () {
            // TODO: Открыть форму редактирования (нужен доступ к _showCategoryForm)
            // Пока заглушка:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Редактирование — в разработке')),
            );
          });
          break;
        case 'change_parent':
          onClose();
          Future.delayed(const Duration(milliseconds: 300), () {
            // TODO: Показать диалог выбора родителя
          });
          break;
        case 'make_root':
          await repo.updateCategory(sub.copyWith(parentId: null));
          ref.invalidate(categoriesHierarchyProvider);
          ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirm(context, sub);
          if (confirmed) {
            await repo.deleteCategory(sub.id);
            ref.invalidate(categoriesHierarchyProvider);
            ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
          }
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: AppTheme.expenseColor,
        ),
      );
    }
  }

  /// 🔹 Локальная версия подтверждения удаления
  Future<bool> _showDeleteConfirm(
    BuildContext context,
    CategoryModel category,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Удалить подкатегорию?'),
            content: Text('«${category.name}» будет удалена безвозвратно.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.expenseColor,
                ),
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
