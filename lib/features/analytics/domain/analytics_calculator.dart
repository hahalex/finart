import '../../../common/models/transaction_model.dart';
import '../../../common/models/category_model.dart';
import '../../../common/models/recommendation_model.dart';
import '../widgets/expenses_chart_placeholder.dart';
import 'analytics_models.dart';

class AnalyticsCalculator {
  // ==========================================================================
  // 📊 ГРУППИРОВКА ПО ДНЯМ
  // ==========================================================================

  static List<ChartPoint> expensesByDay(List<TransactionModel> transactions) {
    final Map<DateTime, double> map = {};

    for (final tx in transactions) {
      final key = DateTime(
        tx.createdAt.year,
        tx.createdAt.month,
        tx.createdAt.day,
      );

      map[key] = (map[key] ?? 0) + tx.amount;
    }

    final sortedKeys = map.keys.toList()..sort();

    return sortedKeys.map((date) {
      return ChartPoint(label: '${date.day}.${date.month}', value: map[date]!);
    }).toList();
  }

  // ==========================================================================
  // 📊 ГРУППИРОВКА ПО НЕДЕЛЯМ
  // ==========================================================================

  static List<ChartPoint> expensesByWeek(List<TransactionModel> transactions) {
    final Map<String, double> map = {};

    for (final tx in transactions) {
      final week = ((tx.createdAt.day - 1) ~/ 7) + 1;
      final key = '${tx.createdAt.month}/нед $week';

      map[key] = (map[key] ?? 0) + tx.amount;
    }

    return map.entries.map((entry) {
      return ChartPoint(label: entry.key, value: entry.value);
    }).toList();
  }

  // ==========================================================================
  // 📊 ГРУППИРОВКА ПО МЕСЯЦАМ
  // ==========================================================================

  static List<ChartPoint> expensesByMonth(List<TransactionModel> transactions) {
    final Map<String, double> map = {};

    for (final tx in transactions) {
      final key = '${tx.createdAt.month}.${tx.createdAt.year}';

      map[key] = (map[key] ?? 0) + tx.amount;
    }

    return map.entries.map((entry) {
      return ChartPoint(label: entry.key, value: entry.value);
    }).toList();
  }

  // ==========================================================================
  // 🥧 ПО КАТЕГОРИЯМ
  // ==========================================================================

  static List<CategoryExpenseData> expensesByCategory(
    List<TransactionModel> transactions,
  ) {
    final Map<String, double> map = {};

    for (final tx in transactions) {
      map[tx.categoryId] = (map[tx.categoryId] ?? 0) + tx.amount;
    }

    return map.entries.map((entry) {
      return CategoryExpenseData(categoryId: entry.key, total: entry.value);
    }).toList()..sort((a, b) => b.total.compareTo(a.total));
  }

  // ==========================================================================
  // 💰 TOTALS
  // ==========================================================================

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

  // ==========================================================================
  // 🏆 TOP CATEGORY
  // ==========================================================================

  static String? topExpenseCategory(
    List<CategoryExpenseData> expenses,
    Map<String, String> categoryNames,
  ) {
    if (expenses.isEmpty) return null;

    final top = expenses.reduce((a, b) => a.total > b.total ? a : b);

    return categoryNames[top.categoryId];
  }

  // ==========================================================================
  // 💡 RECOMMENDATIONS
  // ==========================================================================

  static List<Recommendation> generateRecommendations(
    List<TransactionModel> transactions,
    List<CategoryExpenseData> categoryExpenses,
    List<CategoryModel> categories, {
    DateTime? from,
    DateTime? to,
  }) {
    final income = totalIncome(transactions, from: from, to: to);

    final expense = totalExpense(transactions, from: from, to: to);

    final recommendations = <Recommendation>[];

    final diff = income - expense;

    if (diff < -1000) {
      recommendations.add(
        Recommendation(
          title: 'Расходы превышают доходы на ${(-diff).toStringAsFixed(0)} ₽',
          type: RecommendationType.warning,
        ),
      );
    } else if (diff > 1000) {
      recommendations.add(
        Recommendation(
          title: 'Доходы превышают расходы на ${diff.toStringAsFixed(0)} ₽',
          type: RecommendationType.success,
        ),
      );
    }

    return recommendations;
  }
}
