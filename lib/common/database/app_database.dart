import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'categories_table.dart';
import 'transactions_table.dart';

part 'app_database.g.dart';

/// Главная база данных приложения
@DriftDatabase(tables: [CategoriesTable, TransactionsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Версия базы данных
  @override
  int get schemaVersion => 1;
}

/// Открытие подключения к SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'finart.sqlite'));
    return NativeDatabase(file);
  });
}
