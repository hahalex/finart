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

  /// 🔹 НОВОЕ: иерархия для UI
  Future<Map<CategoryModel, List<CategoryModel>>> getCategoriesHierarchy(
    bool isExpense,
  ) async {
    final roots = await getRootCategories(isExpense);
    final result = <CategoryModel, List<CategoryModel>>{};

    for (final root in roots) {
      final subs = await getSubcategories(root.id);
      result[root] = subs;
    }
    return result;
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    final row = await (_db.select(
      _db.categoriesTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    return row != null ? _fromTableData(row) : null;
  }

  /// ✅ Проверка: используется ли категория в транзакциях
  Future<bool> isCategoryUsed(String categoryId) async {
    final rows = await (_db.select(
      _db.transactionsTable,
    )..where((t) => t.categoryId.equals(categoryId))).get();
    return rows.isNotEmpty;
  }

  /// ✅ Проверка: есть ли категории в БД
  Future<bool> hasCategories() async {
    final rows = await (_db.select(_db.categoriesTable)..limit(1)).get();
    return rows.isNotEmpty;
  }

  // ============================================================================
  // ✏️ CRUD
  // ============================================================================

  Future<void> insertCategory(CategoryModel category) async {
    await _db
        .into(_db.categoriesTable)
        .insert(
          CategoriesTableCompanion.insert(
            // ✅ .insert() → сырые значения!
            id: category.id,
            name: category.name,
            iconCode: category.iconCode,
            isExpense: category.isExpense,
            parentId: category.parentId,
            color: category.color,
            isCustom: category.isCustom,
            isArchived: category.isArchived,
            order: category.order,
            aiTag: category.aiTag,
          ),
        );
  }

  Future<void> updateCategory(CategoryModel category) async {
    await (_db.update(
      _db.categoriesTable,
    )..where((t) => t.id.equals(category.id))).write(
      CategoriesTableCompanion(
        // ✅ Обычный конструктор → с Value()
        name: Value(category.name),
        iconCode: Value(category.iconCode),
        parentId: Value(category.parentId),
        color: Value(category.color),
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
    if (category == null) throw Exception('Категория не найдена');
    if (!category.isCustom)
      throw Exception('Нельзя удалить системную категорию');
    if (await isCategoryUsed(id)) {
      throw Exception('Нельзя удалить: категория используется в транзакциях');
    }

    final subs = await getSubcategories(id);
    for (final sub in subs) {
      await archiveCategory(sub.id);
    }
    await (_db.delete(_db.categoriesTable)..where((t) => t.id.equals(id))).go();
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
