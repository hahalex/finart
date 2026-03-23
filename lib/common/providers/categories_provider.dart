import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/categories_repository.dart';
import '../models/category_model.dart';
import 'database_provider.dart';

/// 🔹 Базовый провайдер репозитория
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoriesRepository(db);
});

/// 🔹 Все активные категории (кэшируются)
final allCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo.getAllCategories();
});

/// 🔹 Только расходы (корневые)
final expenseCategoriesProvider = FutureProvider<List<CategoryModel>>((
  ref,
) async {
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo.getRootCategories(true);
});

/// 🔹 Только доходы (корневые)
final incomeCategoriesProvider = FutureProvider<List<CategoryModel>>((
  ref,
) async {
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo.getRootCategories(false);
});

/// 🔹 Иерархия для picker (кэшируется при изменении isExpense)
final categoriesHierarchyProvider =
    FutureProvider.family<Map<CategoryModel, List<CategoryModel>>, bool>((
      ref,
      isExpense,
    ) async {
      final repo = ref.watch(categoriesRepositoryProvider);
      return repo.getCategoriesHierarchy(isExpense);
    });

/// 🔹 Подкатегории для конкретной родительской категории
final subcategoriesProvider =
    FutureProvider.family<List<CategoryModel>, String>((ref, parentId) async {
      final repo = ref.watch(categoriesRepositoryProvider);
      return repo.getSubcategories(parentId);
    });

/// 🔹 Провайдер для инвалидации кэша после изменений
final categoriesCacheInvalidatorProvider = StateProvider<int>((ref) => 0);

/// 🔹 Helper: получить провайдер с учётом инвалидации
FutureProvider<List<CategoryModel>> createInvalidatableCategoriesProvider(
  Future<List<CategoryModel>> Function(CategoriesRepository) fetcher,
) {
  return FutureProvider((ref) async {
    ref.watch(categoriesCacheInvalidatorProvider); // подписка на изменения
    final repo = ref.watch(categoriesRepositoryProvider);
    return fetcher(repo);
  });
}
