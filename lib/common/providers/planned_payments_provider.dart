// Файл: lib/common/providers/planned_payments_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/planned_payment_model.dart';
import 'planned_repository_provider.dart';

/// Провайдер списка запланированных платежей для UI
/// Возвращает AsyncValue<List<PlannedPaymentModel>> — удобно для loading/error/state
final plannedPaymentsProvider = FutureProvider<List<PlannedPaymentModel>>((
  ref,
) async {
  final repository = ref.watch(plannedRepositoryProvider);
  return repository.getAllPlannedPayments();
});

/// Провайдер только активных платежей
final activePlannedPaymentsProvider = FutureProvider<List<PlannedPaymentModel>>(
  (ref) async {
    final repository = ref.watch(plannedRepositoryProvider);
    final all = await repository.getAllPlannedPayments();
    return all.where((p) => p.isActive).toList();
  },
);
