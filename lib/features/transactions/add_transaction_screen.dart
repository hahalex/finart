import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/navigation_provider.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/models/category_model.dart';
import '../../common/utils/app_theme.dart';
import '../../common/widgets/category_picker.dart';
import '../transactions/providers/transactions_notifier.dart';
import '../planned/presentation/planned_list_screen.dart';
import '../categories/categories_screen.dart';
import 'ai_categorization_screen.dart';

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
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Новая операция'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.event, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlannedListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, size: 22),
            onPressed: () async {
              final result = await Navigator.push<CategoryModel>(
                context,
                MaterialPageRoute(
                  builder: (_) => AiCategorizationScreen(isExpense: isExpense),
                ),
              );

              if (result != null) {
                setState(() {
                  selectedCategory = result;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Переключатель
            Padding(
              padding: const EdgeInsets.all(16),
              child: ToggleButtons(
                isSelected: [isExpense, !isExpense],
                borderRadius: BorderRadius.circular(12),
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
            ),

            /// 🔹 Сумма
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '0 ₽',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 Категории
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 220,
                child: categoriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                  error: (err, _) => Center(child: Text('Ошибка: $err')),
                  data: (categories) {
                    final filtered = categories
                        .where((c) => c.isExpense == isExpense && !c.isArchived)
                        .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: TextButton(
                          onPressed: () => _navigateToCategories(context),
                          child: const Text('Создать категории'),
                        ),
                      );
                    }

                    return CategoryPicker(
                      isExpense: isExpense,
                      selectedCategory: selectedCategory,
                      onSelected: (c) => setState(() => selectedCategory = c),
                      mode: CategoryPickerMode.grid,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 Описание
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Описание',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const Spacer(),

            /// 🔹 Кнопка сохранить
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _canSave ? _saveTransaction : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Icon(Icons.check, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSave {
    final amount = double.tryParse(amountController.text);
    return selectedCategory != null && amount != null && amount > 0;
  }

  void _saveTransaction() {
    final amount = double.tryParse(amountController.text);

    if (selectedCategory == null || amount == null || amount <= 0) {
      _showError('Заполни все поля');
      return;
    }

    ref
        .read(transactionsProvider.notifier)
        .addTransaction(
          amount: amount,
          categoryId: selectedCategory!.id,
          isExpense: isExpense,
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
        );

    /// 🔥 ВАЖНО: сначала меняем вкладку
    ref.read(bottomNavIndexProvider.notifier).state = 0;

    /// 🔥 потом закрываем экран БЕЗ конфликтов
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    /// 🔥 обновляем категории (если добавляли новые)
    ref.invalidate(allCategoriesProvider);

    _clearForm();
  }

  void _clearForm() {
    amountController.clear();
    descriptionController.clear();
    selectedCategory = null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CategoriesScreen(),
        settings: RouteSettings(arguments: isExpense),
      ),
    ).then((_) {
      /// 🔥 обязательно обновляем категории после возврата
      ref.invalidate(allCategoriesProvider);
    });
  }
}
