import 'package:collection/collection.dart';

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
  // 🥧 ГРУППИРОВКА ПО КАТЕГОРИЯМ
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
  // 💰 TOTAL INCOME
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

  // ==========================================================================
  // 💸 TOTAL EXPENSE
  // ==========================================================================

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
  // 💡 PERSONAL RECOMMENDATIONS ENGINE
  // ==========================================================================

  static List<Recommendation> generateRecommendations(
    List<TransactionModel> transactions,
    List<CategoryExpenseData> categoryExpenses,
    List<CategoryModel> categories, {
    DateTime? from,
    DateTime? to,
  }) {
    final now = DateTime.now();
    final recommendations = <Recommendation>[];

    if (transactions.isEmpty) {
      return [
        Recommendation(
          id: 'empty_data',
          title: 'Недостаточно данных',
          description: 'Добавьте операции для построения отчётов',
          type: RecommendationType.info,
          shownAt: now,
        ),
      ];
    }

    final income = totalIncome(transactions, from: from, to: to);
    final expense = totalExpense(transactions, from: from, to: to);
    final balance = income - expense;

    // ==========================================================
    // 1. Отрицательный баланс
    // ==========================================================

    if (balance < 0) {
      recommendations.add(
        Recommendation(
          id: 'negative_balance',
          title:
              'Расходы превышают доходы на ${balance.abs().toStringAsFixed(0)} ₽',
          description: 'Рекомендуется сократить необязательные расходы',
          type: RecommendationType.warning,
          shownAt: now,
        ),
      );
    }

    // ==========================================================
    // 2. Хороший профицит
    // ==========================================================

    if (income > 0 && balance > income * 0.3) {
      recommendations.add(
        Recommendation(
          id: 'positive_balance',
          title: 'Отличный финансовый баланс',
          description:
              'Вы сохраняете ${(balance / income * 100).toStringAsFixed(0)}% дохода',
          type: RecommendationType.success,
          shownAt: now,
        ),
      );
    }

    // ==========================================================
    // 3. Бюджетная нагрузка >90%
    // ==========================================================

    if (income > 0 && expense >= income * 0.9) {
      recommendations.add(
        Recommendation(
          id: 'high_budget_load',
          title: 'Высокая нагрузка на бюджет',
          description: 'Расходы превышают 90% доходов',
          type: RecommendationType.warning,
          shownAt: now,
        ),
      );
    }

    // ==========================================================
    // 4. Доминирующая категория
    // ==========================================================

    final totalCategoryExpense = categoryExpenses.fold<double>(
      0,
      (sum, e) => sum + e.total,
    );

    for (final categoryExpense in categoryExpenses) {
      if (totalCategoryExpense == 0) continue;

      final share = categoryExpense.total / totalCategoryExpense;

      if (share > 0.4) {
        final category = categories.firstWhereOrNull(
          (c) => c.id == categoryExpense.categoryId,
        );

        recommendations.add(
          Recommendation(
            id: 'dominant_${categoryExpense.categoryId}',
            title: 'Высокая доля расходов',
            description:
                '${category?.name ?? "Категория"} занимает ${(share * 100).toStringAsFixed(0)}% бюджета',
            type: RecommendationType.tip,
            shownAt: now,
          ),
        );
      }
    }

    // ==========================================================
    // 5. Нет доходов
    // ==========================================================

    if (income == 0 && expense > 0) {
      recommendations.add(
        Recommendation(
          id: 'no_income',
          title: 'Доходы не обнаружены',
          description: 'Проверьте, все ли поступления внесены',
          type: RecommendationType.info,
          shownAt: now,
        ),
      );
    }

    return recommendations.take(5).toList();
  }
}
