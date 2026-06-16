// Файл: lib/features/categories/categories_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/localization/app_strings.dart';
import '../../common/models/category_model.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/utils/app_theme.dart';
import '../../common/widgets/category_icon.dart';
import 'category_form_dialog.dart';

final categorySearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expanded = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isExpense =
        ModalRoute.of(context)?.settings.arguments as bool? ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isExpense
              ? (strings.isRu ? 'Категории расходов' : 'Expense categories')
              : (strings.isRu ? 'Категории доходов' : 'Income categories'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            // Верхняя правая кнопка переключает экран между расходными
            // и доходными категориями без возврата назад.
            icon: Icon(
              isExpense
                  ? Icons.trending_down_rounded
                  : Icons.trending_up_rounded,
            ),
            tooltip: isExpense
                ? (strings.isRu ? 'Показать доходы' : 'Show income categories')
                : (strings.isRu
                      ? 'Показать расходы'
                      : 'Show expense categories'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesScreen(),
                  settings: RouteSettings(arguments: !isExpense),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context, ref, strings),
          Expanded(
            child: _buildCategoriesList(context, ref, isExpense, strings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Нижняя кнопка создает новую основную категорию текущего типа.
        onPressed: () => _showCategoryForm(context, ref, isExpense, null),
        icon: const Icon(Icons.add),
        label: Text(strings.add),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) {
    final colors = AppTheme.colorsOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        AppTheme.pagePadding,
        AppTheme.pagePadding,
        8,
      ),
      child: TextField(
        // Поиск фильтрует категории по названию и AI-тегу.
        controller: _searchController,
        decoration: InputDecoration(
          hintText: strings.isRu
              ? 'Поиск категории или AI-тега...'
              : 'Search category or AI tag...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(categorySearchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                ),
          filled: true,
          fillColor: colors.surface,
        ),
        onChanged: (query) {
          ref.read(categorySearchQueryProvider.notifier).state = query.trim();
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    WidgetRef ref,
    bool isExpense,
    AppStrings strings,
  ) {
    final hierarchyAsync = ref.watch(categoriesHierarchyProvider(isExpense));
    final searchQuery = ref.watch(categorySearchQueryProvider).toLowerCase();

    return hierarchyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (hierarchy) {
        final visibleRoots = _filterHierarchy(hierarchy, searchQuery);
        if (visibleRoots.isEmpty) {
          return _buildEmptyState(context, ref, isExpense, strings);
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          buildDefaultDragHandles: false,
          itemCount: visibleRoots.length,
          onReorder: searchQuery.isNotEmpty
              ? (_, __) {}
              : (oldIndex, newIndex) =>
                    _reorderRoots(ref, visibleRoots, oldIndex, newIndex),
          itemBuilder: (context, index) {
            final root = visibleRoots[index];
            final subs = hierarchy[root] ?? const <CategoryModel>[];
            final filteredSubs = searchQuery.isEmpty
                ? subs
                : subs.where((sub) => _matches(sub, searchQuery)).toList();
            // В обычном режиме подкатегории видны только после раскрытия
            // родителя; при поиске показываем совпавшие подкатегории сразу.
            final shouldShowSubcategories =
                _expanded.contains(root.id) ||
                (searchQuery.isNotEmpty && filteredSubs.isNotEmpty);

            return Container(
              key: ValueKey(root.id),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: AppTheme.surfaceCardDecoration(
                context,
                radius: AppTheme.radiusLg,
                color: root.colorValue.withOpacity(0.08),
                borderColor: root.colorValue.withOpacity(0.28),
              ),
              child: Column(
                children: [
                  _buildRootTile(
                    context,
                    ref,
                    root,
                    filteredSubs,
                    isExpense,
                    strings,
                    reorderIndex: index,
                    showReorderHandle: searchQuery.isEmpty,
                  ),
                  if (shouldShowSubcategories)
                    _buildSubcategoriesSection(
                      context,
                      ref,
                      root,
                      filteredSubs,
                      strings,
                      searchQuery.isEmpty,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<CategoryModel> _filterHierarchy(
    Map<CategoryModel, List<CategoryModel>> hierarchy,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) {
      return hierarchy.keys.toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    }

    final roots = <CategoryModel>[];
    for (final entry in hierarchy.entries) {
      final root = entry.key;
      final subs = entry.value;

      final rootMatches = _matches(root, searchQuery);
      final subMatches = subs.any((sub) => _matches(sub, searchQuery));
      if (rootMatches || subMatches) {
        roots.add(root);
        _expanded.add(root.id);
      }
    }

    roots.sort((a, b) => a.order.compareTo(b.order));
    return roots;
  }

  bool _matches(CategoryModel category, String query) {
    return category.name.toLowerCase().contains(query) ||
        (category.aiTag?.toLowerCase().contains(query) ?? false);
  }

  Widget _buildRootTile(
    BuildContext context,
    WidgetRef ref,
    CategoryModel root,
    List<CategoryModel> subs,
    bool isExpense,
    AppStrings strings, {
    required int reorderIndex,
    required bool showReorderHandle,
  }) {
    final isExpanded = _expanded.contains(root.id);

    return InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expanded.remove(root.id);
          } else {
            _expanded.add(root.id);
          }
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryIcon(category: root, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    root.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subs.isEmpty
                        ? (strings.isRu
                              ? 'Без подкатегорий'
                              : 'No subcategories')
                        : (strings.isRu
                              ? '${subs.length} подкатегорий'
                              : '${subs.length} subcategories'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedTextOf(context),
                    ),
                  ),
                  if (root.aiTag?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    _AiTagPill(value: root.aiTag!),
                  ],
                ],
              ),
            ),
            if (showReorderHandle)
              ReorderableDragStartListener(
                index: reorderIndex,
                child: Icon(
                  Icons.drag_handle_rounded,
                  color: AppTheme.mutedTextOf(context),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(
                context,
                ref,
                root,
                value,
                isExpense,
                strings,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(strings.editCategory)),
                PopupMenuItem(
                  value: 'add_sub',
                  child: Text(
                    strings.isRu ? 'Добавить подкатегорию' : 'Add subcategory',
                  ),
                ),
                PopupMenuItem(
                  value: 'archive',
                  child: Text(strings.isRu ? 'В архив' : 'Archive'),
                ),
                if (root.isCustom)
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(strings.isRu ? 'Удалить' : 'Delete'),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              isExpanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: AppTheme.mutedTextOf(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesSection(
    BuildContext context,
    WidgetRef ref,
    CategoryModel root,
    List<CategoryModel> subcategories,
    AppStrings strings,
    bool allowReorder,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Divider(color: AppTheme.colorsOf(context).border),
          if (subcategories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  strings.isRu
                      ? 'Подкатегорий пока нет'
                      : 'No subcategories yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedTextOf(context),
                  ),
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: subcategories.length,
              onReorder: allowReorder
                  ? (oldIndex, newIndex) => _reorderSubcategories(
                      ref,
                      subcategories,
                      oldIndex,
                      newIndex,
                    )
                  : (_, __) {},
              itemBuilder: (context, index) {
                final sub = subcategories[index];
                return ListTile(
                  key: ValueKey(sub.id),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: CategoryIcon(category: sub, size: 20),
                  title: Text(sub.name),
                  subtitle: sub.aiTag?.trim().isNotEmpty == true
                      ? Text(
                          'AI: ${sub.aiTag}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.mutedTextOf(context)),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (allowReorder)
                        ReorderableDragStartListener(
                          index: index,
                          child: Icon(
                            Icons.drag_handle_rounded,
                            color: AppTheme.mutedTextOf(context),
                          ),
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleSubcategoryAction(
                          context,
                          ref,
                          sub,
                          value,
                          strings,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(strings.editCategory),
                          ),
                          PopupMenuItem(
                            value: 'make_root',
                            child: Text(
                              strings.isRu ? 'Сделать корневой' : 'Make root',
                            ),
                          ),
                          PopupMenuItem(
                            value: 'archive',
                            child: Text(strings.isRu ? 'В архив' : 'Archive'),
                          ),
                          if (sub.isCustom)
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(strings.isRu ? 'Удалить' : 'Delete'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    bool isExpense,
    AppStrings strings,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.colorsOf(context).surfaceSoft,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Icon(
              Icons.category_outlined,
              size: 40,
              color: AppTheme.mutedTextOf(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.isRu ? 'Нет категорий' : 'No categories',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            strings.isRu
                ? 'Создайте первую категорию'
                : 'Create your first category',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedTextOf(context),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showCategoryForm(context, ref, isExpense, null),
            icon: const Icon(Icons.add),
            label: Text(strings.createCategory),
          ),
        ],
      ),
    );
  }

  Future<void> _reorderRoots(
    WidgetRef ref,
    List<CategoryModel> roots,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;
    final next = [...roots];
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    await ref.read(categoriesRepositoryProvider).reorderCategories(next);
    ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
  }

  Future<void> _reorderSubcategories(
    WidgetRef ref,
    List<CategoryModel> subcategories,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) newIndex--;
    final next = [...subcategories];
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    await ref.read(categoriesRepositoryProvider).reorderCategories(next);
    ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
    String action,
    bool isExpense,
    AppStrings strings,
  ) async {
    final repo = ref.read(categoriesRepositoryProvider);

    try {
      switch (action) {
        case 'edit':
          _showCategoryForm(context, ref, isExpense, category);
          break;
        case 'add_sub':
          _showCategoryForm(context, ref, isExpense, null, parent: category);
          break;
        case 'archive':
          if (await _showArchiveConfirm(context, category, strings)) {
            await repo.archiveCategory(category.id);
          }
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirm(
            context,
            category,
            strings,
          );
          if (confirmed) await repo.deleteCategory(category.id);
          break;
      }

      ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.colorsOf(context).expense,
        ),
      );
    }
  }

  Future<void> _handleSubcategoryAction(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
    String action,
    AppStrings strings,
  ) async {
    final repo = ref.read(categoriesRepositoryProvider);

    try {
      switch (action) {
        case 'edit':
          _showCategoryForm(context, ref, category.isExpense, category);
          return;
        case 'make_root':
          await repo.updateCategory(category.copyWith(parentId: null));
          break;
        case 'archive':
          if (await _showArchiveConfirm(context, category, strings)) {
            await repo.archiveCategory(category.id);
          }
          break;
        case 'delete':
          final confirmed = await _showDeleteConfirm(
            context,
            category,
            strings,
          );
          if (confirmed) await repo.deleteCategory(category.id);
          break;
      }

      ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.colorsOf(context).expense,
        ),
      );
    }
  }

  Future<bool> _showArchiveConfirm(
    BuildContext context,
    CategoryModel category,
    AppStrings strings,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              strings.isRu ? 'Архивировать категорию?' : 'Archive category?',
            ),
            content: Text(
              strings.isRu
                  ? 'Категория «${category.name}» исчезнет из выбора, но останется в данных.'
                  : 'The category "${category.name}" will disappear from selection but remain in stored data.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(strings.cancel),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(strings.isRu ? 'В архив' : 'Archive'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showDeleteConfirm(
    BuildContext context,
    CategoryModel category,
    AppStrings strings,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              strings.isRu ? 'Удалить категорию?' : 'Delete category?',
            ),
            content: Text(
              strings.isRu
                  ? '«${category.name}» будет удалена безвозвратно.'
                  : '"${category.name}" will be deleted permanently.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.colorsOf(ctx).expense,
                ),
                child: Text(strings.isRu ? 'Удалить' : 'Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showCategoryForm(
    BuildContext context,
    WidgetRef ref,
    bool isExpense,
    CategoryModel? category, {
    CategoryModel? parent,
  }) {
    showDialog(
      context: context,
      builder: (_) => CategoryFormDialog(
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
          ref.read(categoriesCacheInvalidatorProvider.notifier).state++;
        },
      ),
    );
  }
}

class _AiTagPill extends StatelessWidget {
  const _AiTagPill({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        'AI: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.mutedTextOf(context),
        ),
      ),
    );
  }
}
