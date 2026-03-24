import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/category_model.dart';

class CategoriesRepository {
  final AppDatabase _db;
  CategoriesRepository(this._db);

  // ============================================================================
  // 🔍 ЧТЕНИЕ
  // ============================================================================

  Future<List<CategoryModel>> getAllCategories({
    bool includeArchived = false,
  }) async {
    final query = _db.select(_db.categoriesTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.order),
        (t) => OrderingTerm(expression: t.name),
      ]);

    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }

    final rows = await query.get();
    return rows.map(_fromTableData).toList();
  }

  Future<List<CategoryModel>> getRootCategories(bool isExpense) async {
    final rows =
        await (_db.select(_db.categoriesTable)
              ..where((t) => t.isExpense.equals(isExpense))
              ..where((t) => t.parentId.isNull())
              ..where((t) => t.isArchived.equals(false))
              ..orderBy([(t) => OrderingTerm(expression: t.order)]))
            .get();

    return rows.map(_fromTableData).toList();
  }

  Future<List<CategoryModel>> getSubcategories(String parentId) async {
    final rows =
        await (_db.select(_db.categoriesTable)
              ..where((t) => t.parentId.equals(parentId))
              ..where((t) => t.isArchived.equals(false))
              ..orderBy([(t) => OrderingTerm(expression: t.order)]))
            .get();

    return rows.map(_fromTableData).toList();
  }

  Future<Map<CategoryModel, List<CategoryModel>>> getCategoriesHierarchy(
    bool isExpense,
  ) async {
    final roots = await getRootCategories(isExpense);
    final result = <CategoryModel, List<CategoryModel>>{};

    for (final root in roots) {
      result[root] = await getSubcategories(root.id);
    }

    return result;
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final row = await (_db.select(
      _db.categoriesTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    return row != null ? _fromTableData(row) : null;
  }

  Future<bool> isCategoryUsed(String categoryId) async {
    final rows = await (_db.select(
      _db.transactionsTable,
    )..where((t) => t.categoryId.equals(categoryId))).get();

    return rows.isNotEmpty;
  }

  Future<bool> hasCategories() async {
    final rows = await (_db.select(_db.categoriesTable)..limit(1)).get();
    return rows.isNotEmpty;
  }

  // ============================================================================
  // ✏️ CRUD — ВСЁ через Value()
  // ============================================================================

  Future<void> insertCategory(CategoryModel category) async {
    await _db
        .into(_db.categoriesTable)
        .insert(
          CategoriesTableCompanion(
            id: Value(category.id),
            name: Value(category.name),
            iconCode: Value(category.iconCode),
            isExpense: Value(category.isExpense),
            color: Value(category.color),
            parentId: Value(category.parentId),
            isCustom: Value(category.isCustom),
            isArchived: Value(category.isArchived),
            order: Value(category.order),
            aiTag: Value(category.aiTag),
          ),
        );
  }

  Future<void> updateCategory(CategoryModel category) async {
    await (_db.update(
      _db.categoriesTable,
    )..where((t) => t.id.equals(category.id))).write(
      CategoriesTableCompanion(
        name: Value(category.name),
        iconCode: Value(category.iconCode),
        color: Value(category.color),
        parentId: Value(category.parentId),
        isCustom: Value(category.isCustom),
        isArchived: Value(category.isArchived),
        order: Value(category.order),
        aiTag: Value(category.aiTag),
      ),
    );
  }

  Future<void> archiveCategory(String id) async {
    if (await isCategoryUsed(id)) {
      throw Exception(
        'Нельзя архивировать: категория используется в транзакциях',
      );
    }

    await (_db.update(_db.categoriesTable)..where((t) => t.id.equals(id)))
        .write(const CategoriesTableCompanion(isArchived: Value(true)));
  }

  Future<void> deleteCategory(String id) async {
    final category = await getCategoryById(id);

    if (category == null) {
      throw Exception('Категория не найдена');
    }

    if (!category.isCustom) {
      throw Exception('Нельзя удалить системную категорию');
    }

    if (await isCategoryUsed(id)) {
      throw Exception('Нельзя удалить: категория используется в транзакциях');
    }

    final subs = await getSubcategories(id);

    for (final sub in subs) {
      await archiveCategory(sub.id);
    }

    await (_db.delete(_db.categoriesTable)..where((t) => t.id.equals(id))).go();
  }

  /// 🔹 Подкатегории, у которых нет родителя (или родитель не найден)
  Future<List<CategoryModel>> getOrphanedSubcategories(bool isExpense) async {
    // Сначала получаем все валидные корневые категории
    final validParents =
        await (_db.select(_db.categoriesTable)
              ..where((t) => t.isExpense.equals(isExpense))
              ..where((t) => t.parentId.isNull())
              ..where((t) => t.isArchived.equals(false)))
            .get()
            .then((rows) => rows.map((r) => r.id).toSet());

    // Теперь ищем подкатегории, чей родитель НЕ в списке валидных
    final rows =
        await (_db.select(_db.categoriesTable)
              ..where((t) => t.isExpense.equals(isExpense))
              ..where((t) => t.parentId.isNotNull())
              ..where((t) => t.isArchived.equals(false)))
            .get();

    return rows
        .where((r) => r.parentId != null && !validParents.contains(r.parentId))
        .map(_fromTableData)
        .toList();
  }

  /// 🔹 Все подкатегории (для отдельного экрана)
  Future<List<CategoryModel>> getAllSubcategories(bool isExpense) async {
    final rows =
        await (_db.select(_db.categoriesTable)
              ..where((t) => t.isExpense.equals(isExpense))
              ..where((t) => t.parentId.isNotNull())
              ..where((t) => t.isArchived.equals(false))
              ..orderBy([(t) => OrderingTerm(expression: t.order)]))
            .get();

    return rows.map(_fromTableData).toList();
  }

  // ============================================================================
  // 🔧 Утилиты
  // ============================================================================

  CategoryModel _fromTableData(CategoriesTableData row) {
    return CategoryModel(
      id: row.id,
      name: row.name,
      iconCode: row.iconCode,
      isExpense: row.isExpense,
      parentId: row.parentId,
      color: row.color,
      isCustom: row.isCustom,
      isArchived: row.isArchived,
      order: row.order,
      aiTag: row.aiTag,
    );
  }

  String generateCategoryId(String name) {
    final base = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    return '${base}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
