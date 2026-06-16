// Файл: lib/features/transactions/add_transaction_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../common/localization/app_strings.dart';
import '../../common/models/category_model.dart';
import '../../common/models/account_model.dart';
import '../../common/providers/accounts_provider.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/providers/navigation_provider.dart';
import '../../common/utils/app_theme.dart';
import '../../common/widgets/category_picker.dart';
import '../categories/categories_screen.dart';
import '../planned/presentation/planned_list_screen.dart';
import 'ai_categorization_screen.dart';
import 'providers/transactions_notifier.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.initialAccountId});

  final String? initialAccountId;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  bool isExpense = true;
  CategoryModel? selectedCategory;
  AccountModel? selectedAccount;
  DateTime selectedDate = DateTime.now();
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
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(strings.isRu ? 'Новая операция' : 'New transaction'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            // Правая верхняя кнопка с календарем ведет к предстоящим платежам.
            icon: const Icon(Icons.event, size: 22),
            tooltip: strings.isRu ? 'Предстоящие платежи' : 'Upcoming payments',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlannedListScreen()),
              );
            },
          ),
          IconButton(
            // Вторая кнопка запускает AI-категоризацию и может вернуть
            // распознанную категорию в текущую форму.
            icon: const Icon(Icons.auto_awesome, size: 22),
            tooltip: strings.isRu ? 'AI категоризация' : 'AI categorization',
            onPressed: () async {
              final result = await Navigator.push<CategoryModel>(
                context,
                MaterialPageRoute(
                  builder: (_) => const AiCategorizationScreen(),
                ),
              );

              if (result != null) {
                setState(() => selectedCategory = result);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedPadding(
              // Когда открывается клавиатура, форма мягко поднимается вверх,
              // чтобы поле суммы/описания не оказалось под системной панелью.
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ToggleButtons(
                          // Переключатель Расход/Доход расположен вверху формы.
                          // При смене типа сбрасываем категорию, потому что
                          // расходные и доходные категории живут отдельно.
                          isSelected: [isExpense, !isExpense],
                          borderRadius: BorderRadius.circular(12),
                          onPressed: (index) {
                            setState(() {
                              isExpense = index == 0;
                              selectedCategory = null;
                            });
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(strings.isRu ? 'Расход' : 'Expense'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(strings.isRu ? 'Доход' : 'Income'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          // Центральное крупное поле суммы — главный ввод экрана.
                          // Оно намеренно без рамки, чтобы не спорить с категорией.
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: accountsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (err, _) => Text('Error: $err'),
                          data: (accounts) {
                            selectedAccount ??=
                                accounts.firstWhereOrNull(
                                  (account) =>
                                      account.id == widget.initialAccountId,
                                ) ??
                                accounts
                                    .where((account) => account.isMain)
                                    .firstOrNull;
                            return DropdownButtonFormField<String>(
                              // Выбор счета: основной счет отправляет операцию
                              // в "Записи", вторичные счета — в историю счета.
                              initialValue: selectedAccount?.id,
                              decoration: InputDecoration(
                                labelText: strings.accounts,
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
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _DatePickerField(
                          label: strings.isRu ? 'Дата' : 'Date',
                          value: _formatDate(context, selectedDate),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          // Блок категорий ограничен по высоте, чтобы кнопка
                          // сохранения оставалась достижимой на небольших экранах.
                          height: 220,
                          child: categoriesAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                            error: (err, _) =>
                                Center(child: Text('Error: $err')),
                            data: (categories) {
                              final filtered = categories
                                  .where(
                                    (c) =>
                                        c.isExpense == isExpense &&
                                        !c.isArchived,
                                  )
                                  .toList();

                              if (filtered.isEmpty) {
                                return Center(
                                  child: TextButton(
                                    onPressed: () =>
                                        _navigateToCategories(context),
                                    child: Text(
                                      strings.isRu
                                          ? 'Создать категории'
                                          : 'Create categories',
                                    ),
                                  ),
                                );
                              }

                              return CategoryPicker(
                                // Сетка категорий позволяет быстро выбрать
                                // основную категорию или подкатегорию.
                                isExpense: isExpense,
                                selectedCategory: selectedCategory,
                                onSelected: (c) =>
                                    setState(() => selectedCategory = c),
                                mode: CategoryPickerMode.grid,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          // Описание необязательное; если пусто, в записи будет
                          // отображаться название категории.
                          controller: descriptionController,
                          decoration: InputDecoration(
                            hintText: strings.isRu ? 'Описание' : 'Description',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          // Нижняя широкая кнопка сохраняет операцию.
                          // Она отключена, пока нет суммы и категории.
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
              ),
            );
          },
        ),
      ),
    );
  }

  bool get _canSave {
    final amount = double.tryParse(amountController.text);
    return selectedCategory != null && amount != null && amount > 0;
  }

  Future<void> _saveTransaction() async {
    final strings = AppStrings.of(context);
    final amount = double.tryParse(amountController.text);

    if (selectedCategory == null || amount == null || amount <= 0) {
      _showError(strings.isRu ? 'Заполните все поля' : 'Fill in all fields');
      return;
    }

    await ref
        .read(transactionsProvider.notifier)
        .addTransaction(
          amount: amount,
          categoryId: selectedCategory!.id,
          accountId: selectedAccount?.id,
          isExpense: isExpense,
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          createdAt: selectedDate,
        );

    if (!mounted) return;
    ref.read(bottomNavIndexProvider.notifier).state = 0;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    ref.invalidate(allCategoriesProvider);
    _clearForm();
  }

  void _clearForm() {
    amountController.clear();
    descriptionController.clear();
    selectedCategory = null;
    selectedDate = DateTime.now();
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
      ref.invalidate(allCategoriesProvider);
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
