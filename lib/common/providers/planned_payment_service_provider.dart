import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/planned_payment_service.dart';
import 'planned_repository_provider.dart';
import 'transactions_repository_provider.dart';
import 'database_provider.dart';

/// Провайдер сервиса обработки запланированных платежей
final plannedPaymentServiceProvider = Provider<PlannedPaymentService>((ref) {
  return PlannedPaymentService(
    plannedRepository: ref.watch(plannedRepositoryProvider),
    transactionsRepository: ref.watch(transactionsRepositoryProvider),
    database: ref.watch(databaseProvider),
  );
});
