// Файл: lib/common/providers/categories_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../repositories/categories_repository.dart';
import 'database_provider.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoriesRepository(db);
});

final categoriesCacheInvalidatorProvider = StateProvider<int>((ref) => 0);

final allCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  ref.watch(categoriesCacheInvalidatorProvider);
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo.getAllCategories();
});

final expenseCategoriesProvider = FutureProvider<List<CategoryModel>>((
  ref,
) async {
  final categories = await ref.watch(allCategoriesProvider.future);
  return categories
      .where(
        (item) => item.isExpense && item.parentId == null && !item.isArchived,
      )
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
});

final incomeCategoriesProvider = FutureProvider<List<CategoryModel>>((
  ref,
) async {
  final categories = await ref.watch(allCategoriesProvider.future);
  return categories
      .where(
        (item) => !item.isExpense && item.parentId == null && !item.isArchived,
      )
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
});

final categoriesHierarchyProvider =
    FutureProvider.family<Map<CategoryModel, List<CategoryModel>>, bool>((
      ref,
      isExpense,
    ) async {
      final categories = await ref.watch(allCategoriesProvider.future);
      final roots =
          categories
              .where(
                (item) =>
                    item.isExpense == isExpense &&
                    item.parentId == null &&
                    !item.isArchived,
              )
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

      final result = <CategoryModel, List<CategoryModel>>{};
      for (final root in roots) {
        result[root] =
            categories
                .where(
                  (item) =>
                      item.parentId == root.id &&
                      item.isExpense == isExpense &&
                      !item.isArchived,
                )
                .toList()
              ..sort((a, b) => a.order.compareTo(b.order));
      }

      return result;
    });

final subcategoriesProvider =
    FutureProvider.family<List<CategoryModel>, String>((ref, parentId) async {
      final categories = await ref.watch(allCategoriesProvider.future);
      return categories
          .where((item) => item.parentId == parentId && !item.isArchived)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    });

FutureProvider<List<CategoryModel>> createInvalidatableCategoriesProvider(
  Future<List<CategoryModel>> Function(CategoriesRepository) fetcher,
) {
  return FutureProvider((ref) async {
    ref.watch(categoriesCacheInvalidatorProvider);
    final repo = ref.watch(categoriesRepositoryProvider);
    return fetcher(repo);
  });
}
