import '../../../common/models/transaction_model.dart';
import '../../../common/models/category_model.dart';
import '../../../common/models/recommendation_model.dart';
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

  static List<MonthlyExpenseData> expensesByMonthFiltered(
    List<TransactionModel> transactions, {
    DateTime? from,
    DateTime? to,
  }) {
    final filtered = transactions.where((tx) {
      if (!tx.isExpense) return false;
      if (from != null && tx.createdAt.isBefore(from)) return false;
      if (to != null && tx.createdAt.isAfter(to)) return false;
      return true;
    }).toList();

    return expensesByMonth(filtered);
  }

  static List<CategoryExpenseData> expensesByCategoryFiltered(
    List<TransactionModel> transactions, {
    DateTime? from,
    DateTime? to,
  }) {
    final filtered = transactions.where((tx) {
      if (!tx.isExpense) return false;
      if (from != null && tx.createdAt.isBefore(from)) return false;
      if (to != null && tx.createdAt.isAfter(to)) return false;
      return true;
    }).toList();

    return expensesByCategory(filtered);
  }

  /// Расходы и доходы за период
  static double totalIncome(
    List<TransactionModel> transactions, {
    DateTime? from,
    DateTime? to,
  }) {
    return transactions
        .where(
          (tx) =>
              !tx.isExpense &&
              (from == null ||
                  tx.createdAt.isAfter(
                    from.subtract(const Duration(seconds: 1)),
                  )) &&
              (to == null ||
                  tx.createdAt.isBefore(to.add(const Duration(seconds: 1)))),
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
              (from == null ||
                  tx.createdAt.isAfter(
                    from.subtract(const Duration(seconds: 1)),
                  )) &&
              (to == null ||
                  tx.createdAt.isBefore(to.add(const Duration(seconds: 1)))),
        )
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Находит категорию с наибольшими расходами
  static String? topExpenseCategory(
    List<CategoryExpenseData> expenses,
    Map<String, String> categoryNames,
  ) {
    if (expenses.isEmpty) return null;

    final top = expenses.reduce((a, b) => a.total > b.total ? a : b);
    return categoryNames[top.categoryId];
  }

  /// Генерация рекомендаций
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

      recommendations.add(
        const Recommendation(
          title: 'Рекомендуется сократить необязательные расходы',
          type: RecommendationType.tip,
        ),
      );
    } else if (diff.abs() <= 1000) {
      recommendations.add(
        const Recommendation(
          title: 'Доходы и расходы находятся в балансе',
          type: RecommendationType.info,
        ),
      );
    } else {
      recommendations.add(
        Recommendation(
          title: 'Доходы превышают расходы на ${diff.toStringAsFixed(0)} ₽',
          type: RecommendationType.success,
        ),
      );

      recommendations.add(
        const Recommendation(
          title: 'Рекомендуется откладывать накопления',
          type: RecommendationType.tip,
        ),
      );
    }

    final categoryNames = {for (final c in categories) c.id: c.name};

    final topCategory = topExpenseCategory(categoryExpenses, categoryNames);
    if (topCategory != null) {
      recommendations.add(
        Recommendation(
          title: 'Наибольшие расходы',
          description: 'Категория "$topCategory"',
          type: RecommendationType.info,
        ),
      );
    }

    return recommendations;
  }
}
