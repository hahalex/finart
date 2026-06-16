// Файл: lib/features/analytics/domain/analytics_models.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

class MonthlyExpenseData {
  final int year;
  final int month;
  final double total;

  const MonthlyExpenseData({
    required this.year,
    required this.month,
    required this.total,
  });
}

class CategoryExpenseData {
  final String categoryId;
  final double total;
  final int transactionCount;

  const CategoryExpenseData({
    required this.categoryId,
    required this.total,
    this.transactionCount = 0,
  });
}

class AnalyticsComparison {
  final double currentTotal;
  final double previousTotal;
  final double delta;
  final double deltaPercent;

  const AnalyticsComparison({
    required this.currentTotal,
    required this.previousTotal,
    required this.delta,
    required this.deltaPercent,
  });

  bool get isUp => delta > 0;
}

class ReportPeriodComparison {
  final double currentIncome;
  final double previousIncome;
  final double incomeDelta;
  final double incomeDeltaPercent;
  final double currentExpense;
  final double previousExpense;
  final double expenseDelta;
  final double expenseDeltaPercent;
  final double currentSavingsRate;
  final double previousSavingsRate;

  const ReportPeriodComparison({
    required this.currentIncome,
    required this.previousIncome,
    required this.incomeDelta,
    required this.incomeDeltaPercent,
    required this.currentExpense,
    required this.previousExpense,
    required this.expenseDelta,
    required this.expenseDeltaPercent,
    required this.currentSavingsRate,
    required this.previousSavingsRate,
  });
}
