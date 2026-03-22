import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/widgets/summary_card.dart';
import '../../common/widgets/transaction_tile.dart';
import '../../common/widgets/date_header.dart';
import '../../common/widgets/month_navigation.dart';
import '../../common/widgets/month_picker_dialog.dart';
import '../../common/utils/date_grouping.dart';
import '../../common/models/category_model.dart';
import '../../common/utils/app_theme.dart';
import '../../common/providers/selected_month_provider.dart';
import '../transactions/providers/transactions_notifier.dart';
import '../transactions/providers/categories_provider.dart';
import '../../features/planned/presentation/planned_list_screen.dart';

/// Экран "Записи" — главный экран приложения
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final allTransactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);

    /// ✅ Фильтруем транзакции по выбранному месяцу
    final (monthStart, monthEnd) = getMonthRange(selectedMonth);
    final monthTransactions = allTransactions
        .where(
          (t) =>
              t.createdAt.isAfter(monthStart) ||
              t.createdAt.isAtSameMomentAs(monthStart),
        )
        .where((t) => t.createdAt.isBefore(monthEnd))
        .toList();

    /// Сортируем по дате (новые сверху)
    final sortedTransactions = [...monthTransactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    /// Группируем по датам
    final groupedTransactions = groupItemsByDate(
      items: sortedTransactions,
      dateExtractor: (t) => t.createdAt,
    );

    /// Подсчёт аналитики ТОЛЬКО для выбранного месяца
    final totalIncome = monthTransactions
        .where((t) => !t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalExpense = monthTransactions
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// ✅ Навигация по месяцам
            MonthNavigation(
              selectedMonth: selectedMonth,
              onPrevious: () => _changeMonth(ref, -1),
              onNext: () => _changeMonth(ref, 1),
              onMonthTap: () => _showMonthPicker(context, ref),
            ),

            /// Шапка с аналитикой
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Карточки: доходы / расходы / баланс
                  Row(
                    children: [
                      SummaryCard(
                        title: 'Доходы',
                        amount: totalIncome,
                        color: AppTheme.incomeColor,
                      ),
                      SummaryCard(
                        title: 'Расходы',
                        amount: totalExpense,
                        color: AppTheme.expenseColor,
                      ),
                      SummaryCard(
                        title: 'Баланс',
                        amount: balance,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Список операций
            Expanded(
              child: groupedTransactions.isEmpty
                  ? _buildEmptyState(context, selectedMonth)
                  : ListView(
                      children: groupedTransactions.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DateHeader(label: entry.key),
                            ...entry.value.map((transaction) {
                              final category = categories.firstWhere(
                                (c) => c.id == transaction.categoryId,
                                orElse: () => CategoryModel(
                                  id: 'unknown',
                                  name: 'Без категории',
                                  icon: Icons.category,
                                  isExpense: true,
                                ),
                              );

                              return TransactionTile(
                                title: transaction.description ?? category.name,
                                category: category.name,
                                amount: transaction.amount,
                                isExpense: transaction.isExpense,
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),

      // FAB для перехода к предстоящим платежам
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlannedListScreen()),
          );
        },
        child: const Icon(Icons.event),
        tooltip: 'Предстоящие платежи',
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Смена месяца на +/- 1
  void _changeMonth(WidgetRef ref, int delta) {
    final current = ref.read(selectedMonthProvider);
    final newMonth = current.month + delta;
    final newYear = newMonth > 12
        ? current.year + 1
        : newMonth < 1
        ? current.year - 1
        : current.year;
    final normalizedMonth = newMonth > 12
        ? 1
        : newMonth < 1
        ? 12
        : newMonth;

    ref.read(selectedMonthProvider.notifier).state = DateTime(
      newYear,
      normalizedMonth,
      1,
    );
  }

  /// Показать диалог выбора месяца
  void _showMonthPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(selectedMonthProvider);

    showDialog(
      context: context,
      builder: (_) => MonthPickerDialog(
        initialDate: current,
        onSelected: (newDate) {
          ref.read(selectedMonthProvider.notifier).state = newDate;
        },
      ),
    );
  }

  /// Пустое состояние с подсказкой
  Widget _buildEmptyState(BuildContext context, DateTime month) {
    final monthName = getMonthName(month);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Нет записей за $monthName',
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
}
