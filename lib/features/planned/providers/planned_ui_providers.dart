// Файл: lib/features/planned/providers/planned_ui_providers.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/models/planned_payment_model.dart';
import '../../../../common/providers/planned_repository_provider.dart';

/// Фильтр для списка запланированных платежей
enum PlannedFilter { all, active, completed }

/// Провайдер текущего фильтра
final plannedFilterProvider = StateProvider<PlannedFilter>((ref) {
  return PlannedFilter.active;
});

/// Провайдер списка платежей с применением фильтра
final plannedPaymentsListProvider =
    FutureProvider.family<List<PlannedPaymentModel>, PlannedFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.watch(plannedRepositoryProvider);
      final all = await repo.getAllPlannedPayments();

      switch (filter) {
        case PlannedFilter.active:
          return all.where((p) => p.isActive).toList();
        case PlannedFilter.completed:
          return all.where((p) => !p.isActive).toList();
        case PlannedFilter.all:
          return all;
      }
    });

/// Провайдер для формы: выбранный платёж для редактирования (null = создание нового)
final selectedPlannedPaymentProvider = StateProvider<PlannedPaymentModel?>(
  (ref) => null,
);

/// Провайдер валидации формы
final plannedFormValidProvider = Provider.family<bool, PlannedPaymentFormState>(
  (ref, form) {
    return form.title.trim().isNotEmpty &&
        form.amount > 0 &&
        form.categoryId.isNotEmpty;
  },
);

/// Состояние формы (для валидации)
class PlannedPaymentFormState {
  final String title;
  final double amount;
  final String categoryId;
  final String recurrence;
  final DateTime startDate;
  final bool isExpense;

  PlannedPaymentFormState({
    this.title = '',
    this.amount = 0,
    this.categoryId = '',
    this.recurrence = 'monthly',
    required this.startDate,
    this.isExpense = true,
  });
}

/// Провайдер состояния формы
final plannedFormStateProvider =
    StateNotifierProvider<FormNotifier, PlannedPaymentFormState>((ref) {
      return FormNotifier();
    });

class FormNotifier extends StateNotifier<PlannedPaymentFormState> {
  FormNotifier() : super(PlannedPaymentFormState(startDate: DateTime.now()));

  void updateTitle(String title) => state = PlannedPaymentFormState(
    title: title,
    amount: state.amount,
    categoryId: state.categoryId,
    recurrence: state.recurrence,
    startDate: state.startDate,
    isExpense: state.isExpense,
  );

  void updateAmount(double amount) => state = PlannedPaymentFormState(
    title: state.title,
    amount: amount,
    categoryId: state.categoryId,
    recurrence: state.recurrence,
    startDate: state.startDate,
    isExpense: state.isExpense,
  );

  void updateCategory(String categoryId) => state = PlannedPaymentFormState(
    title: state.title,
    amount: state.amount,
    categoryId: categoryId,
    recurrence: state.recurrence,
    startDate: state.startDate,
    isExpense: state.isExpense,
  );

  void updateRecurrence(String recurrence) => state = PlannedPaymentFormState(
    title: state.title,
    amount: state.amount,
    categoryId: state.categoryId,
    recurrence: recurrence,
    startDate: state.startDate,
    isExpense: state.isExpense,
  );

  void updateDate(DateTime date) => state = PlannedPaymentFormState(
    title: state.title,
    amount: state.amount,
    categoryId: state.categoryId,
    recurrence: state.recurrence,
    startDate: date,
    isExpense: state.isExpense,
  );

  void updateType(bool isExpense) => state = PlannedPaymentFormState(
    title: state.title,
    amount: state.amount,
    categoryId: state.categoryId,
    recurrence: state.recurrence,
    startDate: state.startDate,
    isExpense: isExpense,
  );

  void reset() => state = PlannedPaymentFormState(startDate: DateTime.now());

  void loadFromModel(PlannedPaymentModel model) {
    state = PlannedPaymentFormState(
      title: model.title,
      amount: model.amount,
      categoryId: model.categoryId,
      recurrence: model.recurrence,
      startDate: model.startDate,
      isExpense: model.isExpense,
    );
  }
}
