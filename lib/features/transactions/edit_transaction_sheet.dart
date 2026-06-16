// Файл: lib/features/transactions/edit_transaction_sheet.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/localization/app_strings.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/providers/accounts_provider.dart';
import '../../common/models/account_model.dart';
import '../../common/models/category_model.dart';
import '../../common/widgets/category_picker.dart';
import '../../common/models/transaction_model.dart';
import 'providers/transactions_notifier.dart';

class EditTransactionSheet extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const EditTransactionSheet({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<EditTransactionSheet> {
  late TextEditingController amountController;
  late TextEditingController descriptionController;

  CategoryModel? selectedCategory;
  AccountModel? selectedAccount;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.transaction.createdAt;

    amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );

    descriptionController = TextEditingController(
      text: widget.transaction.description ?? '',
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите корректную сумму')));
      return;
    }

    final updated = TransactionModel(
      id: widget.transaction.id,
      amount: amount,
      categoryId: selectedCategory?.id ?? widget.transaction.categoryId,
      accountId: selectedAccount?.id ?? widget.transaction.accountId,
      createdAt: selectedDate,
      isExpense: widget.transaction.isExpense,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    );

    await ref.read(transactionsProvider.notifier).editTransaction(updated);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

    return Padding(
      // Нижний лист редактирования поднимается над клавиатурой за счет
      // viewInsets.bottom и остается прокручиваемым на маленьких экранах.
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Редактировать транзакцию',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TextField(
              // Сумма обязательна; тип расход/доход не меняется при редактировании.
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Сумма',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            accountsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
              data: (accounts) {
                selectedAccount ??= accounts.firstWhere(
                  (account) => account.id == widget.transaction.accountId,
                  orElse: () => accounts.firstWhere(
                    (account) => account.isMain,
                    orElse: () => accounts.first,
                  ),
                );
                return DropdownButtonFormField<String>(
                  // Смена счета переносит операцию в историю выбранного счета
                  // или обратно в основной список, если выбран main.
                  initialValue: selectedAccount?.id,
                  decoration: const InputDecoration(
                    labelText: 'Счет',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final account in accounts)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedAccount = accounts.firstWhere(
                        (account) => account.id == value,
                      );
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            _DatePickerField(
              label: strings.isRu ? 'Дата' : 'Date',
              value: _formatDate(context, selectedDate),
              onTap: _pickDate,
            ),

            const SizedBox(height: 16),

            SizedBox(
              // Компактная сетка категорий для текущего типа операции.
              height: 180,
              child: categoriesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (err, _) => Center(child: Text('Ошибка: $err')),
                data: (categories) {
                  final filtered = categories
                      .where(
                        (c) =>
                            c.isExpense == widget.transaction.isExpense &&
                            !c.isArchived,
                      )
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Нет доступных категорий'));
                  }

                  selectedCategory ??= filtered.firstWhere(
                    (c) => c.id == widget.transaction.categoryId,
                    orElse: () => filtered.first,
                  );

                  return CategoryPicker(
                    isExpense: widget.transaction.isExpense,
                    selectedCategory: selectedCategory,
                    onSelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    mode: CategoryPickerMode.grid,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              // Описание можно очистить: тогда будет сохранено null.
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Нижняя широкая кнопка применяет изменения и закрывает лист.
                onPressed: _save,
                child: const Text('Сохранить изменения'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;

    setState(() {
      selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        selectedDate.hour,
        selectedDate.minute,
        selectedDate.second,
        selectedDate.millisecond,
        selectedDate.microsecond,
      );
    });
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatCompactDate(date);
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(value),
      ),
    );
  }
}
