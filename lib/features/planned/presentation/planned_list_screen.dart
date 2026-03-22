import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ Импорт моделей
import '../../../common/models/planned_payment_model.dart';
import '../../../common/models/category_model.dart';
import '../../../common/utils/app_theme.dart';

// ✅ Используем существующий categoriesProvider (из transactions)
import '../../transactions/providers/categories_provider.dart';

import '../providers/planned_ui_providers.dart';
import '../widgets/planned_tile.dart';
import '../widgets/planned_form_dialog.dart';
import '../../../common/providers/planned_repository_provider.dart';

/// Экран "Предстоящие платежи"
class PlannedListScreen extends ConsumerWidget {
  const PlannedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(plannedFilterProvider);
    final paymentsAsync = ref.watch(plannedPaymentsListProvider(filter));

    // ✅ categories — это сразу List<CategoryModel>, не Future!
    final categories = ref.watch(categoriesProvider);

    return SafeArea(
      child: Column(
        children: [
          // Заголовок + фильтры
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Предстоящие платежи',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                ToggleButtons(
                  isSelected: [
                    filter == PlannedFilter.all,
                    filter == PlannedFilter.active,
                    filter == PlannedFilter.completed,
                  ],
                  borderRadius: BorderRadius.circular(12),
                  onPressed: (index) {
                    final newFilter = [
                      PlannedFilter.all,
                      PlannedFilter.active,
                      PlannedFilter.completed,
                    ][index];
                    ref.read(plannedFilterProvider.notifier).state = newFilter;
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Все'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Активные'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Завершённые'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Список платежей
          Expanded(
            child: paymentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Ошибка: $err')),
              data: (payments) {
                if (payments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          filter == PlannedFilter.active
                              ? 'Нет активных платежей'
                              : 'Пока ничего нет',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];

                    // ✅ Теперь categories — это List, firstWhere работает!
                    final category = categories.firstWhere(
                      (c) => c.id == payment.categoryId,
                      orElse: () => CategoryModel(
                        id: 'unknown',
                        name: 'Без категории',
                        icon: Icons.category,
                        isExpense: true,
                      ),
                    );

                    return PlannedTile(
                      payment: payment,
                      categoryName: category.name,
                      onEdit: () =>
                          _showForm(context, ref, payment, categories),
                      onDelete: () => _confirmDelete(context, ref, payment.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(
    BuildContext context,
    WidgetRef ref,
    PlannedPaymentModel? payment,
    List<CategoryModel> categories,
  ) {
    showDialog(
      context: context,
      builder: (_) =>
          PlannedFormDialog(existingPayment: payment, categories: categories),
    ).then((_) {
      ref.invalidate(plannedPaymentsListProvider);
    });
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить платёж?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(plannedRepositoryProvider);
              await repo.deletePlannedPayment(id);
              if (context.mounted) Navigator.pop(context);
              ref.invalidate(plannedPaymentsListProvider);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
