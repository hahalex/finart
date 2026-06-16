// Файл: lib/common/providers/planned_repository_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/planned_repository.dart';
import 'database_provider.dart';

/// Provider репозитория запланированных платежей
final plannedRepositoryProvider = Provider<PlannedRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PlannedRepository(db);
});
