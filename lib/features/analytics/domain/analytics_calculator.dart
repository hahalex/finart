import '../../../common/models/transaction_model.dart';
import 'analytics_models.dart';

class AnalyticsCalculator {
  /// Расходы по месяцам
  static List<MonthlyExpenseData> expensesByMonth(
    List<TransactionModel> transactions,
  ) {
    final Map<(int year, int month), double> map = {};

    for (final tx in transactions) {
      if (!tx.isExpense) continue;

      final key = (tx.createdAt.year, tx.createdAt.month);
      map[key] = (map[key] ?? 0) + tx.amount;
    }

    return map.entries.map((entry) {
      return MonthlyExpenseData(
        year: entry.key.$1,
        month: entry.key.$2,
        total: entry.value,
      );
    }).toList()..sort(
      (a, b) => (a.year * 12 + a.month).compareTo(b.year * 12 + b.month),
    );
  }

  /// Расходы по категориям
  static List<CategoryExpenseData> expensesByCategory(
    List<TransactionModel> transactions,
  ) {
    final Map<String, double> map = {};

    for (final tx in transactions) {
      if (!tx.isExpense) continue;

      map[tx.categoryId] = (map[tx.categoryId] ?? 0) + tx.amount;
    }

    return map.entries.map((entry) {
      return CategoryExpenseData(categoryId: entry.key, total: entry.value);
    }).toList()..sort((a, b) => b.total.compareTo(a.total));
  }
}
