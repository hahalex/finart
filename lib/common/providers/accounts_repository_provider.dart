// Файл: lib/common/providers/accounts_repository_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/accounts_repository.dart';
import 'database_provider.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(ref.watch(databaseProvider));
});
