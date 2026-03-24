import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/app_theme.dart';
import '../../../common/models/category_model.dart';
import '../../../common/models/planned_payment_model.dart';
import '../../../common/providers/categories_provider.dart';
import '../../../common/providers/planned_repository_provider.dart';
import '../providers/planned_ui_providers.dart';

class PlannedFormDialog extends ConsumerStatefulWidget {
  final PlannedPaymentModel? existingPayment;

  const PlannedFormDialog({super.key, this.existingPayment});

  @override
  ConsumerState<PlannedFormDialog> createState() => _PlannedFormDialogState();
}

class _PlannedFormDialogState extends ConsumerState<PlannedFormDialog> {
  late bool _isExpense;

  String? _selectedRootId;
  String? _selectedCategoryId;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _recurrence = 'monthly';

  @override
  void initState() {
    super.initState();

    if (widget.existingPayment != null) {
      final p = widget.existingPayment!;
      _isExpense = p.isExpense;
      _selectedCategoryId = p.categoryId;
      _titleController.text = p.title;
      _amountController.text = p.amount.toString();
      _selectedDate = p.startDate;
      _recurrence = p.recurrence;
    } else {
      _isExpense = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(_categoriesProvider(_isExpense));

    return AlertDialog(
      title: Text(
        widget.existingPayment == null ? 'Новый платёж' : 'Редактировать',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔹 Тип
            ToggleButtons(
              isSelected: [_isExpense, !_isExpense],
              borderRadius: BorderRadius.circular(12),
              onPressed: (index) {
                setState(() {
                  _isExpense = index == 0;
                  _selectedRootId = null;
                  _selectedCategoryId = null;
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

            /// 🔹 Название
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// 🔹 Сумма
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Сумма',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 РОДИТЕЛЬСКИЕ КАТЕГОРИИ
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Категория',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 100,
              child: categoriesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (e, _) => Text('Ошибка: $e'),
                data: (categories) {
                  final roots = categories
                      .where((c) => c.parentId == null)
                      .toList();

                  final subs = categories
                      .where((c) => c.parentId != null)
                      .toList();

                  return Column(
                    children: [
                      /// 🔹 ROOT LIST
                      SizedBox(
                        height: 90,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: roots.map((root) {
                            final isSelected = _selectedRootId == root.id;

                            return GestureDetector(
                              onTap: () {
                                final hasSubs = subs.any(
                                  (s) => s.parentId == root.id,
                                );

                                setState(() {
                                  _selectedRootId = root.id;

                                  /// если нет подкатегорий → сразу выбираем
                                  _selectedCategoryId = hasSubs
                                      ? null
                                      : root.id;
                                });
                              },
                              child: Container(
                                width: 90,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                padding: const EdgeInsets.all(6),
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
                                      root.iconData,
                                      size: 28,
                                      color: root.colorValue,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      root.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      /// 🔹 SUBCATEGORIES
                      if (_selectedRootId != null)
                        Builder(
                          builder: (_) {
                            final children = subs
                                .where((s) => s.parentId == _selectedRootId)
                                .toList();

                            if (children.isEmpty) return const SizedBox();

                            return SizedBox(
                              height: 80,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: children.map((sub) {
                                  final isSelected =
                                      _selectedCategoryId == sub.id;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryId = sub.id;
                                      });
                                    },
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryColor.withOpacity(
                                                0.2,
                                              )
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: isSelected
                                            ? Border.all(
                                                color: AppTheme.primaryColor,
                                              )
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            sub.iconData,
                                            size: 22,
                                            color: sub.colorValue,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            sub.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            /// 🔹 Дата
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
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),

            /// 🔹 Периодичность
            DropdownButtonFormField<String>(
              value: _recurrence,
              decoration: const InputDecoration(
                labelText: 'Периодичность',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Один раз')),
                DropdownMenuItem(value: 'daily', child: Text('Ежедневно')),
                DropdownMenuItem(value: 'weekly', child: Text('Еженедельно')),
                DropdownMenuItem(value: 'monthly', child: Text('Ежемесячно')),
                DropdownMenuItem(value: 'yearly', child: Text('Ежегодно')),
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
          onPressed: _isValid ? () => _save(context) : null,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }

  /// 🔥 категории
  AutoDisposeFutureProvider<List<CategoryModel>> _categoriesProvider(
    bool isExpense,
  ) {
    return FutureProvider.autoDispose((ref) async {
      final repo = ref.watch(categoriesRepositoryProvider);

      final roots = await repo.getRootCategories(isExpense);
      final subs = await repo.getAllSubcategories(isExpense);

      return [...roots, ...subs].where((c) => !c.isArchived).toList();
    });
  }

  bool get _isValid {
    final amount = double.tryParse(_amountController.text);
    return _titleController.text.trim().isNotEmpty &&
        amount != null &&
        amount > 0 &&
        _selectedCategoryId != null;
  }

  void _save(BuildContext context) async {
    final repo = ref.read(plannedRepositoryProvider);
    final amount = double.parse(_amountController.text);

    if (_selectedCategoryId == null) return;

    if (widget.existingPayment != null) {
      final updated = widget.existingPayment!.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        isExpense: _isExpense,
        startDate: _selectedDate,
        recurrence: _recurrence,
      );
      await repo.updatePlannedPayment(updated);
    } else {
      final newPayment = PlannedPaymentModel(
        id: 'planned_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        isExpense: _isExpense,
        startDate: _selectedDate,
        recurrence: _recurrence,
        createdAt: DateTime.now(),
      );
      await repo.insertPlannedPayment(newPayment);
    }

    if (mounted) {
      ref.invalidate(plannedPaymentsListProvider);
      Navigator.pop(context);
    }
  }
}
