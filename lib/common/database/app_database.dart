// Файл: lib/common/database/app_database.dart.
// Назначение: описывает таблицы Drift и структуру локальной базы данных.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/local/db/ai_learning_table.dart';
import 'account_operations_table.dart';
import 'accounts_table.dart';
import 'categories_table.dart';
import 'planned_payments_table.dart';
import 'transactions_table.dart';
import 'user_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CategoriesTable,
    AccountsTable,
    AccountOperationsTable,
    TransactionsTable,
    UserTable,
    PlannedPaymentsTable,
    AiLearning,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultAccount();
    },
    onUpgrade: (m, from, to) async {
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

      if (from < 4) {
        await m.addColumn(userTable, userTable.avatarPath);
      }

      if (from < 5) {
        await m.createTable(aiLearning);
      }

      if (from < 6) {
        await m.addColumn(aiLearning, aiLearning.normalizedText);
        await customStatement('''
          UPDATE ai_learning
          SET normalized_text = trim(lower(keyword))
          WHERE normalized_text IS NULL OR normalized_text = ''
          ''');
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_ai_learning_normalized_text ON ai_learning (normalized_text)',
        );
      }

      if (from < 7) {
        await m.createTable(accountsTable);
        await _seedDefaultAccount();
        await m.addColumn(transactionsTable, transactionsTable.accountId);
        await m.addColumn(plannedPaymentsTable, plannedPaymentsTable.accountId);
        await customStatement(
          "UPDATE transactions_table SET account_id = 'main_account' WHERE account_id IS NULL",
        );
        await customStatement(
          "UPDATE planned_payments_table SET account_id = 'main_account' WHERE account_id IS NULL",
        );
      }

      if (from < 8) {
        await m.createTable(accountOperationsTable);
        await m.addColumn(
          plannedPaymentsTable,
          plannedPaymentsTable.paymentType,
        );
      }

      if (from < 9) {
        await m.addColumn(accountsTable, accountsTable.summary);
      }
    },
  );

  Future<void> _seedDefaultAccount() async {
    final exists = await (select(accountsTable)..limit(1)).getSingleOrNull();
    if (exists != null) return;

    final now = DateTime.now();
    await into(accountsTable).insert(
      AccountsTableCompanion(
        id: const Value('main_account'),
        name: const Value('Основной счет'),
        type: const Value('main'),
        balance: const Value(0),
        summary: const Value(
          'Основной счет синхронизируется с балансом записей за выбранный месяц.',
        ),
        isDefault: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

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
