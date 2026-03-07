import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'categories_table.dart';
import 'transactions_table.dart';
import 'user_table.dart';
import 'planned_payments_table.dart';

part 'app_database.g.dart';

/// Главная база данных приложения
@DriftDatabase(
  tables: [CategoriesTable, TransactionsTable, UserTable, PlannedPaymentsTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Миграция с версии 1 на 2: создаём таблицу planned_payments
          await m.createTable(plannedPaymentsTable);
        }
        // Если в будущем будет версия 3, добавим: if (from < 3) { ... }
      },
      beforeOpen: (details) async {
        // Опционально: можно добавить логирование или проверку
        // print('Database opened: ${details.wasCreated}');
      },
    );
  }

  // Добавим методы для работы с пользователем
  Future<UserTableData?> getUser() => select(userTable).getSingleOrNull();

  Future<void> insertUser(UserTableCompanion user) =>
      into(userTable).insert(user, mode: InsertMode.insertOrReplace);

  Future<void> updateUser(UserTableCompanion user) =>
      update(userTable).replace(user);
}

/// Открытие подключения к SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'finart.sqlite'));
    return NativeDatabase(file);
  });
}
