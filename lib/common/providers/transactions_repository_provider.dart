// Файл: lib/common/providers/transactions_repository_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/transactions_repository.dart';
import 'database_provider.dart';

/// Provider репозитория операций
final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionsRepository(db);
});
