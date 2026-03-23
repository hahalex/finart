import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'categories_table.dart';
import 'transactions_table.dart';
import 'user_table.dart';
import 'planned_payments_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [CategoriesTable, TransactionsTable, UserTable, PlannedPaymentsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultCategories();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(plannedPaymentsTable);
        }
        if (from < 3) {
          await m.addColumn(categoriesTable, categoriesTable.parentId);
          await m.addColumn(categoriesTable, categoriesTable.color);
          await m.addColumn(categoriesTable, categoriesTable.isCustom);
          await m.addColumn(categoriesTable, categoriesTable.isArchived);
          await m.addColumn(categoriesTable, categoriesTable.order);
          await m.addColumn(categoriesTable, categoriesTable.aiTag);
        }
      },
    );
  }

  /// Сид дефолтных категорий
  Future<void> _seedDefaultCategories() async {
    // Проверяем, есть ли уже категории
    final exists = await (select(categoriesTable)..limit(1)).getSingleOrNull();
    if (exists != null) return;

    // ✅ ПРАВИЛЬНО: Companion.insert() принимает СЫРЫЕ значения, БЕЗ Value()!
    final defaults = [
      CategoriesTableCompanion.insert(
        id: 'food',
        name: 'Еда',
        iconCode: Icons.fastfood.codePoint, // ✅ int
        isExpense: true, // ✅ bool
        parentId: null, // ✅ null для nullable
        color: 0xFFFF9800, // ✅ int
        isCustom: false, // ✅ bool
        isArchived: false,
        order: 0,
        aiTag: 'food', // ✅ String для nullable
      ),
      CategoriesTableCompanion.insert(
        id: 'transport',
        name: 'Транспорт',
        iconCode: Icons.directions_bus.codePoint,
        isExpense: true,
        parentId: null,
        color: 0xFF2196F3,
        isCustom: false,
        isArchived: false,
        order: 1,
        aiTag: 'transport',
      ),
      CategoriesTableCompanion.insert(
        id: 'entertainment',
        name: 'Развлечения',
        iconCode: Icons.movie.codePoint,
        isExpense: true,
        parentId: null,
        color: 0xFF9C27B0,
        isCustom: false,
        isArchived: false,
        order: 2,
        aiTag: 'entertainment',
      ),
      CategoriesTableCompanion.insert(
        id: 'games',
        name: 'Игры',
        iconCode: Icons.sports_esports.codePoint,
        isExpense: true,
        parentId: null,
        color: 0xFF4CAF50,
        isCustom: false,
        isArchived: false,
        order: 3,
        aiTag: 'entertainment',
      ),
      CategoriesTableCompanion.insert(
        id: 'subscriptions',
        name: 'Подписки',
        iconCode: Icons.repeat.codePoint,
        isExpense: true,
        parentId: null,
        color: 0xFF607D8B,
        isCustom: false,
        isArchived: false,
        order: 4,
        aiTag: 'subscriptions',
      ),
      CategoriesTableCompanion.insert(
        id: 'salary',
        name: 'Зарплата',
        iconCode: Icons.payments.codePoint,
        isExpense: false,
        parentId: null,
        color: 0xFF4CAF50,
        isCustom: false,
        isArchived: false,
        order: 0,
        aiTag: 'income',
      ),
      CategoriesTableCompanion.insert(
        id: 'gift',
        name: 'Подарок',
        iconCode: Icons.card_giftcard.codePoint,
        isExpense: false,
        parentId: null,
        color: 0xFFE91E63,
        isCustom: false,
        isArchived: false,
        order: 1,
        aiTag: 'income',
      ),
    ];

    for (final category in defaults) {
      await into(
        categoriesTable,
      ).insert(category, mode: InsertMode.insertOrIgnore);
    }
  }

  // Методы для работы с пользователем
  Future<UserTableData?> getUser() =>
      (select(userTable)..limit(1)).getSingleOrNull();
  Future<void> insertUser(UserTableCompanion user) =>
      into(userTable).insert(user, mode: InsertMode.insertOrReplace);
  Future<void> updateUser(UserTableCompanion user) =>
      update(userTable).replace(user);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'finart.sqlite'));
    return NativeDatabase(file);
  });
}
