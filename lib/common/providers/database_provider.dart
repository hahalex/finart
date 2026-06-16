// Файл: lib/common/providers/database_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

/// Provider базы данных (Singleton)
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  /// Закрываем БД при уничтожении provider'а
  ref.onDispose(() {
    db.close();
  });

  return db;
});
