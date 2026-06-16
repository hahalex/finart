// Файл: lib/common/providers/planned_payment_service_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/planned_payment_service.dart';
import 'accounts_repository_provider.dart';
import 'planned_repository_provider.dart';
import 'transactions_repository_provider.dart';
import 'database_provider.dart';

/// Провайдер сервиса обработки запланированных платежей
final plannedPaymentServiceProvider = Provider<PlannedPaymentService>((ref) {
  return PlannedPaymentService(
    plannedRepository: ref.watch(plannedRepositoryProvider),
    transactionsRepository: ref.watch(transactionsRepositoryProvider),
    accountsRepository: ref.watch(accountsRepositoryProvider),
    database: ref.watch(databaseProvider),
  );
});
