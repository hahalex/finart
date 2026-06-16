// Файл: lib/features/analytics/providers/analytics_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/localization/app_language.dart';
import '../../../common/models/recommendation_model.dart';
import '../../../common/models/transaction_model.dart';
import '../../../common/providers/categories_provider.dart';
import '../../../common/providers/database_provider.dart';
import '../../../common/providers/locale_provider.dart';
import '../../transactions/providers/transactions_notifier.dart';
import '../domain/analytics_calculator.dart';
import '../domain/analytics_models.dart';
import '../widgets/expenses_chart_placeholder.dart';

enum AnalyticsType { expense, income }

enum AnalyticsPeriod { day, week, month }

enum CategoryDisplayMode { parentOnly, subcategoriesOnly, all }

enum ReportPeriod { year, halfYear, quarter, currentMonth, custom }

final analyticsChartViewProvider = StateProvider<AnalyticsChartView>(
  (ref) => AnalyticsChartView.bar,
);

final analyticsTypeProvider = StateProvider<AnalyticsType>(
  (ref) => AnalyticsType.expense,
);

final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>(
  (ref) => AnalyticsPeriod.week,
);

final categoryDisplayModeProvider = StateProvider<CategoryDisplayMode>(
  (ref) => CategoryDisplayMode.all,
);

final selectedReportPeriodProvider = StateProvider<ReportPeriod>(
  (ref) => ReportPeriod.quarter,
);

final analyticsDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);
final reportDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

DateTimeRange _normalizedRange({
  required DateTime start,
  required DateTime end,
}) {
  return DateTimeRange(
    start: DateTime(start.year, start.month, start.day),
    end: DateTime(end.year, end.month, end.day, 23, 59, 59),
  );
}

DateTimeRange _shiftRangeByYear(DateTimeRange range, int deltaYears) {
  return DateTimeRange(
    start: DateTime(
      range.start.year + deltaYears,
      range.start.month,
      range.start.day,
    ),
    end: DateTime(
      range.end.year + deltaYears,
      range.end.month,
      range.end.day,
      range.end.hour,
      range.end.minute,
      range.end.second,
    ),
  );
}

DateTimeRange _previousAdjacentRange(DateTimeRange range) {
  final days = range.end.difference(range.start).inDays + 1;
  final previousEnd = range.start.subtract(const Duration(seconds: 1));
  final previousStart = DateTime(
    previousEnd.year,
    previousEnd.month,
    previousEnd.day,
  ).subtract(Duration(days: days - 1));
  return _normalizedRange(start: previousStart, end: previousEnd);
}

DateTimeRange _baselineRange(DateTimeRange range) {
  final baselineEnd = range.start.subtract(const Duration(seconds: 1));
  return _normalizedRange(
    start: DateTime(baselineEnd.year, baselineEnd.month - 6, baselineEnd.day),
    end: baselineEnd,
  );
}

final effectiveAnalyticsRangeProvider = Provider<DateTimeRange>((ref) {
  final customRange = ref.watch(analyticsDateRangeProvider);
  if (customRange != null) {
    return _normalizedRange(start: customRange.start, end: customRange.end);
  }

  final now = DateTime.now();
  final period = ref.watch(analyticsPeriodProvider);

  switch (period) {
    case AnalyticsPeriod.day:
      return _normalizedRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      );
    case AnalyticsPeriod.week:
      return _normalizedRange(
        start: now.subtract(const Duration(days: 90)),
        end: now,
      );
    case AnalyticsPeriod.month:
      return _normalizedRange(
        start: DateTime(now.year - 1, now.month, now.day),
        end: now,
      );
  }
});

final effectiveReportRangeProvider = Provider<DateTimeRange>((ref) {
  final selectedPeriod = ref.watch(selectedReportPeriodProvider);
  final customRange = ref.watch(reportDateRangeProvider);
  final now = DateTime.now();

  switch (selectedPeriod) {
    case ReportPeriod.year:
      return _normalizedRange(
        start: DateTime(now.year - 1, now.month, now.day),
        end: now,
      );
    case ReportPeriod.halfYear:
      return _normalizedRange(
        start: DateTime(now.year, now.month - 6, now.day),
        end: now,
      );
    case ReportPeriod.quarter:
      return _normalizedRange(
        start: DateTime(now.year, now.month - 3, now.day),
        end: now,
      );
    case ReportPeriod.currentMonth:
      return _normalizedRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      );
    case ReportPeriod.custom:
      final range =
          customRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month - 3, now.day),
            end: now,
          );
      return _normalizedRange(start: range.start, end: range.end);
  }
});

final previousReportRangeProvider = Provider<DateTimeRange>((ref) {
  final range = ref.watch(effectiveReportRangeProvider);
  return _previousAdjacentRange(range);
});

final reportBaselineRangeProvider = Provider<DateTimeRange>((ref) {
  final range = ref.watch(effectiveReportRangeProvider);
  return _baselineRange(range);
});

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final type = ref.watch(analyticsTypeProvider);
  final range = ref.watch(effectiveAnalyticsRangeProvider);

  return transactions.where((tx) {
    final matchesType = type == AnalyticsType.expense
        ? tx.isExpense
        : !tx.isExpense;
    final matchesRange =
        !tx.createdAt.isBefore(range.start) && !tx.createdAt.isAfter(range.end);
    return matchesType && matchesRange;
  }).toList();
});

final reportTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final range = ref.watch(effectiveReportRangeProvider);

  return transactions.where((tx) {
    return !tx.createdAt.isBefore(range.start) &&
        !tx.createdAt.isAfter(range.end);
  }).toList();
});

final previousReportTransactionsProvider = Provider<List<TransactionModel>>((
  ref,
) {
  final transactions = ref.watch(transactionsProvider);
  final range = ref.watch(previousReportRangeProvider);

  return transactions.where((tx) {
    return !tx.createdAt.isBefore(range.start) &&
        !tx.createdAt.isAfter(range.end);
  }).toList();
});

final reportBaselineTransactionsProvider = Provider<List<TransactionModel>>((
  ref,
) {
  final transactions = ref.watch(transactionsProvider);
  final range = ref.watch(reportBaselineRangeProvider);

  return transactions.where((tx) {
    return !tx.createdAt.isBefore(range.start) &&
        !tx.createdAt.isAfter(range.end);
  }).toList();
});

final reportExpenseTransactionsProvider = Provider<List<TransactionModel>>((
  ref,
) {
  final transactions = ref.watch(reportTransactionsProvider);
  return transactions.where((tx) => tx.isExpense).toList();
});

final chartDataProvider = FutureProvider<List<ChartPoint>>((ref) async {
  final period = ref.watch(analyticsPeriodProvider);
  final transactions = ref.watch(filteredTransactionsProvider);
  final isRu = ref.watch(localeProvider) == AppLanguage.russian;

  final buckets = <String, _ChartBucket>{};
  for (final tx in transactions) {
    final date = tx.createdAt;
    String key;
    DateTime sortDate;
    String label;
    String tooltip;

    switch (period) {
      case AnalyticsPeriod.day:
        sortDate = DateTime(date.year, date.month, date.day);
        key = _dateKey(sortDate);
        label = '${date.day}.${date.month}';
        tooltip = isRu
            ? '${date.day}.${date.month}.${date.year}'
            : '${date.month}/${date.day}/${date.year}';
        break;
      case AnalyticsPeriod.week:
        sortDate = _weekStart(date);
        final week = _weekOfYear(date);
        final labelPrefix = isRu ? '\u043d\u0435\u0434' : 'wk';
        key = _dateKey(sortDate);
        label = '$labelPrefix $week';
        tooltip = isRu
            ? '\u041d\u0435\u0434\u0435\u043b\u044f $week, ${date.year}'
            : 'Week $week, ${date.year}';
        break;
      case AnalyticsPeriod.month:
        sortDate = DateTime(date.year, date.month);
        key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        label = '${date.month}.${date.year}';
        tooltip = isRu
            ? '\u041c\u0435\u0441\u044f\u0446 ${date.month}, ${date.year}'
            : 'Month ${date.month}, ${date.year}';
        break;
    }

    final existing = buckets[key];
    if (existing == null) {
      buckets[key] = _ChartBucket(
        sortDate: sortDate,
        label: label,
        tooltip: tooltip,
        total: tx.amount,
      );
    } else {
      existing.total += tx.amount;
    }
  }

  final sortedBuckets = buckets.values.toList()
    ..sort((a, b) => a.sortDate.compareTo(b.sortDate));
  final points = sortedBuckets
      .map(
        (bucket) => ChartPoint(
          label: bucket.label,
          tooltip: bucket.tooltip,
          value: bucket.total,
        ),
      )
      .toList();

  final anomalyIndexes = AnalyticsCalculator.detectAnomalyIndexes(points);
  return points.asMap().entries.map((entry) {
    final point = entry.value;
    return ChartPoint(
      label: point.label,
      tooltip: point.tooltip,
      value: point.value,
      isAnomaly: anomalyIndexes.contains(entry.key),
    );
  }).toList();
});

class _ChartBucket {
  _ChartBucket({
    required this.sortDate,
    required this.label,
    required this.tooltip,
    required this.total,
  });

  final DateTime sortDate;
  final String label;
  final String tooltip;
  double total;
}

String _dateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

DateTime _weekStart(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

int _weekOfYear(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  final firstDay = DateTime(day.year);
  return ((day.difference(firstDay).inDays + firstDay.weekday) / 7).ceil();
}

final chartTrendValueProvider = FutureProvider<double?>((ref) async {
  final points = await ref.watch(chartDataProvider.future);
  if (points.isEmpty) return null;
  return AnalyticsCalculator.averageValue(points.map((p) => p.value).toList());
});

final analyticsComparisonProvider = FutureProvider<AnalyticsComparison?>((
  ref,
) async {
  ref.watch(transactionsProvider);
  final db = ref.watch(databaseProvider);
  final range = ref.watch(effectiveAnalyticsRangeProvider);
  final type = ref.watch(analyticsTypeProvider);
  final previousRange = _shiftRangeByYear(range, -1);

  Future<double> sumForRange(DateTimeRange targetRange) async {
    final row = await db
        .customSelect(
          '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions_table
      WHERE is_expense = ?1
        AND created_at >= ?2
        AND created_at <= ?3
      ''',
          variables: [
            Variable<bool>(type == AnalyticsType.expense),
            Variable<DateTime>(targetRange.start),
            Variable<DateTime>(targetRange.end),
          ],
          readsFrom: {db.transactionsTable},
        )
        .getSingle();

    return row.read<double>('total');
  }

  final current = await sumForRange(range);
  final previous = await sumForRange(previousRange);
  if (current == 0 && previous == 0) return null;

  final delta = current - previous;
  final deltaPercent = previous == 0 ? 100.0 : (delta / previous) * 100.0;
  return AnalyticsComparison(
    currentTotal: current,
    previousTotal: previous,
    delta: delta,
    deltaPercent: deltaPercent,
  );
});

final categoryExpensesProvider = FutureProvider<List<CategoryExpenseData>>((
  ref,
) async {
  ref.watch(transactionsProvider);
  final db = ref.watch(databaseProvider);
  final range = ref.watch(effectiveAnalyticsRangeProvider);
  final type = ref.watch(analyticsTypeProvider);
  final categories = await ref.watch(allCategoriesProvider.future);
  final displayMode = ref.watch(categoryDisplayModeProvider);

  final rows = await db
      .customSelect(
        '''
    SELECT category_id, SUM(amount) AS total, COUNT(*) AS tx_count
    FROM transactions_table
    WHERE is_expense = ?1
      AND created_at >= ?2
      AND created_at <= ?3
    GROUP BY category_id
    ''',
        variables: [
          Variable<bool>(type == AnalyticsType.expense),
          Variable<DateTime>(range.start),
          Variable<DateTime>(range.end),
        ],
        readsFrom: {db.transactionsTable},
      )
      .get();

  final categoryById = {
    for (final category in categories) category.id: category,
  };
  final aggregated = <String, CategoryExpenseData>{};

  for (final row in rows) {
    final categoryId = row.readNullable<String>('category_id');
    if (categoryId == null || categoryId.trim().isEmpty) continue;
    final total = row.read<double>('total');
    final count = row.read<int>('tx_count');
    final category = categoryById[categoryId];
    if (category == null) continue;

    String effectiveId = categoryId;
    switch (displayMode) {
      case CategoryDisplayMode.all:
        effectiveId = categoryId;
        break;
      case CategoryDisplayMode.parentOnly:
        effectiveId = category.parentId ?? category.id;
        break;
      case CategoryDisplayMode.subcategoriesOnly:
        if (!category.isSubcategory) {
          continue;
        }
        effectiveId = category.id;
        break;
    }

    final existing = aggregated[effectiveId];
    aggregated[effectiveId] = CategoryExpenseData(
      categoryId: effectiveId,
      total: (existing?.total ?? 0) + total,
      transactionCount: (existing?.transactionCount ?? 0) + count,
    );
  }

  return aggregated.values.toList()..sort((a, b) => b.total.compareTo(a.total));
});

final reportExpenseCategoryExpensesProvider =
    Provider<List<CategoryExpenseData>>((ref) {
      final transactions = ref.watch(reportExpenseTransactionsProvider);
      return AnalyticsCalculator.expensesByCategory(transactions);
    });

final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(reportTransactionsProvider);
  return AnalyticsCalculator.totalIncome(transactions);
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(reportTransactionsProvider);
  return AnalyticsCalculator.totalExpense(transactions);
});

final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income - expense;
});

final reportPeriodComparisonProvider = Provider<ReportPeriodComparison?>((ref) {
  final current = ref.watch(reportTransactionsProvider);
  final previous = ref.watch(previousReportTransactionsProvider);
  if (current.isEmpty && previous.isEmpty) return null;

  final currentIncome = AnalyticsCalculator.totalIncome(current);
  final previousIncome = AnalyticsCalculator.totalIncome(previous);
  final currentExpense = AnalyticsCalculator.totalExpense(current);
  final previousExpense = AnalyticsCalculator.totalExpense(previous);
  final currentBalance = currentIncome - currentExpense;
  final previousBalance = previousIncome - previousExpense;

  double percentDelta(double currentValue, double previousValue) {
    if (previousValue == 0) return currentValue == 0 ? 0 : 100;
    return (currentValue - previousValue) / previousValue * 100;
  }

  double savingsRate(double income, double balance) {
    if (income <= 0) return 0;
    return (balance / income * 100).clamp(-999, 999);
  }

  return ReportPeriodComparison(
    currentIncome: currentIncome,
    previousIncome: previousIncome,
    incomeDelta: currentIncome - previousIncome,
    incomeDeltaPercent: percentDelta(currentIncome, previousIncome),
    currentExpense: currentExpense,
    previousExpense: previousExpense,
    expenseDelta: currentExpense - previousExpense,
    expenseDeltaPercent: percentDelta(currentExpense, previousExpense),
    currentSavingsRate: savingsRate(currentIncome, currentBalance),
    previousSavingsRate: savingsRate(previousIncome, previousBalance),
  );
});

final topCategoryNameProvider = Provider<String?>((ref) {
  final expenses = ref.watch(reportExpenseCategoryExpensesProvider);
  final categories = ref.watch(allCategoriesProvider).value ?? [];
  if (expenses.isEmpty) return null;

  final top = expenses.reduce((a, b) => a.total > b.total ? a : b);
  final category = categories.firstWhereOrNull((c) => c.id == top.categoryId);
  return category?.name;
});

final top3CategoryNamesProvider = Provider<List<String>>((ref) {
  final expenses = ref.watch(reportExpenseCategoryExpensesProvider);
  final categories = ref.watch(allCategoriesProvider).value ?? [];
  final isRu = ref.watch(localeProvider) == AppLanguage.russian;

  if (expenses.isEmpty) return [];

  final sorted = [...expenses]..sort((a, b) => b.total.compareTo(a.total));

  return sorted.take(3).map((expense) {
    final category = categories.firstWhereOrNull(
      (c) => c.id == expense.categoryId,
    );
    return category?.name ?? (isRu ? 'Неизвестно' : 'Unknown');
  }).toList();
});

final topCategoryPercentProvider = Provider<double?>((ref) {
  final expenses = ref.watch(reportExpenseCategoryExpensesProvider);
  if (expenses.isEmpty) return null;

  final total = expenses.fold<double>(0, (sum, e) => sum + e.total);
  final top = expenses.reduce((a, b) => a.total > b.total ? a : b);
  return total > 0 ? (top.total / total * 100).clamp(0, 100) : 0;
});

final recommendationsProvider = Provider<List<Recommendation>>((ref) {
  final transactions = ref.watch(reportTransactionsProvider);
  final previousTransactions = ref.watch(previousReportTransactionsProvider);
  final baselineTransactions = ref.watch(reportBaselineTransactionsProvider);
  final range = ref.watch(effectiveReportRangeProvider);
  final categories = ref.watch(allCategoriesProvider).value ?? [];
  final categoryExpenses = ref.watch(reportExpenseCategoryExpensesProvider);
  final isRu = ref.watch(localeProvider) == AppLanguage.russian;

  return AnalyticsCalculator.generateRecommendations(
    transactions,
    categoryExpenses,
    categories,
    previousTransactions: previousTransactions,
    baselineTransactions: baselineTransactions,
    currentPeriodDays: range.end.difference(range.start).inDays + 1,
    isRu: isRu,
  );
});
