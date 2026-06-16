// Файл: lib/features/analytics/domain/analytics_calculator.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

import 'package:collection/collection.dart';

import '../../../common/models/category_model.dart';
import '../../../common/models/recommendation_model.dart';
import '../../../common/models/transaction_model.dart';
import '../widgets/expenses_chart_placeholder.dart';
import 'analytics_models.dart';

class AnalyticsCalculator {
  static List<ChartPoint> expensesByDay(List<TransactionModel> transactions) {
    final map = <DateTime, double>{};

    for (final tx in transactions) {
      final key = DateTime(
        tx.createdAt.year,
        tx.createdAt.month,
        tx.createdAt.day,
      );
      map[key] = (map[key] ?? 0) + tx.amount;
    }

    final sortedKeys = map.keys.toList()..sort();
    return sortedKeys
        .map(
          (date) =>
              ChartPoint(label: '${date.day}.${date.month}', value: map[date]!),
        )
        .toList();
  }

  static List<ChartPoint> expensesByWeek(
    List<TransactionModel> transactions, {
    bool isRu = true,
  }) {
    final map = <String, double>{};
    final labelPrefix = isRu ? 'нед' : 'wk';

    for (final tx in transactions) {
      final week = ((tx.createdAt.day - 1) ~/ 7) + 1;
      final key = '${tx.createdAt.month}/$labelPrefix $week';
      map[key] = (map[key] ?? 0) + tx.amount;
    }

    return map.entries
        .map((entry) => ChartPoint(label: entry.key, value: entry.value))
        .toList();
  }

  static List<ChartPoint> expensesByMonth(List<TransactionModel> transactions) {
    final map = <String, double>{};

    for (final tx in transactions) {
      final key = '${tx.createdAt.month}.${tx.createdAt.year}';
      map[key] = (map[key] ?? 0) + tx.amount;
    }

    return map.entries
        .map((entry) => ChartPoint(label: entry.key, value: entry.value))
        .toList();
  }

  static List<CategoryExpenseData> expensesByCategory(
    List<TransactionModel> transactions,
  ) {
    final totals = <String, double>{};
    final counts = <String, int>{};

    for (final tx in transactions) {
      totals[tx.categoryId] = (totals[tx.categoryId] ?? 0) + tx.amount;
      counts[tx.categoryId] = (counts[tx.categoryId] ?? 0) + 1;
    }

    return totals.entries
        .map(
          (entry) => CategoryExpenseData(
            categoryId: entry.key,
            total: entry.value,
            transactionCount: counts[entry.key] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  static double averageValue(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static List<int> detectAnomalyIndexes(List<ChartPoint> points) {
    if (points.length < 4) return const [];
    final values = points.map((point) => point.value).toList();
    final average = averageValue(values);
    final variance =
        values
            .map((value) => (value - average) * (value - average))
            .reduce((a, b) => a + b) /
        values.length;
    final deviation = variance.sqrtSafe();
    if (deviation == 0) return const [];

    final anomalies = <int>[];
    for (var i = 0; i < values.length; i++) {
      if ((values[i] - average).abs() > deviation * 1.75) {
        anomalies.add(i);
      }
    }
    return anomalies;
  }

  static double totalIncome(
    List<TransactionModel> transactions, {
    DateTime? from,
    DateTime? to,
  }) {
    return transactions
        .where(
          (tx) =>
              !tx.isExpense &&
              (from == null || !tx.createdAt.isBefore(from)) &&
              (to == null || !tx.createdAt.isAfter(to)),
        )
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  static double totalExpense(
    List<TransactionModel> transactions, {
    DateTime? from,
    DateTime? to,
  }) {
    return transactions
        .where(
          (tx) =>
              tx.isExpense &&
              (from == null || !tx.createdAt.isBefore(from)) &&
              (to == null || !tx.createdAt.isAfter(to)),
        )
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  static List<Recommendation> generateRecommendations(
    List<TransactionModel> transactions,
    List<CategoryExpenseData> categoryExpenses,
    List<CategoryModel> categories, {
    List<TransactionModel> previousTransactions = const [],
    List<TransactionModel> baselineTransactions = const [],
    int currentPeriodDays = 30,
    DateTime? referenceDate,
    bool isRu = true,
  }) {
    final now = referenceDate ?? DateTime.now();
    final recommendations = <Recommendation>[];

    if (transactions.isEmpty) {
      return [
        Recommendation(
          id: 'empty_data',
          title: isRu ? 'Недостаточно данных' : 'Not enough data',
          description: isRu
              ? 'Добавьте операции для построения отчётов'
              : 'Add transactions to generate reports',
          type: RecommendationType.info,
          shownAt: now,
        ),
      ];
    }

    final income = totalIncome(transactions);
    final expense = totalExpense(transactions);
    final balance = income - expense;
    final previousExpense = totalExpense(previousTransactions);
    final previousIncome = totalIncome(previousTransactions);
    final historyTransactions = [
      ...baselineTransactions,
      ...previousTransactions,
      ...transactions,
    ];

    if (balance < 0) {
      recommendations.add(
        Recommendation(
          id: 'negative_balance',
          title: isRu
              ? 'Расходы превышают доходы на ${balance.abs().toStringAsFixed(0)}'
              : 'Expenses exceed income by ${balance.abs().toStringAsFixed(0)}',
          description: isRu
              ? 'Рекомендуется сократить необязательные расходы'
              : 'Consider reducing non-essential spending',
          type: RecommendationType.warning,
          priority: RecommendationPriority.high,
          shownAt: now,
        ),
      );
    }

    if (previousExpense > 0) {
      final expenseGrowth = (expense - previousExpense) / previousExpense;
      if (expenseGrowth > 0.2) {
        recommendations.add(
          Recommendation(
            id: 'expense_growth',
            title: isRu
                ? 'Расходы выросли на ${(expenseGrowth * 100).toStringAsFixed(0)}%'
                : 'Expenses increased by ${(expenseGrowth * 100).toStringAsFixed(0)}%',
            description: isRu
                ? 'Сравните крупные категории с прошлым периодом, чтобы найти источник роста'
                : 'Compare your largest categories with the previous period to find the source',
            type: RecommendationType.warning,
            priority: RecommendationPriority.high,
            shownAt: now,
          ),
        );
      }
    }

    if (previousIncome > 0) {
      final incomeChange = (income - previousIncome) / previousIncome;
      if (incomeChange < -0.15) {
        recommendations.add(
          Recommendation(
            id: 'income_drop',
            title: isRu
                ? 'Доходы снизились на ${(incomeChange.abs() * 100).toStringAsFixed(0)}%'
                : 'Income decreased by ${(incomeChange.abs() * 100).toStringAsFixed(0)}%',
            description: isRu
                ? 'Проверьте, все ли поступления внесены, и пересмотрите план расходов'
                : 'Check whether all income was recorded and revisit your spending plan',
            type: RecommendationType.info,
            priority: RecommendationPriority.medium,
            shownAt: now,
          ),
        );
      }
    }

    if (income > 0 && balance > income * 0.3) {
      recommendations.add(
        Recommendation(
          id: 'positive_balance',
          title: isRu
              ? 'Отличный финансовый баланс'
              : 'Strong financial balance',
          description: isRu
              ? 'Вы сохраняете ${(balance / income * 100).toStringAsFixed(0)}% дохода'
              : 'You are saving ${(balance / income * 100).toStringAsFixed(0)}% of your income',
          type: RecommendationType.success,
          priority: RecommendationPriority.low,
          shownAt: now,
        ),
      );
    }

    if (income > 0 && expense >= income * 0.9) {
      recommendations.add(
        Recommendation(
          id: 'high_budget_load',
          title: isRu ? 'Высокая нагрузка на бюджет' : 'High budget load',
          description: isRu
              ? 'Расходы превышают 90% доходов'
              : 'Expenses exceed 90% of income',
          type: RecommendationType.warning,
          priority: RecommendationPriority.high,
          shownAt: now,
        ),
      );
    }

    final forecast = _monthForecast(
      transactions,
      baselineTransactions,
      now: now,
    );
    if (forecast != null) {
      if (forecast.projectedBalance < 0) {
        recommendations.add(
          Recommendation(
            id: 'forecast_negative_month',
            title: isRu
                ? 'Месяц может уйти в минус'
                : 'This month may end negative',
            description: isRu
                ? 'При текущем темпе прогноз баланса: ${forecast.projectedBalance.toStringAsFixed(0)}'
                : 'At the current pace, projected balance is ${forecast.projectedBalance.toStringAsFixed(0)}',
            type: RecommendationType.warning,
            priority: RecommendationPriority.high,
            shownAt: now,
          ),
        );
      } else if (forecast.averageMonthlyExpense > 0 &&
          forecast.projectedExpense > forecast.averageMonthlyExpense * 1.2) {
        final growth =
            (forecast.projectedExpense - forecast.averageMonthlyExpense) /
            forecast.averageMonthlyExpense;
        recommendations.add(
          Recommendation(
            id: 'forecast_expense_over_norm',
            title: isRu
                ? 'Прогноз расходов выше нормы'
                : 'Expense forecast is above your norm',
            description: isRu
                ? 'К концу месяца расходы могут быть выше обычных на ${(growth * 100).toStringAsFixed(0)}%'
                : 'By month end, expenses may be ${(growth * 100).toStringAsFixed(0)}% above usual',
            type: RecommendationType.warning,
            priority: RecommendationPriority.high,
            shownAt: now,
          ),
        );
      }
    }

    final totalCategoryExpense = categoryExpenses.fold<double>(
      0,
      (sum, e) => sum + e.total,
    );
    final topCategory = categoryExpenses.firstOrNull;

    if (topCategory != null && totalCategoryExpense > 0) {
      final share = topCategory.total / totalCategoryExpense;
      if (share > 0.4) {
        final category = categories.firstWhereOrNull(
          (c) => c.id == topCategory.categoryId,
        );
        final categoryName =
            category?.name ?? (isRu ? 'Категория' : 'Category');

        recommendations.add(
          Recommendation(
            id: 'dominant_${topCategory.categoryId}',
            title: isRu
                ? 'Высокая доля расходов'
                : 'High spending concentration',
            description: isRu
                ? '$categoryName занимает ${(share * 100).toStringAsFixed(0)}% всех расходов'
                : '$categoryName accounts for ${(share * 100).toStringAsFixed(0)}% of all expenses',
            type: RecommendationType.tip,
            priority: RecommendationPriority.medium,
            shownAt: now,
          ),
        );
      }
    }

    if (categoryExpenses.length >= 3 && totalCategoryExpense > 0) {
      final top3Share =
          categoryExpenses.take(3).fold<double>(0, (sum, e) => sum + e.total) /
          totalCategoryExpense;
      if (top3Share > 0.7) {
        recommendations.add(
          Recommendation(
            id: 'top3_concentration',
            title: isRu
                ? 'Расходы сильно сконцентрированы'
                : 'Spending is highly concentrated',
            description: isRu
                ? 'Топ-3 категории занимают ${(top3Share * 100).toStringAsFixed(0)}% всех расходов'
                : 'Your top 3 categories make up ${(top3Share * 100).toStringAsFixed(0)}% of all expenses',
            type: RecommendationType.warning,
            priority: RecommendationPriority.high,
            shownAt: now,
          ),
        );
      }
    }

    final categoryBaseline = _categoryBaseline(
      baselineTransactions,
      currentPeriodDays: currentPeriodDays,
    );
    final categoryOutliers =
        categoryExpenses.where((expense) {
          final expected = categoryBaseline[expense.categoryId];
          return expected != null &&
              expected > 0 &&
              expense.total > expected * 1.25;
        }).toList()..sort((a, b) {
          final aExpected = categoryBaseline[a.categoryId] ?? 1;
          final bExpected = categoryBaseline[b.categoryId] ?? 1;
          return (b.total / bExpected).compareTo(a.total / aExpected);
        });

    final categoryOutlier = categoryOutliers.firstOrNull;
    if (categoryOutlier != null) {
      final expected = categoryBaseline[categoryOutlier.categoryId]!;
      final growth = (categoryOutlier.total - expected) / expected;
      final category = categories.firstWhereOrNull(
        (c) => c.id == categoryOutlier.categoryId,
      );
      final categoryName = category?.name ?? (isRu ? 'Категория' : 'Category');

      recommendations.add(
        Recommendation(
          id: 'category_above_norm_${categoryOutlier.categoryId}',
          title: isRu
              ? '$categoryName выше вашей нормы'
              : '$categoryName is above your norm',
          description: isRu
              ? 'Расходы выше обычного уровня на ${(growth * 100).toStringAsFixed(0)}%'
              : 'Spending is ${(growth * 100).toStringAsFixed(0)}% above your usual level',
          type: RecommendationType.tip,
          priority: RecommendationPriority.medium,
          shownAt: now,
        ),
      );
    }

    final largeTransaction = _largestTransactionAnomaly(
      transactions,
      historyTransactions,
    );
    if (largeTransaction != null) {
      final category = categories.firstWhereOrNull(
        (c) => c.id == largeTransaction.categoryId,
      );
      final categoryName = category?.name ?? (isRu ? 'Категория' : 'Category');
      recommendations.add(
        Recommendation(
          id: 'large_transaction_${largeTransaction.id}',
          title: isRu
              ? 'Необычно крупная операция'
              : 'Unusually large transaction',
          description: isRu
              ? '$categoryName: ${largeTransaction.amount.toStringAsFixed(0)} заметно выше обычной суммы'
              : '$categoryName: ${largeTransaction.amount.toStringAsFixed(0)} is well above the usual amount',
          type: RecommendationType.warning,
          priority: RecommendationPriority.high,
          shownAt: now,
        ),
      );
    }

    final growingCategory = _growingCategory(historyTransactions);
    if (growingCategory != null) {
      final category = categories.firstWhereOrNull(
        (c) => c.id == growingCategory.categoryId,
      );
      final categoryName = category?.name ?? (isRu ? 'Категория' : 'Category');
      recommendations.add(
        Recommendation(
          id: 'growing_category_${growingCategory.categoryId}',
          title: isRu
              ? '$categoryName растёт несколько месяцев'
              : '$categoryName has been rising for months',
          description: isRu
              ? 'За последние 3 месяца расходы выросли на ${(growingCategory.growth * 100).toStringAsFixed(0)}%'
              : 'Spending increased by ${(growingCategory.growth * 100).toStringAsFixed(0)}% over the last 3 months',
          type: RecommendationType.tip,
          priority: RecommendationPriority.medium,
          shownAt: now,
        ),
      );
    }

    final recurring = _recurringExpenseSummary(historyTransactions);
    if (recurring != null &&
        (recurring.groupCount >= 2 ||
            (income > 0 && recurring.monthlyTotal > income * 0.25))) {
      recommendations.add(
        Recommendation(
          id: 'recurring_expenses',
          title: isRu
              ? 'Найдены повторяющиеся расходы'
              : 'Recurring expenses detected',
          description: isRu
              ? '${recurring.groupCount} регулярных платежа примерно на ${recurring.monthlyTotal.toStringAsFixed(0)} в месяц'
              : '${recurring.groupCount} recurring payments total about ${recurring.monthlyTotal.toStringAsFixed(0)} per month',
          type: RecommendationType.info,
          priority: RecommendationPriority.medium,
          shownAt: now,
        ),
      );
    }

    if (income == 0 && expense > 0) {
      recommendations.add(
        Recommendation(
          id: 'no_income',
          title: isRu ? 'Доходы не обнаружены' : 'No income detected',
          description: isRu
              ? 'Проверьте, все ли поступления внесены'
              : 'Check whether all income transactions were recorded',
          type: RecommendationType.info,
          priority: RecommendationPriority.medium,
          shownAt: now,
        ),
      );
    }

    recommendations.sort(
      (a, b) => _priorityRank(a.priority).compareTo(_priorityRank(b.priority)),
    );
    return recommendations.take(5).toList();
  }

  static Map<String, double> _categoryBaseline(
    List<TransactionModel> transactions, {
    required int currentPeriodDays,
  }) {
    final expenseTransactions = transactions.where((tx) => tx.isExpense);
    if (expenseTransactions.isEmpty) return const {};

    final dates = expenseTransactions.map((tx) => tx.createdAt).toList()
      ..sort();
    final first = dates.first;
    final last = dates.last;
    final baselineDays = last.difference(first).inDays.abs() + 1;
    final scale = currentPeriodDays / baselineDays.clamp(1, 100000);
    final totals = expensesByCategory(expenseTransactions.toList());

    return {for (final item in totals) item.categoryId: item.total * scale};
  }

  static TransactionModel? _largestTransactionAnomaly(
    List<TransactionModel> currentTransactions,
    List<TransactionModel> historyTransactions,
  ) {
    final historicalExpenses = historyTransactions
        .where((tx) => tx.isExpense)
        .toList();
    final currentExpenses = currentTransactions.where((tx) => tx.isExpense);
    TransactionModel? result;
    var bestRatio = 0.0;

    for (final tx in currentExpenses) {
      final categoryAmounts =
          historicalExpenses
              .where((item) => item.categoryId == tx.categoryId)
              .map((item) => item.amount)
              .toList()
            ..sort();
      if (categoryAmounts.length < 4) continue;

      final median = _median(categoryAmounts);
      if (median <= 0) continue;

      final ratio = tx.amount / median;
      if (ratio >= 2.5 && tx.amount - median >= 1000 && ratio > bestRatio) {
        bestRatio = ratio;
        result = tx;
      }
    }

    return result;
  }

  static _GrowingCategory? _growingCategory(
    List<TransactionModel> transactions,
  ) {
    final monthly = <String, Map<String, double>>{};
    final monthStarts = <DateTime>{};

    for (final tx in transactions.where((tx) => tx.isExpense)) {
      final monthStart = DateTime(tx.createdAt.year, tx.createdAt.month);
      final monthKey = '${monthStart.year}-${monthStart.month}';
      monthStarts.add(monthStart);
      monthly.putIfAbsent(monthKey, () => {});
      final categoryTotals = monthly[monthKey]!;
      categoryTotals[tx.categoryId] =
          (categoryTotals[tx.categoryId] ?? 0) + tx.amount;
    }

    final sortedMonths = monthStarts.toList()..sort();
    if (sortedMonths.length < 3) return null;

    final lastMonths = sortedMonths.skip(sortedMonths.length - 3).toList();
    final categoryIds = <String>{
      for (final totals in monthly.values) ...totals.keys,
    };

    _GrowingCategory? best;
    for (final categoryId in categoryIds) {
      final values = lastMonths.map((month) {
        final key = '${month.year}-${month.month}';
        return monthly[key]?[categoryId] ?? 0;
      }).toList();
      if (values.first <= 0) continue;
      if (!(values[0] < values[1] && values[1] < values[2])) continue;

      final growth = (values[2] - values[0]) / values[0];
      if (growth < 0.25) continue;
      if (best == null || growth > best.growth) {
        best = _GrowingCategory(categoryId: categoryId, growth: growth);
      }
    }

    return best;
  }

  static _MonthForecast? _monthForecast(
    List<TransactionModel> transactions,
    List<TransactionModel> baselineTransactions, {
    required DateTime now,
  }) {
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final currentMonthTransactions = transactions.where((tx) {
      return !tx.createdAt.isBefore(monthStart) &&
          !tx.createdAt.isAfter(monthEnd);
    }).toList();
    if (currentMonthTransactions.isEmpty) return null;

    final elapsedDays = now.day.clamp(1, monthEnd.day);
    final daysInMonth = monthEnd.day;
    final currentExpense = totalExpense(currentMonthTransactions);
    final currentIncome = totalIncome(currentMonthTransactions);
    final projectedExpense = currentExpense / elapsedDays * daysInMonth;
    final projectedIncome = currentIncome / elapsedDays * daysInMonth;
    final averageMonthlyExpense = _averageMonthlyExpense(baselineTransactions);

    return _MonthForecast(
      projectedExpense: projectedExpense,
      projectedIncome: projectedIncome,
      projectedBalance: projectedIncome - projectedExpense,
      averageMonthlyExpense: averageMonthlyExpense,
    );
  }

  static double _averageMonthlyExpense(List<TransactionModel> transactions) {
    final monthlyTotals = <String, double>{};
    for (final tx in transactions.where((tx) => tx.isExpense)) {
      final key = '${tx.createdAt.year}-${tx.createdAt.month}';
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + tx.amount;
    }
    if (monthlyTotals.isEmpty) return 0;
    return averageValue(monthlyTotals.values.toList());
  }

  static _RecurringExpenseSummary? _recurringExpenseSummary(
    List<TransactionModel> transactions,
  ) {
    final groups = <String, List<TransactionModel>>{};
    for (final tx in transactions.where((tx) => tx.isExpense)) {
      final key = _recurringKey(tx);
      groups.putIfAbsent(key, () => []).add(tx);
    }

    var groupCount = 0;
    var monthlyTotal = 0.0;
    for (final group in groups.values) {
      if (group.length < 3) continue;
      group.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final intervals = <double>[];
      for (var i = 1; i < group.length; i++) {
        intervals.add(
          group[i].createdAt.difference(group[i - 1].createdAt).inDays.abs() +
              0.0,
        );
      }
      intervals.sort();
      final medianInterval = _median(intervals);
      if (medianInterval < 6 || medianInterval > 45) continue;

      final amounts = group.map((tx) => tx.amount).toList()..sort();
      final medianAmount = _median(amounts);
      if (medianAmount <= 0) continue;

      final hasStableAmounts = amounts.every(
        (amount) => (amount - medianAmount).abs() <= medianAmount * 0.2,
      );
      final hasStableDescription = _normalizedDescription(
        group.first,
      ).isNotEmpty;
      if (!hasStableAmounts && !hasStableDescription) continue;

      final monthlyMultiplier = medianInterval <= 10
          ? 4.33
          : medianInterval <= 20
          ? 2.16
          : 1.0;
      monthlyTotal += medianAmount * monthlyMultiplier;
      groupCount++;
    }

    if (groupCount == 0) return null;
    return _RecurringExpenseSummary(
      groupCount: groupCount,
      monthlyTotal: monthlyTotal,
    );
  }

  static String _recurringKey(TransactionModel tx) {
    final description = _normalizedDescription(tx);
    if (description.isNotEmpty) {
      return '${tx.categoryId}:$description';
    }
    final amountBucket = (tx.amount / 100).round() * 100;
    return '${tx.categoryId}:$amountBucket';
  }

  static String _normalizedDescription(TransactionModel tx) {
    return (tx.description ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static double _median(List<double> sortedValues) {
    final middle = sortedValues.length ~/ 2;
    if (sortedValues.length.isOdd) return sortedValues[middle];
    return (sortedValues[middle - 1] + sortedValues[middle]) / 2;
  }

  static int _priorityRank(RecommendationPriority priority) {
    return switch (priority) {
      RecommendationPriority.high => 0,
      RecommendationPriority.medium => 1,
      RecommendationPriority.low => 2,
    };
  }
}

class _GrowingCategory {
  const _GrowingCategory({required this.categoryId, required this.growth});

  final String categoryId;
  final double growth;
}

class _MonthForecast {
  const _MonthForecast({
    required this.projectedExpense,
    required this.projectedIncome,
    required this.projectedBalance,
    required this.averageMonthlyExpense,
  });

  final double projectedExpense;
  final double projectedIncome;
  final double projectedBalance;
  final double averageMonthlyExpense;
}

class _RecurringExpenseSummary {
  const _RecurringExpenseSummary({
    required this.groupCount,
    required this.monthlyTotal,
  });

  final int groupCount;
  final double monthlyTotal;
}

extension on double {
  double sqrtSafe() {
    if (this <= 0) return 0;
    var x = this;
    var root = x / 2;
    for (var i = 0; i < 12; i++) {
      root = 0.5 * (root + x / root);
    }
    return root;
  }
}
