import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../common/models/planned_payment_model.dart';
import '../../../common/models/category_model.dart';
import '../../../common/utils/app_theme.dart';
import '../../../common/utils/date_grouping.dart';
import '../../../common/widgets/date_header.dart';
import '../../../common/providers/planned_repository_provider.dart';
import '../../../common/providers/categories_provider.dart';
import '../presentation/category_selection_screen.dart';

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

    final categoriesAsync = ref.watch(allCategoriesProvider);
    final categories = categoriesAsync.value ?? [];

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
                    child: Text('Все'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('Активные'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('Завершённые'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildPaymentsList(paymentsAsync, categories, filter),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
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
      return Center(child: Text('Ошибка: ${paymentsAsync.error}'));
    }

    final payments = paymentsAsync.value ?? [];

    if (payments.isEmpty) {
      return const Center(child: Text('Пока ничего нет'));
    }

    final grouped = groupItemsByDate(
      items: payments,
      dateExtractor: (p) => p.startDate,
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: grouped.entries.map((entry) {
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
                  iconCode: Icons.category.codePoint,
                  isExpense: payment.isExpense,
                  color: 0xFF90A4AE,
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

  /// =======================
  /// 🔥 ADD DIALOG
  /// =======================
  void _showAddDialog(BuildContext context) {
    String title = '';
    double amount = 0;
    String? selectedCategoryId;
    bool dialogIsExpense = true;
    DateTime dialogStartDate = DateTime.now();
    String dialogRecurrence = 'monthly';

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final allCats = ref.read(allCategoriesProvider).value ?? [];

            final dialogCategories = allCats
                .where((c) => c.isExpense == dialogIsExpense)
                .toList();

            CategoryModel? selectedCategory = dialogCategories
                .where((c) => c.id == selectedCategoryId)
                .cast<CategoryModel?>()
                .fold<CategoryModel?>(
                  null,
                  (prev, el) => prev ?? el,
                ); // safe firstOrNull

            return AlertDialog(
              title: const Text('Новый платёж'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Кнопки Расход/Доход по центру, меньше и более округлые
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ToggleButtons(
                          isSelected: [dialogIsExpense, !dialogIsExpense],
                          borderRadius: BorderRadius.circular(20),
                          constraints: const BoxConstraints(
                            minWidth: 70,
                            minHeight: 36,
                          ),
                          selectedColor: Colors.white,
                          fillColor: dialogIsExpense
                              ? AppTheme.expenseColor.withOpacity(0.7)
                              : AppTheme.incomeColor.withOpacity(0.7),
                          color: Colors.grey[700],
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: (i) =>
                              setDialogState(() => dialogIsExpense = i == 0),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Расход'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Доход'),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      decoration: const InputDecoration(labelText: 'Название'),
                      onChanged: (v) => title = v,
                    ),

                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Сумма'),
                      onChanged: (v) => amount = double.tryParse(v) ?? 0,
                    ),

                    const SizedBox(height: 12),

                    /// 🔥 ВЫБОР КАТЕГОРИИ
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Категория'),
                      subtitle: selectedCategory == null
                          ? const Text('Не выбрана')
                          : Text(selectedCategory.name),
                      leading: selectedCategory != null
                          ? Icon(selectedCategory.iconData)
                          : const Icon(Icons.category_outlined),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategorySelectionScreen(
                              isExpense: dialogIsExpense,
                            ),
                          ),
                        );

                        if (result != null && result is CategoryModel) {
                          setDialogState(() {
                            selectedCategoryId = result.id;
                          });
                        }
                      },
                    ),

                    ListTile(
                      title: const Text('Дата'),
                      subtitle: Text(
                        '${dialogStartDate.day}.${dialogStartDate.month}.${dialogStartDate.year}',
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dialogStartDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => dialogStartDate = picked);
                        }
                      },
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

                          await repo.insertPlannedPayment(
                            PlannedPaymentModel(
                              id: const Uuid().v4(),
                              title: title.isNotEmpty ? title : 'Без названия',
                              amount: amount,
                              categoryId: selectedCategoryId!,
                              isExpense: dialogIsExpense,
                              startDate: dialogStartDate,
                              recurrence: dialogRecurrence,
                              createdAt: DateTime.now(),
                            ),
                          );

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

  /// ✅ Диалог редактирования: выбор между "Изменить" и "Завершить"
  void _showEditDialog(BuildContext context, PlannedPaymentModel payment) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(payment.title),
        content: SizedBox(
          width: 300, // чуть длиннее
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.center, // выравнивание по центру
            children: [
              Text(
                '💰 ${payment.amount.toStringAsFixed(2)} ₽',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
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
              const SizedBox(height: 16),

              // Кнопки сверху вниз
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditFormDialog(context, payment);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Изменить'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final repo = ref.read(plannedRepositoryProvider);
                  await repo.deactivatePlannedPayment(payment.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.invalidate(plannedPaymentsListProvider);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 18),
                    SizedBox(width: 8),
                    Text('Завершить'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Отмена'),
              ),
            ],
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  /// ✅ Форма редактирования запланированного платежа
  void _showEditFormDialog(BuildContext context, PlannedPaymentModel payment) {
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
            // 🔹 Получаем категории из нового провайдера
            final allCats = ref.read(allCategoriesProvider).value ?? [];
            final dialogCategories = allCats
                .where((c) => c.isExpense == dialogIsExpense)
                .toList();

            return AlertDialog(
              title: const Text('Редактировать платёж'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Кнопки Расход/Доход по центру, компактнее и округлее
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ToggleButtons(
                          isSelected: [dialogIsExpense, !dialogIsExpense],
                          borderRadius: BorderRadius.circular(20),
                          constraints: const BoxConstraints(
                            minWidth: 70,
                            minHeight: 36,
                          ),
                          selectedColor: Colors.white,
                          fillColor: dialogIsExpense
                              ? AppTheme.expenseColor.withOpacity(0.7)
                              : AppTheme.incomeColor.withOpacity(0.7),
                          color: Colors.grey[700],
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          onPressed: (idx) =>
                              setDialogState(() => dialogIsExpense = idx == 0),
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Расход'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Доход'),
                            ),
                          ],
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

                    /// 🔹 Выбор категории через отдельный экран
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Категория'),
                      subtitle: selectedCategoryId.isEmpty
                          ? const Text('Не выбрана')
                          : Text(
                              (ref.read(allCategoriesProvider).value ?? [])
                                  .firstWhere(
                                    (c) => c.id == selectedCategoryId,
                                    orElse: () => CategoryModel(
                                      id: 'unknown',
                                      name: 'Неизвестно',
                                      iconCode: Icons.category.codePoint,
                                      isExpense: dialogIsExpense,
                                      color: 0xFF90A4AE,
                                    ),
                                  )
                                  .name,
                            ),
                      leading: Icon(
                        (ref.read(allCategoriesProvider).value ?? [])
                            .firstWhere(
                              (c) => c.id == selectedCategoryId,
                              orElse: () => CategoryModel(
                                id: 'unknown',
                                name: 'Неизвестно',
                                iconCode: Icons.category.codePoint,
                                isExpense: dialogIsExpense,
                                color: 0xFF90A4AE,
                              ),
                            )
                            .iconData,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategorySelectionScreen(
                              isExpense: dialogIsExpense,
                            ),
                          ),
                        );

                        if (result != null && result is CategoryModel) {
                          setDialogState(() {
                            selectedCategoryId = result.id;
                          });
                        }
                      },
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

                    // Периодичность
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
                            Navigator.pop(dialogContext);
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

  /// Вспомогательный метод для читаемого названия периодичности
  String _getRecurrenceLabel(String recurrence) {
    switch (recurrence) {
      case 'daily':
        return 'Ежедневно';
      case 'weekly':
        return 'Еженедельно';
      case 'monthly':
        return 'Ежемесячно';
      case 'yearly':
        return 'Ежегодно';
      default:
        return 'Разово';
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
