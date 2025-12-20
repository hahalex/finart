import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'categories_table.dart';
import 'transactions_table.dart';
import 'user_table.dart';

part 'app_database.g.dart';

/// Главная база данных приложения
@DriftDatabase(tables: [CategoriesTable, TransactionsTable, UserTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
