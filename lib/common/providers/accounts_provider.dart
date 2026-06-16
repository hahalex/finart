// Файл: lib/common/providers/accounts_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_model.dart';
import '../models/account_operation_model.dart';
import 'accounts_repository_provider.dart';

final accountsProvider = FutureProvider.autoDispose<List<AccountModel>>((
  ref,
) async {
  final repository = ref.watch(accountsRepositoryProvider);
  await repository.ensureMainAccount();
  return repository.getAllAccounts();
});

final defaultAccountProvider = FutureProvider.autoDispose<AccountModel>((
  ref,
) async {
  final repository = ref.watch(accountsRepositoryProvider);
  return repository.ensureMainAccount();
});

final accountOperationsProvider = FutureProvider.autoDispose
    .family<List<AccountOperationModel>, String>((ref, accountId) async {
      return ref.watch(accountsRepositoryProvider).getOperations(accountId);
    });
