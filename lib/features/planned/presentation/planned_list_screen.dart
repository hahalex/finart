// Файл: lib/features/planned/presentation/planned_list_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

import '../../../common/localization/app_strings.dart';
import '../../../common/models/category_model.dart';
import '../../../common/models/planned_payment_model.dart';
import '../../../common/providers/categories_provider.dart';
import '../../../common/providers/notification_service_provider.dart';
import '../../../common/providers/notification_settings_provider.dart';
import '../../../common/providers/planned_repository_provider.dart';
import '../../../common/utils/app_theme.dart';
import '../../../common/utils/date_grouping.dart';
import '../../../common/widgets/date_header.dart';
import '../providers/planned_ui_providers.dart';
import '../widgets/planned_tile.dart';
import 'category_selection_screen.dart';

enum _PlannedKindFilter { all, expense, income }

class PlannedListScreen extends ConsumerStatefulWidget {
  const PlannedListScreen({
    super.key,
    this.initialAccountId,
    this.openCreateOnStart = false,
  });

  final String? initialAccountId;
  final bool openCreateOnStart;

  @override
  ConsumerState<PlannedListScreen> createState() => _PlannedListScreenState();
}

class _PlannedListScreenState extends ConsumerState<PlannedListScreen> {
  final _searchController = TextEditingController();
  _PlannedKindFilter _kindFilter = _PlannedKindFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.openCreateOnStart) {
      // Если экран открыт из модуля счетов, сразу показываем форму создания.
      // forcedAccountId ниже превратит платеж в перевод между счетами.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPaymentFormDialog(
            context,
            forcedAccountId: widget.initialAccountId,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final filter = ref.watch(plannedFilterProvider);
    final paymentsAsync = ref.watch(plannedPaymentsListProvider(filter));
    final categories = ref.watch(allCategoriesProvider).value ?? [];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(strings.upcomingPayments), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              // Верхнее меню Все/Активные/Завершенные управляет основным
              // фильтром списка через Riverpod.
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: _PlannedFilterControl(
                filter: filter,
                isRu: strings.isRu,
                onChanged: (value) {
                  ref.read(plannedFilterProvider.notifier).state = value;
                },
              ),
            ),
            Padding(
              // Второй ряд фильтров: текстовый поиск и расход/доход.
              // Он работает поверх основного фильтра выше.
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _PlannedSearchPanel(
                controller: _searchController,
                kindFilter: _kindFilter,
                isRu: strings.isRu,
                onQueryChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
                onKindChanged: (value) {
                  setState(() => _kindFilter = value);
                },
              ),
            ),
            Expanded(
              child: _buildPaymentsList(
                context,
                paymentsAsync,
                categories,
                strings,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Кнопка "+" создает обычный предстоящий платеж.
        // Привязанные к счету платежи создаются из экрана "Счета".
        onPressed: () => _showPaymentFormDialog(context),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaymentsList(
    BuildContext context,
    AsyncValue<List<PlannedPaymentModel>> paymentsAsync,
    List<CategoryModel> categories,
    AppStrings strings,
  ) {
    if (paymentsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (paymentsAsync.hasError) {
      return Center(child: Text('Error: ${paymentsAsync.error}'));
    }

    final payments = paymentsAsync.value ?? [];
    final filteredPayments = payments.where((payment) {
      // Сначала отсекаем платежи по типу расход/доход, затем применяем поиск.
      if (_kindFilter == _PlannedKindFilter.expense && !payment.isExpense) {
        return false;
      }
      if (_kindFilter == _PlannedKindFilter.income && payment.isExpense) {
        return false;
      }

      if (_searchQuery.isEmpty) return true;
      final categoryName = categories
          .where((category) => category.id == payment.categoryId)
          .map((category) => category.name)
          .firstOrNull;
      final haystack = '${payment.title} ${categoryName ?? ''}'.toLowerCase();
      return haystack.contains(_searchQuery);
    }).toList();

    if (filteredPayments.isEmpty) {
      return Center(
        child: Text(strings.isRu ? 'Пока ничего нет' : 'Nothing here yet'),
      );
    }

    final grouped = groupItemsByDate(
      // Группируем платежи по ближайшей дате исполнения, а не по дате создания.
      items: filteredPayments,
      dateExtractor: (payment) =>
          payment.getNextOccurrenceOnOrAfter(DateTime.now()),
      languageCode: strings.isRu ? 'ru' : 'en',
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
                (category) => category.id == payment.categoryId,
                orElse: () => CategoryModel(
                  id: 'unknown',
                  name: strings.isRu ? 'Неизвестно' : 'Unknown',
                  iconCode: Icons.category.codePoint,
                  isExpense: payment.isExpense,
                  color: 0xFF90A4AE,
                ),
              );

              return PlannedTile(
                payment: payment,
                categoryName: category.name,
                onEdit: () => _showEditOptionsDialog(context, payment),
                onDelete: () => _confirmDelete(payment.id),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  void _showEditOptionsDialog(
    BuildContext context,
    PlannedPaymentModel payment,
  ) {
    final strings = AppStrings.of(context);

    showDialog(
      // Диалог ниже используется и для создания, и для редактирования.
      // StatefulBuilder держит локальные значения формы без отдельного StatefulWidget.
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(payment.title, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              payment.amount.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              strings.isRu
                  ? 'Что вы хотите сделать?'
                  : 'What would you like to do?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              // Открывает ту же форму, но уже в режиме редактирования.
              onPressed: () {
                Navigator.pop(dialogContext);
                _showPaymentFormDialog(context, payment: payment);
              },
              child: Text(strings.isRu ? 'Изменить' : 'Edit'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              // Завершает платеж без удаления: он остается в разделе завершенных.
              onPressed: () async {
                final repo = ref.read(plannedRepositoryProvider);
                await repo.deactivatePlannedPayment(payment.id);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                _invalidatePlannedLists();
                await _syncNotifications();
              },
              child: Text(strings.isRu ? 'Завершить' : 'Complete'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              // Удаление вынесено в отдельное подтверждение, чтобы не потерять
              // регулярный платеж случайным нажатием.
              onPressed: () {
                Navigator.pop(dialogContext);
                _confirmDelete(payment.id);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.colorsOf(context).expense,
              ),
              child: Text(strings.isRu ? 'Удалить' : 'Delete'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentFormDialog(
    BuildContext context, {
    PlannedPaymentModel? payment,
    String? forcedAccountId,
  }) {
    final strings = AppStrings.of(context);
    final titleController = TextEditingController(text: payment?.title ?? '');
    final amountController = TextEditingController(
      text: payment == null ? '' : payment.amount.toString(),
    );
    String? selectedCategoryId = payment?.categoryId;
    String? selectedAccountId = forcedAccountId ?? payment?.accountId;
    final isTransfer =
        forcedAccountId != null || payment?.paymentType.isTransfer == true;
    bool dialogIsExpense = isTransfer ? true : (payment?.isExpense ?? true);
    DateTime dialogStartDate = payment?.startDate ?? DateTime.now();
    String dialogRecurrence = payment?.recurrence ?? 'monthly';

    showDialog(
      // Финальное подтверждение удаления предстоящего платежа.
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final allCategories = ref.read(allCategoriesProvider).value ?? [];
            if (isTransfer && selectedCategoryId == null) {
              selectedCategoryId = allCategories
                  .firstWhereOrNull(
                    (category) =>
                        category.isExpense == dialogIsExpense &&
                        !category.isArchived,
                  )
                  ?.id;
            }
            final selectedCategory = allCategories
                .cast<CategoryModel?>()
                .firstWhere(
                  (category) => category?.id == selectedCategoryId,
                  orElse: () => null,
                );

            return AlertDialog(
              title: Text(
                payment != null
                    ? (strings.isRu ? 'Редактировать платёж' : 'Edit payment')
                    : (strings.isRu ? 'Новый платёж' : 'New payment'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isTransfer)
                      _TransferNotice(isRu: strings.isRu)
                    else
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          // Переключает набор категорий между расходами и доходами.
                          // При смене типа выбранная категория сбрасывается.
                          segments: [
                            ButtonSegment(
                              value: true,
                              label: Text(strings.isRu ? 'Расход' : 'Expense'),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text(strings.isRu ? 'Доход' : 'Income'),
                            ),
                          ],
                          selected: {dialogIsExpense},
                          onSelectionChanged: (value) {
                            setDialogState(() {
                              dialogIsExpense = value.first;
                              selectedCategoryId = null;
                            });
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: strings.isRu ? 'Название' : 'Title',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: strings.isRu ? 'Сумма' : 'Amount',
                        hintText: '0',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      // Строка выбора категории открывает экран с основными
                      // категориями и подкатегориями.
                      contentPadding: EdgeInsets.zero,
                      title: Text(strings.isRu ? 'Категория' : 'Category'),
                      subtitle: Text(
                        selectedCategory?.name ??
                            (strings.isRu ? 'Не выбрана' : 'Not selected'),
                      ),
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
                              selectedCategoryId: selectedCategoryId,
                            ),
                          ),
                        );

                        if (result != null && result is CategoryModel) {
                          setDialogState(() {
                            selectedCategoryId = result.id;
                            dialogIsExpense = result.isExpense;
                          });
                        }
                      },
                    ),
                    ListTile(
                      // Дата старта платежа выбирается системным календарем.
                      contentPadding: EdgeInsets.zero,
                      title: Text(strings.isRu ? 'Дата' : 'Date'),
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
                        if (picked != null) {
                          setDialogState(() => dialogStartDate = picked);
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      // Периодичность хранится строковым правилом recurrence.
                      initialValue: dialogRecurrence,
                      decoration: InputDecoration(
                        labelText: strings.isRu
                            ? 'Периодичность'
                            : 'Recurrence',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text(strings.isRu ? 'Ежедневно' : 'Daily'),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text(strings.isRu ? 'Еженедельно' : 'Weekly'),
                        ),
                        DropdownMenuItem(
                          value: 'every:weeks:2',
                          child: Text(
                            strings.isRu ? 'Раз в 2 недели' : 'Every 2 weeks',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text(strings.isRu ? 'Ежемесячно' : 'Monthly'),
                        ),
                        DropdownMenuItem(
                          value: 'every:months:3',
                          child: Text(
                            strings.isRu ? 'Раз в 3 месяца' : 'Every 3 months',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'weekdays:1,2,3,4,5',
                          child: Text(strings.isRu ? 'По будням' : 'Weekdays'),
                        ),
                        DropdownMenuItem(
                          value: 'yearly',
                          child: Text(strings.isRu ? 'Ежегодно' : 'Yearly'),
                        ),
                        DropdownMenuItem(
                          value: 'none',
                          child: Text(strings.isRu ? 'Разово' : 'One-time'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => dialogRecurrence = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  // "Сохранить" валидирует форму, пишет запись в БД,
                  // закрывает диалог и пересчитывает уведомления.
                  onPressed: () async {
                    final effectiveCategoryId =
                        selectedCategoryId ??
                        allCategories
                            .firstWhereOrNull(
                              (category) =>
                                  category.isExpense == dialogIsExpense &&
                                  !category.isArchived,
                            )
                            ?.id;
                    if (effectiveCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            strings.isRu
                                ? 'Выберите категорию'
                                : 'Choose a category',
                          ),
                        ),
                      );
                      return;
                    }
                    if (isTransfer && selectedAccountId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            strings.isRu
                                ? 'Счет не выбран'
                                : 'Account is not selected',
                          ),
                        ),
                      );
                      return;
                    }

                    final amount =
                        double.tryParse(
                          amountController.text.trim().replaceAll(',', '.'),
                        ) ??
                        0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            strings.isRu
                                ? 'Введите сумму больше нуля'
                                : 'Enter an amount greater than zero',
                          ),
                        ),
                      );
                      return;
                    }

                    final repo = ref.read(plannedRepositoryProvider);
                    final title = titleController.text.trim();

                    if (payment != null) {
                      await repo.updatePlannedPayment(
                        payment.copyWith(
                          title: title.isEmpty ? payment.title : title,
                          amount: amount,
                          categoryId: effectiveCategoryId,
                          accountId: isTransfer ? selectedAccountId : null,
                          paymentType: isTransfer
                              ? PlannedPaymentType.transfer
                              : PlannedPaymentType.standard,
                          isExpense: dialogIsExpense,
                          startDate: dialogStartDate,
                          recurrence: dialogRecurrence,
                        ),
                      );
                    } else {
                      await repo.insertPlannedPayment(
                        PlannedPaymentModel(
                          id: const Uuid().v4(),
                          title: title.isEmpty
                              ? (strings.isRu ? 'Без названия' : 'Untitled')
                              : title,
                          amount: amount,
                          categoryId: effectiveCategoryId,
                          accountId: isTransfer ? selectedAccountId : null,
                          paymentType: isTransfer
                              ? PlannedPaymentType.transfer
                              : PlannedPaymentType.standard,
                          isExpense: dialogIsExpense,
                          startDate: dialogStartDate,
                          recurrence: dialogRecurrence,
                          createdAt: DateTime.now(),
                        ),
                      );
                    }

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    _invalidatePlannedLists();
                    await _syncNotifications();
                  },
                  child: Text(strings.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String id) {
    final strings = AppStrings.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.isRu ? 'Удалить?' : 'Delete?'),
        content: Text(
          strings.isRu
              ? 'Это действие нельзя отменить'
              : 'This action cannot be undone',
        ),
        backgroundColor: AppTheme.colorsOf(context).background,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(plannedRepositoryProvider);
              await repo.deletePlannedPayment(id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              _invalidatePlannedLists();
              await _syncNotifications();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.colorsOf(context).expense,
            ),
            child: Text(strings.isRu ? 'Удалить' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _invalidatePlannedLists() {
    for (final filter in PlannedFilter.values) {
      ref.invalidate(plannedPaymentsListProvider(filter));
    }
  }

  Future<void> _syncNotifications() async {
    final repository = ref.read(plannedRepositoryProvider);
    final settings = ref.read(notificationSettingsProvider);
    final plannedPayments = await repository.getAllPlannedPayments();

    await ref
        .read(notificationServiceProvider)
        .syncAll(
          settings: settings,
          plannedPayments: plannedPayments
              .where((payment) => payment.isActive)
              .toList(),
        );
  }
}

class _PlannedFilterControl extends StatelessWidget {
  const _PlannedFilterControl({
    required this.filter,
    required this.isRu,
    required this.onChanged,
  });

  final PlannedFilter filter;
  final bool isRu;
  final ValueChanged<PlannedFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final items = [
      (PlannedFilter.all, isRu ? 'Все' : 'All'),
      (PlannedFilter.active, isRu ? 'Активные' : 'Active'),
      (PlannedFilter.completed, isRu ? 'Заверш.' : 'Done'),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        // Общая рамка вокруг трех сегментов. Высота и FittedBox ниже защищают
        // от layout overflow на узких экранах.
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            for (final item in items)
              Expanded(
                child: InkWell(
                  onTap: () => onChanged(item.$1),
                  child: ColoredBox(
                    color: filter == item.$1
                        ? colors.primary
                        : Colors.transparent,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            item.$2,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: filter == item.$1
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlannedSearchPanel extends StatelessWidget {
  const _PlannedSearchPanel({
    required this.controller,
    required this.kindFilter,
    required this.isRu,
    required this.onQueryChanged,
    required this.onKindChanged,
  });

  final TextEditingController controller;
  final _PlannedKindFilter kindFilter;
  final bool isRu;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_PlannedKindFilter> onKindChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final items = [
      (_PlannedKindFilter.all, isRu ? 'Все' : 'All'),
      (_PlannedKindFilter.expense, isRu ? 'Расход' : 'Expense'),
      (_PlannedKindFilter.income, isRu ? 'Доход' : 'Income'),
    ];

    return Column(
      children: [
        TextField(
          // Поиск срабатывает сразу при вводе и ищет по названию/категории.
          controller: controller,
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: isRu
                ? 'Поиск по названию или категории'
                : 'Search by title or category',
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          // Легкий сегментированный фильтр расход/доход: выбранный пункт
          // закрашен primary, остальные прозрачные.
          height: 34,
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              for (final item in items)
                Expanded(
                  child: InkWell(
                    onTap: () => onKindChanged(item.$1),
                    child: ColoredBox(
                      color: kindFilter == item.$1
                          ? colors.primary
                          : Colors.transparent,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.$2,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: kindFilter == item.$1
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransferNotice extends StatelessWidget {
  const _TransferNotice({required this.isRu});

  final bool isRu;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Container(
      // Плашка появляется в форме регулярного платежа счета и объясняет,
      // почему нет обычного выбора расход/доход.
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.accounts.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.accounts.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz_rounded, color: colors.accounts),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isRu
                  ? 'Перевод между счетами: списание с основного счета и пополнение выбранного счета.'
                  : 'Account transfer: deducts from main account and tops up the selected account.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
