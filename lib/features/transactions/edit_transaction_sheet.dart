import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/categories_provider.dart';
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

  @override
  void initState() {
    super.initState();

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

  void _save() {
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
      createdAt: widget.transaction.createdAt,
      isExpense: widget.transaction.isExpense,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    );

    ref.read(transactionsProvider.notifier).editTransaction(updated);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Padding(
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

            SizedBox(
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
                onPressed: _save,
                child: const Text('Сохранить изменения'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
