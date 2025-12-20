import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/category_model.dart';

/// Репозиторий для работы с категориями
class CategoriesRepository {
  final AppDatabase _db;

  CategoriesRepository(this._db);

  /// Получить все категории
  Future<List<CategoryModel>> getAllCategories() async {
    final rows = await _db.select(_db.categoriesTable).get();

    return rows.map((row) {
      return CategoryModel(
        id: row.id,
        name: row.name,
        icon: IconData(row.iconCode, fontFamily: 'MaterialIcons'),
        isExpense: row.isExpense,
      );
    }).toList();
  }

  /// Добавить категорию
  Future<void> insertCategory(CategoryModel category) async {
    await _db
        .into(_db.categoriesTable)
        .insert(
          CategoriesTableCompanion.insert(
            id: category.id,
            name: category.name,
            iconCode: category.icon.codePoint,
            isExpense: category.isExpense,
          ),
        );
  }

  /// Проверка: есть ли категории в БД
  Future<bool> hasCategories() async {
    final count = await _db
        .select(_db.categoriesTable)
        .get()
        .then((e) => e.length);
    return count > 0;
  }
}
