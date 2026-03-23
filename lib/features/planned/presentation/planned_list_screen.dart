import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../common/models/planned_payment_model.dart';
import '../../../common/models/category_model.dart';
import '../../../common/utils/app_theme.dart';
import '../../../common/utils/date_grouping.dart';
import '../../../common/widgets/date_header.dart';
import '../../../common/providers/planned_repository_provider.dart';

import '../../transactions/providers/categories_provider.dart';
import '../providers/planned_ui_providers.dart';
import '../widgets/planned_tile.dart';

/// Экран "Предстоящие платежи"
class PlannedListScreen extends ConsumerStatefulWidget {
  const PlannedListScreen({super.key});

  @override
  ConsumerState<PlannedListScreen> createState() => _PlannedListScreenState();
}

class _PlannedListScreenState extends ConsumerState<PlannedListScreen> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(plannedFilterProvider);
    final paymentsAsync = ref.watch(plannedPaymentsListProvider(filter));
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Предстоящие платежи'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Фильтры
            Padding(
              padding: const EdgeInsets.all(16),
              child: ToggleButtons(
                isSelected: [
                  filter == PlannedFilter.all,
                  filter == PlannedFilter.active,
                  filter == PlannedFilter.completed,
                ],
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                fillColor: AppTheme.primaryColor,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withOpacity(0.7),
                borderColor: AppTheme.primaryColor.withOpacity(0.3),
                selectedBorderColor: AppTheme.primaryColor,
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
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('Все', style: TextStyle(fontSize: 14)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('Активные', style: TextStyle(fontSize: 14)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('Завершённые', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),

            // Список
            Expanded(
              child: _buildPaymentsList(paymentsAsync, categories, filter),
            ),
          ],
        ),
      ),

      // FAB для добавления
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Добавить платёж',
      ),
    );
  }

  Widget _buildPaymentsList(
    AsyncValue<List<PlannedPaymentModel>> paymentsAsync,
    List<CategoryModel> categories,
    PlannedFilter filter,
  ) {
    if (paymentsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paymentsAsync.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(
              'Ошибка: ${paymentsAsync.error}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: () => ref.refresh(plannedPaymentsListProvider(filter)),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (paymentsAsync.hasValue) {
      final payments = paymentsAsync.value!;

      if (payments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                filter == PlannedFilter.active
                    ? Icons.event_busy
                    : Icons.inbox_outlined,
                size: 72,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              Text(
                filter == PlannedFilter.active
                    ? 'Нет активных платежей'
                    : 'Пока ничего нет',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Нажмите + чтобы добавить',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ],
          ),
        );
      }

      final groupedPayments = groupItemsByDate(
        items: payments,
        dateExtractor: (p) => p.startDate,
      );

      return ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: groupedPayments.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateHeader(label: entry.key),
              ...entry.value.map((payment) {
                final category = categories.firstWhere(
                  (c) => c.id == payment.categoryId,
                  orElse: () => CategoryModel(
                    id: 'unknown',
                    name: 'Неизвестно',
                    iconCode: Icons
                        .category_outlined
                        .codePoint, // ✅ codePoint, не IconData
                    isExpense: true,
                    color: 0xFF90A4AE, // ✅ обязательно указывать цвет
                  ),
                );
                return PlannedTile(
                  payment: payment,
                  categoryName: category.name,
                  onEdit: () => _showEditDialog(context, payment),
                  onDelete: () => _confirmDelete(payment.id),
                );
              }),
            ],
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  /// ✅ Диалог добавления нового платежа — упрощённый, без сложных провайдеров
  void _showAddDialog(BuildContext context) {
    // Локальные переменные для формы
    String title = '';
    double amount = 0;
    String? selectedCategoryId;
    bool dialogIsExpense = true;
    DateTime dialogStartDate = DateTime.now();
    String dialogRecurrence = 'monthly';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogCategories = ref
                .read(categoriesProvider)
                .where((c) => c.isExpense == dialogIsExpense)
                .toList();

            return AlertDialog(
              title: const Text('Новый платёж'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Тип: расход/доход
                    ToggleButtons(
                      isSelected: [dialogIsExpense, !dialogIsExpense],
                      borderRadius: BorderRadius.circular(10),
                      selectedColor: Colors.white,
                      fillColor: dialogIsExpense
                          ? AppTheme.expenseColor
                          : AppTheme.incomeColor,
                      onPressed: (idx) =>
                          setDialogState(() => dialogIsExpense = idx == 0),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Расход'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Доход'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Название
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        hintText: 'Подписка Яндекс.Плюс',
                      ),
                      onChanged: (v) => title = v,
                    ),
                    const SizedBox(height: 8),

                    // Сумма
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Сумма',
                        hintText: '0 ₽',
                      ),
                      onChanged: (v) => amount = double.tryParse(v) ?? 0,
                    ),
                    const SizedBox(height: 12),

                    // Категория
                    Text(
                      'Категория',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: dialogCategories.map((cat) {
                          final isSelected = selectedCategoryId == cat.id;
                          return GestureDetector(
                            onTap: () => setDialogState(
                              () => selectedCategoryId = cat.id,
                            ),
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: AppTheme.primaryColor)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    cat.iconData,
                                    size: 24,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Дата
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Дата'),
                      subtitle: Text(
                        '${dialogStartDate.day}.${dialogStartDate.month}.${dialogStartDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dialogStartDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null)
                          setDialogState(() => dialogStartDate = picked);
                      },
                    ),

                    // Периодичность
                    DropdownButtonFormField<String>(
                      value: dialogRecurrence,
                      decoration: const InputDecoration(
                        labelText: 'Периодичность',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'none',
                          child: Text('📅 Один раз'),
                        ),
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text('🔄 Ежедневно'),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('📆 Еженедельно'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('🗓️ Ежемесячно'),
                        ),
                        DropdownMenuItem(
                          value: 'yearly',
                          child: Text('🎂 Ежегодно'),
                        ),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => dialogRecurrence = v!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: selectedCategoryId == null || amount <= 0
                      ? null
                      : () async {
                          final repo = ref.read(plannedRepositoryProvider);
                          final newPayment = PlannedPaymentModel(
                            id: const Uuid().v4(),
                            title: title.isNotEmpty ? title : 'Без названия',
                            amount: amount,
                            categoryId: selectedCategoryId!,
                            isExpense: dialogIsExpense,
                            startDate: dialogStartDate,
                            recurrence: dialogRecurrence,
                            createdAt: DateTime.now(),
                          );
                          await repo.insertPlannedPayment(newPayment);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ref.invalidate(plannedPaymentsListProvider);
                          }
                        },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Диалог редактирования (можно сделать аналогично)
  /// ✅ Диалог редактирования: выбор между "Изменить" и "Завершить"
  void _showEditDialog(BuildContext context, PlannedPaymentModel payment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(payment.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💰 ${payment.amount.toStringAsFixed(2)} ₽',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('📁 Категория: ${payment.categoryId}'),
            Text(
              '📅 Дата: ${payment.startDate.day}.${payment.startDate.month}.${payment.startDate.year}',
            ),
            Text(
              '🔄 Периодичность: ${_getRecurrenceLabel(payment.recurrence)}',
            ),
            const SizedBox(height: 16),
            Text(
              'Что хотите сделать?',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          // Кнопка "Отмена"
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          // Кнопка "✏️ Изменить"
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрываем первый диалог
              _showEditFormDialog(
                context,
                payment,
              ); // Открываем форму редактирования
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 4),
                Text('Изменить'),
              ],
            ),
          ),
          // Кнопка "✓ Завершить"
          TextButton(
            onPressed: () async {
              final repo = ref.read(plannedRepositoryProvider);
              await repo.deactivatePlannedPayment(payment.id);
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(plannedPaymentsListProvider);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 18),
                SizedBox(width: 4),
                Text('Завершить'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Форма редактирования запланированного платежа
  void _showEditFormDialog(BuildContext context, PlannedPaymentModel payment) {
    // Локальные переменные с предзаполненными значениями
    String title = payment.title;
    double amount = payment.amount;
    String selectedCategoryId = payment.categoryId;
    bool dialogIsExpense = payment.isExpense;
    DateTime dialogStartDate = payment.startDate;
    String dialogRecurrence = payment.recurrence;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogCategories = ref
                .read(categoriesProvider)
                .where((c) => c.isExpense == dialogIsExpense)
                .toList();

            return AlertDialog(
              title: const Text('Редактировать платёж'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Тип: расход/доход
                    ToggleButtons(
                      isSelected: [dialogIsExpense, !dialogIsExpense],
                      borderRadius: BorderRadius.circular(10),
                      selectedColor: Colors.white,
                      fillColor: dialogIsExpense
                          ? AppTheme.expenseColor
                          : AppTheme.incomeColor,
                      onPressed: (idx) =>
                          setDialogState(() => dialogIsExpense = idx == 0),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Расход'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Доход'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Название
                    TextField(
                      controller: TextEditingController(text: title),
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        hintText: 'Подписка Яндекс.Плюс',
                      ),
                      onChanged: (v) => title = v,
                    ),
                    const SizedBox(height: 8),

                    // Сумма
                    TextField(
                      controller: TextEditingController(
                        text: amount.toString(),
                      ),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Сумма',
                        hintText: '0 ₽',
                      ),
                      onChanged: (v) => amount = double.tryParse(v) ?? 0,
                    ),
                    const SizedBox(height: 12),

                    // Категория
                    Text(
                      'Категория',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: dialogCategories.map((cat) {
                          final isSelected = selectedCategoryId == cat.id;
                          return GestureDetector(
                            onTap: () => setDialogState(
                              () => selectedCategoryId = cat.id,
                            ),
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(color: AppTheme.primaryColor)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    cat.iconData,
                                    size: 24,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Дата
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Дата'),
                      subtitle: Text(
                        '${dialogStartDate.day}.${dialogStartDate.month}.${dialogStartDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dialogStartDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null)
                          setDialogState(() => dialogStartDate = picked);
                      },
                    ),

                    // Периодичность (с "Ежедневно")
                    DropdownButtonFormField<String>(
                      value: dialogRecurrence,
                      decoration: const InputDecoration(
                        labelText: 'Периодичность',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text('🔄 Ежедневно'),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text('📆 Еженедельно'),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text('🗓️ Ежемесячно'),
                        ),
                        DropdownMenuItem(
                          value: 'yearly',
                          child: Text('🎂 Ежегодно'),
                        ),
                        DropdownMenuItem(
                          value: 'none',
                          child: Text('📅 Один раз'),
                        ),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => dialogRecurrence = v!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: selectedCategoryId.isEmpty || amount <= 0
                      ? null
                      : () async {
                          final repo = ref.read(plannedRepositoryProvider);
                          final updated = payment.copyWith(
                            title: title.isNotEmpty ? title : payment.title,
                            amount: amount,
                            categoryId: selectedCategoryId,
                            isExpense: dialogIsExpense,
                            startDate: dialogStartDate,
                            recurrence: dialogRecurrence,
                          );
                          await repo.updatePlannedPayment(updated);
                          if (context.mounted) {
                            Navigator.pop(dialogContext); // Закрываем форму
                            ref.invalidate(
                              plannedPaymentsListProvider,
                            ); // Обновляем список
                          }
                        },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Вспомогательный метод для читаемого названия периодичности
  String _getRecurrenceLabel(String recurrence) {
    switch (recurrence) {
      case 'daily':
        return 'ежедневно';
      case 'weekly':
        return 'еженедельно';
      case 'monthly':
        return 'ежемесячно';
      case 'yearly':
        return 'ежегодно';
      default:
        return 'разово';
    }
  }

  /// Подтверждение удаления
  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить?'),
        content: const Text('Это действие нельзя отменить'),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(plannedRepositoryProvider);
              await repo.deletePlannedPayment(id);
              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(plannedPaymentsListProvider);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.expenseColor),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
