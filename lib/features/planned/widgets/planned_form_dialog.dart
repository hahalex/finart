import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/utils/app_theme.dart';
import '../../../../common/models/category_model.dart';
import '../../../../common/models/planned_payment_model.dart';
import '../providers/planned_ui_providers.dart';
import '../../../../common/providers/planned_repository_provider.dart';

/// Диалог создания/редактирования запланированного платежа
class PlannedFormDialog extends ConsumerStatefulWidget {
  final PlannedPaymentModel? existingPayment;
  final List<CategoryModel> categories;

  const PlannedFormDialog({
    super.key,
    this.existingPayment,
    required this.categories,
  });

  @override
  ConsumerState<PlannedFormDialog> createState() => _PlannedFormDialogState();
}

class _PlannedFormDialogState extends ConsumerState<PlannedFormDialog> {
  late bool _isExpense;
  late String _selectedCategoryId;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _recurrence = 'monthly';

  @override
  void initState() {
    super.initState();
    if (widget.existingPayment != null) {
      _isExpense = widget.existingPayment!.isExpense;
      _selectedCategoryId = widget.existingPayment!.categoryId;
      _titleController.text = widget.existingPayment!.title;
      _amountController.text = widget.existingPayment!.amount.toString();
      _selectedDate = widget.existingPayment!.startDate;
      _recurrence = widget.existingPayment!.recurrence;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = widget.categories
        .where((c) => c.isExpense == _isExpense)
        .toList();

    final isValid =
        _titleController.text.trim().isNotEmpty &&
        double.tryParse(_amountController.text) != null &&
        double.tryParse(_amountController.text)! > 0 &&
        _selectedCategoryId.isNotEmpty;

    return AlertDialog(
      title: Text(
        widget.existingPayment == null ? 'Новый платёж' : 'Редактировать',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Переключатель доход/расход
            ToggleButtons(
              isSelected: [_isExpense, !_isExpense],
              borderRadius: BorderRadius.circular(12),
              onPressed: (index) {
                setState(() {
                  _isExpense = index == 0;
                  _selectedCategoryId = '';
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Расход'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Доход'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Название
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Например: Подписка Яндекс.Плюс',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Сумма
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Сумма',
                hintText: '0 ₽',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 12),

            // Категория (горизонтальный скролл как в AddTransactionScreen)
            Text('Категория', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: filteredCategories.map((category) {
                  final isSelected = _selectedCategoryId == category.id;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategoryId = category.id),
                    child: Container(
                      width: 75,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryColor)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category.icon,
                            size: 28,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Дата начала
            ListTile(
              title: const Text('Дата первого платежа'),
              subtitle: Text(
                '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),

            // Периодичность
            DropdownButtonFormField<String>(
              value: _recurrence,
              decoration: const InputDecoration(
                labelText: 'Периодичность',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('📅 Один раз')),
                DropdownMenuItem(value: 'daily', child: Text('🔄 Ежедневно')),
                DropdownMenuItem(
                  value: 'weekly',
                  child: Text('📆 Еженедельно'),
                ),
                DropdownMenuItem(
                  value: 'monthly',
                  child: Text('🗓️ Ежемесячно'),
                ),
                DropdownMenuItem(value: 'yearly', child: Text('🎂 Ежегодно')),
              ],
              onChanged: (value) => setState(() => _recurrence = value!),
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
          onPressed: isValid ? () => _save(context) : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  void _save(BuildContext context) async {
    final repo = ref.read(plannedRepositoryProvider);
    final amount = double.parse(_amountController.text);

    if (widget.existingPayment != null) {
      // Редактирование
      final updated = widget.existingPayment!.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _selectedCategoryId,
        isExpense: _isExpense,
        startDate: _selectedDate,
        recurrence: _recurrence,
      );
      await repo.updatePlannedPayment(updated);
    } else {
      // Создание нового
      final newPayment = PlannedPaymentModel(
        id: 'planned_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _selectedCategoryId,
        isExpense: _isExpense,
        startDate: _selectedDate,
        recurrence: _recurrence,
        createdAt: DateTime.now(),
      );
      await repo.insertPlannedPayment(newPayment);
    }

    if (mounted) Navigator.pop(context);
  }
}
