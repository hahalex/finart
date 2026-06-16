// Файл: lib/features/transactions/transactions_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../common/localization/app_strings.dart';
import '../../common/models/category_model.dart';
import '../../common/providers/accounts_provider.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/providers/selected_month_provider.dart';
import '../../common/utils/app_theme.dart';
import '../../common/utils/date_grouping.dart';
import '../../common/widgets/date_header.dart';
import '../../common/widgets/month_navigation.dart';
import '../../common/widgets/month_picker_dialog.dart';
import '../../common/widgets/summary_card.dart';
import '../../common/widgets/transaction_tile.dart';
import '../accounts/accounts_screen.dart';
import '../planned/presentation/planned_list_screen.dart';
import 'providers/transactions_notifier.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final balanceColor = AppTheme.balanceAccentOf(context);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final allTransactions = ref.watch(transactionsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    final (monthStart, monthEnd) = getMonthRange(selectedMonth);

    // На экране "Записи" показываем только операции выбранного месяца.
    // Операции вторичных счетов сюда не попадают на уровне notifier/репозитория.
    final monthTransactions = allTransactions
        .where(
          (t) =>
              (t.createdAt.isAfter(monthStart) ||
                  t.createdAt.isAtSameMomentAs(monthStart)) &&
              t.createdAt.isBefore(monthEnd),
        )
        .toList();

    final sortedTransactions = [...monthTransactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final groupedTransactions = groupItemsByDate(
      items: sortedTransactions,
      dateExtractor: (t) => t.createdAt,
      languageCode: strings.isRu ? 'ru' : 'en',
    );

    final totalIncome = allTransactions
        .where((t) => !t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = allTransactions
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final mainAccountBalance = accountsAsync.valueOrNull
        ?.where((account) => account.isMain)
        .firstOrNull
        ?.balance;
    final balance = mainAccountBalance ?? totalIncome - totalExpense;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя строка: слева кнопка "Счета", по центру перелистывание
            // месяцев, справа кнопка "Предстоящие платежи".
            MonthNavigation(
              selectedMonth: selectedMonth,
              onPrevious: () => _changeMonth(ref, -1),
              onNext: () => _changeMonth(ref, 1),
              onMonthTap: () => _showMonthPicker(context, ref),
              leading: IconButton(
                // Левая иконка открывает модуль счетов.
                icon: const Icon(Icons.account_balance_wallet_outlined),
                tooltip: strings.accounts,
                color: colors.accounts,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountsScreen()),
                  );
                },
              ),
              trailing: IconButton(
                // Правая иконка открывает список предстоящих платежей.
                icon: const Icon(Icons.event_outlined),
                tooltip: strings.upcomingPayments,
                color: colors.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlannedListScreen(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.pagePadding),
              child: Row(
                children: [
                  // Три верхние карточки показывают текущее состояние
                  // основного счета, а выбор месяца влияет только на список.
                  // SummaryCard сам отвечает за фон, скругления, тень и иконку.
                  SummaryCard(
                    title: strings.isRu ? 'Доходы' : 'Income',
                    amount: totalIncome,
                    color: colors.income,
                    icon: Icons.arrow_downward_rounded,
                  ),
                  SummaryCard(
                    title: strings.isRu ? 'Баланс' : 'Balance',
                    amount: balance,
                    color: balanceColor,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  SummaryCard(
                    title: strings.isRu ? 'Расходы' : 'Expenses',
                    amount: totalExpense,
                    color: colors.expense,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ],
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (categories) {
                  if (groupedTransactions.isEmpty) {
                    return _buildEmptyState(context, selectedMonth, strings);
                  }

                  // Список сгруппирован по датам: сначала DateHeader,
                  // затем карточки операций за этот день.
                  return ListView(
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
                                name: strings.isRu
                                    ? 'Без категории'
                                    : 'No category',
                                iconCode: Icons.category_outlined.codePoint,
                                isExpense: transaction.isExpense,
                                color: AppTheme.unknownCategoryColor.toARGB32(),
                              ),
                            );

                            var categoryTitle = category.name;
                            if (category.isSubcategory) {
                              final parentCategory = categories.firstWhere(
                                (c) => c.id == category.parentId,
                                orElse: () => CategoryModel(
                                  id: 'unknown',
                                  name: '',
                                  iconCode: Icons.category_outlined.codePoint,
                                  isExpense: category.isExpense,
                                  color: AppTheme.unknownCategoryColor
                                      .toARGB32(),
                                ),
                              );

                              if (parentCategory.name.isNotEmpty) {
                                categoryTitle =
                                    '${category.name} (${parentCategory.name})';
                              }
                            }

                            return TransactionTile(
                              // Нажатие по TransactionTile открывает редактирование,
                              // свайп влево показывает удаление.
                              transaction: transaction,
                              title: transaction.description ?? categoryTitle,
                              category: categoryTitle,
                              categoryIcon: category.iconData,
                              categoryColor: category.colorValue,
                              amount: transaction.amount,
                              isExpense: transaction.isExpense,
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  void _showMonthPicker(BuildContext context, WidgetRef ref) {
    final current = ref.read(selectedMonthProvider);

    showDialog(
      // Диалог выбора месяца вызывается нажатием по центральной части
      // MonthNavigation.
      context: context,
      builder: (_) => MonthPickerDialog(
        initialDate: current,
        onSelected: (newDate) {
          ref.read(selectedMonthProvider.notifier).state = newDate;
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    DateTime month,
    AppStrings strings,
  ) {
    final monthName = getMonthName(
      month,
      languageCode: strings.isRu ? 'ru' : 'en',
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // Пустое состояние: мягкая квадратная плашка с иконкой чека.
            // surfaceSoft делает ее заметной, но не спорящей с карточками.
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppTheme.colorsOf(context).surfaceSoft,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: AppTheme.mutedTextOf(context),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            strings.isRu
                ? 'Нет записей за $monthName'
                : 'No entries for $monthName',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.isRu
                ? 'Нажмите + чтобы добавить'
                : 'Tap + to add a transaction',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedTextOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
