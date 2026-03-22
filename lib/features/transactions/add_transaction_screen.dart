import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/navigation_provider.dart';
import '../transactions/providers/transactions_notifier.dart';
import '../transactions/providers/categories_provider.dart';
import '../../common/models/category_model.dart';
import '../../common/utils/app_theme.dart';
import '../planned/presentation/planned_list_screen.dart'; // ✅ Для навигации

/// Экран добавления дохода или расхода (упрощённый)
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  bool isExpense = true;
  CategoryModel? selectedCategory;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref
        .watch(categoriesProvider)
        .where((c) => c.isExpense == isExpense)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Новая операция'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        // ✅ Кнопка перехода к предстоящим платежам (как на экране Записи)
        actions: [
          IconButton(
            icon: const Icon(Icons.event, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlannedListScreen()),
              );
            },
            tooltip: 'Предстоящие платежи',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Переключатель: Расход / Доход
              ToggleButtons(
                isSelected: [isExpense, !isExpense],
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                fillColor: isExpense
                    ? AppTheme.expenseColor
                    : AppTheme.incomeColor,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                borderColor: isExpense
                    ? AppTheme.expenseColor
                    : AppTheme.incomeColor,
                selectedBorderColor: isExpense
                    ? AppTheme.expenseColor
                    : AppTheme.incomeColor,
                onPressed: (index) {
                  setState(() {
                    isExpense = index == 0;
                    selectedCategory = null;
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Расход'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('Доход'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Ввод суммы
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '0 ₽',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 16),

              /// Категории
              Text('Категория', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map((category) {
                    final isSelected = selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category.icon,
                              size: 32,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              /// Описание
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Описание (необязательно)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),

              const Spacer(),

              /// Кнопка сохранения
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Icon(Icons.check, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Сохранение обычной транзакции
  void _saveTransaction() {
    if (selectedCategory == null) {
      _showError('Выберите категорию');
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Введите корректную сумму');
      return;
    }

    ref
        .read(transactionsProvider.notifier)
        .addTransaction(
          amount: amount,
          categoryId: selectedCategory!.id,
          isExpense: isExpense,
          description: descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
        );

    // Возвращаемся на вкладку "Записи"
    ref.read(bottomNavIndexProvider.notifier).state = 0;
    _clearForm();
  }

  /// Показать ошибку
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.expenseColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Очистка формы
  void _clearForm() {
    amountController.clear();
    descriptionController.clear();
    selectedCategory = null;
  }
}
