// Файл: lib/common/providers/categories_repository_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/categories_repository.dart';
import 'database_provider.dart';

/// Provider репозитория категорий
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoriesRepository(db);
});
