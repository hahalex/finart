/// Мок-данные для экрана "Отчёты"
/// Позже будут приходить с backend

class MonthlyReport {
  final double averageIncome;
  final double averageExpense;
  final double averageBalance;
  final List<String> recommendations;

  const MonthlyReport({
    required this.averageIncome,
    required this.averageExpense,
    required this.averageBalance,
    required this.recommendations,
  });
}

/// Пример отчёта
const MonthlyReport mockMonthlyReport = MonthlyReport(
  averageIncome: 42000,
  averageExpense: 38500,
  averageBalance: 3500,
  recommendations: [
    'Расходы превышают доходы в некоторые месяцы.',
    'Вы тратите больше всего средств на категорию "Еда".',
    'Рекомендуется сократить необязательные расходы.',
  ],
);
