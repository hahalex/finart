// Файл: lib/features/analytics/charts_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/localization/app_strings.dart';
import '../../common/models/transaction_model.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/utils/app_theme.dart';
import 'domain/analytics_models.dart';
import 'providers/analytics_provider.dart';
import 'widgets/category_expense_tile.dart';
import 'widgets/category_expenses_pie_chart.dart';
import 'widgets/expenses_chart_placeholder.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final chartPalette = AppTheme.analyticsChartPaletteOf(context);
    final analyticsType = ref.watch(analyticsTypeProvider);
    final period = ref.watch(analyticsPeriodProvider);
    final categoryMode = ref.watch(categoryDisplayModeProvider);
    final chartView = ref.watch(analyticsChartViewProvider);

    final chartDataAsync = ref.watch(chartDataProvider);
    final categoryExpensesAsync = ref.watch(categoryExpensesProvider);
    final comparisonAsync = ref.watch(analyticsComparisonProvider);
    final trendValueAsync = ref.watch(chartTrendValueProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final categoryExpenses =
        categoryExpensesAsync.valueOrNull ?? const <CategoryExpenseData>[];
    final topPieExpenses = [...categoryExpenses]
      ..sort((a, b) => b.total.compareTo(a.total));
    final visiblePieExpenses = topPieExpenses.take(10).toList();
    final categories = ref.watch(allCategoriesProvider).value ?? [];

    String periodLabel() {
      final isExpense = analyticsType == AnalyticsType.expense;
      switch (period) {
        case AnalyticsPeriod.day:
          return isExpense
              ? (strings.isRu
                    ? '\u0420\u0430\u0441\u0445\u043e\u0434\u044b \u043f\u043e \u0434\u043d\u044f\u043c'
                    : 'Expenses by day')
              : (strings.isRu
                    ? '\u0414\u043e\u0445\u043e\u0434\u044b \u043f\u043e \u0434\u043d\u044f\u043c'
                    : 'Income by day');
        case AnalyticsPeriod.week:
          return isExpense
              ? (strings.isRu
                    ? '\u0420\u0430\u0441\u0445\u043e\u0434\u044b \u043f\u043e \u043d\u0435\u0434\u0435\u043b\u044f\u043c'
                    : 'Expenses by week')
              : (strings.isRu
                    ? '\u0414\u043e\u0445\u043e\u0434\u044b \u043f\u043e \u043d\u0435\u0434\u0435\u043b\u044f\u043c'
                    : 'Income by week');
        case AnalyticsPeriod.month:
          return isExpense
              ? (strings.isRu
                    ? '\u0420\u0430\u0441\u0445\u043e\u0434\u044b \u043f\u043e \u043c\u0435\u0441\u044f\u0446\u0430\u043c'
                    : 'Expenses by month')
              : (strings.isRu
                    ? '\u0414\u043e\u0445\u043e\u0434\u044b \u043f\u043e \u043c\u0435\u0441\u044f\u0446\u0430\u043c'
                    : 'Income by month');
      }
    }

    final categoryColors = <String, Color>{};
    for (var i = 0; i < categoryExpenses.length; i++) {
      final category = categories.firstWhereOrNull(
        (item) => item.id == categoryExpenses[i].categoryId,
      );
      categoryColors[categoryExpenses[i].categoryId] =
          category?.colorValue ?? AppTheme.unknownCategoryColor;
    }

    void openCategoryDetails(String categoryId) {
      final category = categories.firstWhereOrNull((c) => c.id == categoryId);
      final descendantIds = <String>{categoryId};
      if (category != null && !category.isSubcategory) {
        for (final sub in categories.where(
          (item) => item.parentId == category.id,
        )) {
          descendantIds.add(sub.id);
        }
      }

      final categoryTransactions =
          filteredTransactions
              .where((tx) => descendantIds.contains(tx.categoryId))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final subcategoryTotals =
          categories
              .where((item) => item.parentId == categoryId)
              .map((sub) {
                final total = filteredTransactions
                    .where((tx) => tx.categoryId == sub.id)
                    .fold<double>(0, (sum, tx) => sum + tx.amount);
                final count = filteredTransactions
                    .where((tx) => tx.categoryId == sub.id)
                    .length;
                return CategoryExpenseData(
                  categoryId: sub.id,
                  total: total,
                  transactionCount: count,
                );
              })
              .where((item) => item.total > 0)
              .toList()
            ..sort((a, b) => b.total.compareTo(a.total));

      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return SafeArea(
            top: false,
            child: Container(
              height: MediaQuery.of(sheetContext).size.height * 0.78,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (category?.colorValue ?? colors.primary)
                            .withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    (category?.colorValue ?? colors.primary)
                                        .withOpacity(0.18),
                                child: Icon(
                                  category?.iconData ?? Icons.category_outlined,
                                  color: category?.colorValue ?? colors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category?.name ??
                                      (strings.isRu
                                          ? '\u041a\u0430\u0442\u0435\u0433\u043e\u0440\u0438\u044f'
                                          : 'Category'),
                                  style: Theme.of(sheetContext)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            strings.isRu
                                ? '\u041e\u043f\u0435\u0440\u0430\u0446\u0438\u0438 \u0437\u0430 \u0432\u044b\u0431\u0440\u0430\u043d\u043d\u044b\u0439 \u043f\u0435\u0440\u0438\u043e\u0434'
                                : 'Transactions for the selected period',
                            style: Theme.of(sheetContext).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.mutedTextOf(sheetContext),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${categoryTransactions.length} ${strings.isRu ? '\u043e\u043f\u0435\u0440\u0430\u0446\u0438\u0439' : 'transactions'}',
                            style: Theme.of(sheetContext).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.mutedTextOf(sheetContext),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (subcategoryTotals.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.isRu ? 'Подкатегории' : 'Subcategories',
                            style: Theme.of(sheetContext).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: subcategoryTotals.map((item) {
                              final sub = categories.firstWhereOrNull(
                                (entry) => entry.id == item.categoryId,
                              );
                              final chipColor =
                                  sub?.colorValue ??
                                  (category?.colorValue ?? colors.primary);
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  openCategoryDetails(item.categoryId);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: chipColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: chipColor.withOpacity(0.26),
                                    ),
                                  ),
                                  child: Text(
                                    '${sub?.name ?? item.categoryId} • ${item.total.toStringAsFixed(0)}',
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: categoryTransactions.isEmpty
                        ? Center(child: Text(strings.noData))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: categoryTransactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, index) {
                              final tx = categoryTransactions[index];
                              return _TransactionPreviewTile(
                                transaction: tx,
                                categoryName:
                                    category?.name ??
                                    (strings.isRu
                                        ? '\u0411\u0435\u0437 \u043a\u0430\u0442\u0435\u0433\u043e\u0440\u0438\u0438'
                                        : 'No category'),
                                color: category?.colorValue ?? colors.primary,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<AnalyticsType>(
            // Верхний переключатель меняет весь экран графиков:
            // анализ расходов или анализ доходов.
            segments: [
              ButtonSegment(
                value: AnalyticsType.expense,
                label: Text(
                  strings.isRu
                      ? '\u0420\u0430\u0441\u0445\u043e\u0434\u044b'
                      : 'Expenses',
                ),
              ),
              ButtonSegment(
                value: AnalyticsType.income,
                label: Text(
                  strings.isRu
                      ? '\u0414\u043e\u0445\u043e\u0434\u044b'
                      : 'Income',
                ),
              ),
            ],
            selected: {analyticsType},
            onSelectionChanged: (value) {
              ref.read(analyticsTypeProvider.notifier).state = value.first;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            // Кнопка периода циклически переключает день/неделю/месяц.
            onPressed: () {
              final next = switch (period) {
                AnalyticsPeriod.day => AnalyticsPeriod.week,
                AnalyticsPeriod.week => AnalyticsPeriod.month,
                AnalyticsPeriod.month => AnalyticsPeriod.day,
              };
              ref.read(analyticsPeriodProvider.notifier).state = next;
            },
            child: Text(periodLabel()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  periodLabel(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                // Правый переключатель меняет визуализацию графика:
                // столбики или линия/область. Рамка круглая, фон прозрачный.
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: colors.border),
                ),
                child: ToggleButtons(
                  isSelected: [
                    chartView == AnalyticsChartView.bar,
                    chartView == AnalyticsChartView.area,
                  ],
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 46,
                  ),
                  borderRadius: BorderRadius.circular(100),
                  borderColor: Colors.transparent,
                  selectedBorderColor: Colors.transparent,
                  fillColor: chartPalette.first.withOpacity(0.14),
                  // fillColor — легкая прозрачная заливка выбранной иконки,
                  // чтобы кнопка не конкурировала с самим графиком.
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  selectedColor: chartPalette.first,
                  onPressed: (index) {
                    ref
                        .read(analyticsChartViewProvider.notifier)
                        .state = index == 0
                        ? AnalyticsChartView.bar
                        : AnalyticsChartView.area;
                  },
                  children: const [
                    Icon(Icons.bar_chart_rounded, size: 20),
                    Icon(Icons.timeline_rounded, size: 20),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (comparisonAsync.valueOrNull != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnalyticsHeadline(
                comparison: comparisonAsync.valueOrNull!,
                isExpense: analyticsType == AnalyticsType.expense,
              ),
            ),
          chartDataAsync.when(
            loading: () => const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
            error: (err, _) => SizedBox(
              height: 260,
              child: Center(child: Text('Error: $err')),
            ),
            data: (points) => ExpensesChartPlaceholder(
              data: points,
              chartView: chartView,
              color: chartPalette.first,
              trendValue: trendValueAsync.valueOrNull,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  // Открывает системный выбор произвольного диапазона дат.
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      ref.read(analyticsDateRangeProvider.notifier).state =
                          picked;
                    }
                  },
                  child: Text(
                    strings.isRu
                        ? '\u041f\u0435\u0440\u0438\u043e\u0434'
                        : 'Period',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                // Сброс возвращает графики к периоду по умолчанию.
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                ),
                onPressed: () {
                  ref.read(analyticsDateRangeProvider.notifier).state = null;
                },
                child: Text(
                  strings.isRu ? '\u0421\u0431\u0440\u043e\u0441' : 'Reset',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SegmentedButton<CategoryDisplayMode>(
            // Фильтр отображения категорий: все, только основные или подкатегории.
            // Компактная типографика нужна, чтобы сегменты не переполнялись.
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
            segments: [
              ButtonSegment(
                value: CategoryDisplayMode.all,
                label: Text(
                  strings.isRu ? '\u0412\u0441\u0435' : 'All',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ButtonSegment(
                value: CategoryDisplayMode.parentOnly,
                label: Text(
                  strings.isRu
                      ? '\u041a\u0430\u0442\u0435\u0433\u043e\u0440\u0438\u0438'
                      : 'Categories',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ButtonSegment(
                value: CategoryDisplayMode.subcategoriesOnly,
                label: Text(
                  strings.isRu
                      ? '\u041f\u043e\u0434\u043a\u0430\u0442\u0435\u0433\u043e\u0440\u0438\u0438'
                      : 'Subcategories',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            selected: {categoryMode},
            onSelectionChanged: (value) {
              ref.read(categoryDisplayModeProvider.notifier).state =
                  value.first;
            },
          ),
          const SizedBox(height: 16),
          categoryExpensesAsync.when(
            loading: () => const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
            error: (err, _) => SizedBox(
              height: 240,
              child: Center(child: Text('Error: $err')),
            ),
            data: (_) => CategoryExpensesPieChart(
              expenses: visiblePieExpenses,
              categoryColors: categoryColors,
              onCategoryTap: openCategoryDetails,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            analyticsType == AnalyticsType.expense
                ? (strings.isRu
                      ? '\u0420\u0430\u0441\u0445\u043e\u0434\u044b \u043f\u043e \u043a\u0430\u0442\u0435\u0433\u043e\u0440\u0438\u044f\u043c'
                      : 'Expenses by category')
                : (strings.isRu
                      ? '\u0414\u043e\u0445\u043e\u0434\u044b \u043f\u043e \u043a\u0430\u0442\u0435\u0433\u043e\u0440\u0438\u044f\u043c'
                      : 'Income by category'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...categoryExpenses.map((expense) {
            final category = categories.firstWhereOrNull(
              (c) => c.id == expense.categoryId,
            );
            final parentCategory = category?.parentId == null
                ? null
                : categories.firstWhereOrNull(
                    (c) => c.id == category?.parentId,
                  );
            final color =
                categoryColors[expense.categoryId] ??
                AppTheme.unknownCategoryColor;
            final totalAmount = categoryExpenses.fold<double>(
              0,
              (sum, e) => sum + e.total,
            );

            return CategoryExpenseTile(
              expense: expense,
              categoryName:
                  category?.name ??
                  (strings.isRu
                      ? '\u041d\u0435\u0438\u0437\u0432\u0435\u0441\u0442\u043d\u043e'
                      : 'Unknown'),
              parentCategoryName: parentCategory?.name,
              showParentCategory:
                  categoryMode == CategoryDisplayMode.subcategoriesOnly &&
                  category?.isSubcategory == true,
              color: color,
              totalAmount: totalAmount,
              onTap: () => openCategoryDetails(expense.categoryId),
            );
          }),
        ],
      ),
    );
  }
}

class _AnalyticsHeadline extends StatelessWidget {
  const _AnalyticsHeadline({required this.comparison, required this.isExpense});

  final AnalyticsComparison comparison;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final accent = comparison.delta >= 0
        ? (isExpense
              ? AppTheme.colorsOf(context).expense
              : AppTheme.colorsOf(context).income)
        : AppTheme.balanceAccentOf(context);

    final direction = comparison.delta >= 0
        ? (strings.isRu ? 'выше' : 'higher')
        : (strings.isRu ? 'ниже' : 'lower');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.accentCardDecoration(
        context,
        accent: accent,
        radius: AppTheme.radiusMd,
      ),
      child: Row(
        children: [
          Icon(
            comparison.delta >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              strings.isRu
                  ? '${comparison.deltaPercent.abs().toStringAsFixed(0)}% $direction, чем в аналогичном периоде прошлого года'
                  : '${comparison.deltaPercent.abs().toStringAsFixed(0)}% $direction than the same period last year',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionPreviewTile extends StatelessWidget {
  const _TransactionPreviewTile({
    required this.transaction,
    required this.categoryName,
    required this.color,
  });

  final TransactionModel transaction;
  final String categoryName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor = transaction.isExpense
        ? AppTheme.colorsOf(context).expense
        : AppTheme.colorsOf(context).income;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.14),
          child: Icon(Icons.receipt_long_outlined, color: color),
        ),
        title: Text(
          transaction.description?.trim().isNotEmpty == true
              ? transaction.description!
              : categoryName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(_formatDate(transaction.createdAt)),
        ),
        trailing: Text(
          '${transaction.isExpense ? '-' : '+'}${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year  $hour:$minute';
  }
}
