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
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultCategories();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(plannedPaymentsTable);

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

  /// ✅ Сид дефолтных категорий (ПРАВИЛЬНО)
  Future<void> _seedDefaultCategories() async {
    final exists = await (select(categoriesTable)..limit(1)).getSingleOrNull();
    if (exists != null) return;

    final defaults = [
      CategoriesTableCompanion(
        id: const Value('food'),
        name: const Value('Еда'),
        iconCode: Value(Icons.fastfood.codePoint),
        isExpense: const Value(true),
        color: const Value(0xFFFF9800),
        parentId: const Value(null),
        isCustom: const Value(false),
        isArchived: const Value(false),
        order: const Value(0),
        aiTag: const Value('food'),
      ),
      CategoriesTableCompanion(
        id: const Value('transport'),
        name: const Value('Транспорт'),
        iconCode: Value(Icons.directions_bus.codePoint),
        isExpense: const Value(true),
        color: const Value(0xFF2196F3),
        parentId: const Value(null),
        isCustom: const Value(false),
        isArchived: const Value(false),
        order: const Value(1),
        aiTag: const Value('transport'),
      ),
      CategoriesTableCompanion(
        id: const Value('entertainment'),
        name: const Value('Развлечения'),
        iconCode: Value(Icons.movie.codePoint),
        isExpense: const Value(true),
        color: const Value(0xFF9C27B0),
        parentId: const Value(null),
        isCustom: const Value(false),
        isArchived: const Value(false),
        order: const Value(2),
        aiTag: const Value('entertainment'),
      ),
      CategoriesTableCompanion(
        id: const Value('games'),
        name: const Value('Игры'),
        iconCode: Value(Icons.sports_esports.codePoint),
        isExpense: const Value(true),
        color: const Value(0xFF4CAF50),
        parentId: const Value(null),
        isCustom: const Value(false),
        isArchived: const Value(false),
        order: const Value(3),
        aiTag: const Value('entertainment'),
      ),
      CategoriesTableCompanion(
        id: const Value('subscriptions'),
        name: const Value('Подписки'),
        iconCode: Value(Icons.repeat.codePoint),
        isExpense: const Value(true),
        color: const Value(0xFF607D8B),
        parentId: const Value(null),
        isCustom: const Value(false),
        isArchived: const Value(false),
        order: const Value(4),
        aiTag: const Value('subscriptions'),
      ),
      CategoriesTableCompanion(
        id: const Value('salary'),
        name: const Value('Зарплата'),
        iconCode: Value(Icons.payments.codePoint),
        isExpense: const Value(false),
        color: const Value(0xFF4CAF50),
        parentId: const Value(null),
        isCustom: const Value(false),
        isArchived: const Value(false),
        order: const Value(0),
        aiTag: const Value('income'),
      ),
      CategoriesTableCompanion(
        id: const Value('gift'),
        name: const Value('Подарок'),
        iconCode: Value(Icons.card_giftcard.codePoint),
        isExpense: const Value(false),
        color: const Value(0xFFE91E63),
        parentId: const Value(null),
        isCustom: const Value(false),
        isArchived: const Value(false),
        order: const Value(1),
        aiTag: const Value('income'),
      ),
    ];

    for (final c in defaults) {
      await into(categoriesTable).insert(c, mode: InsertMode.insertOrIgnore);
    }
  }

  // Методы для пользователя
  Future<UserTableData?> getUser() =>
      (select(userTable)..limit(1)).getSingleOrNull();

  Future<void> insertUser(UserTableCompanion user) =>
      into(userTable).insert(user, mode: InsertMode.insertOrReplace);

  Future<void> updateUser(UserTableCompanion user) =>
      update(userTable).replace(user);
}

/// Подключение к SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'finart.sqlite'));
    return NativeDatabase(file);
  });
}
