import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/providers/analytics_provider.dart';
import '../transactions/providers/categories_provider.dart';
import 'widgets/report_stat_card.dart';
import 'widgets/recommendation_tile.dart';
import '../transactions/providers/transactions_notifier.dart';
import 'domain/analytics_calculator.dart';

/// Экран "Отчёты"
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categoryExpenses = ref.watch(categoryExpensesFilteredProvider);
    final categories = ref.watch(categoriesProvider);

    final totalIncome = AnalyticsCalculator.totalIncome(transactions);
    final totalExpense = AnalyticsCalculator.totalExpense(transactions);
    final balance = totalIncome - totalExpense;

    final recommendations = AnalyticsCalculator.generateRecommendations(
      transactions,
      categoryExpenses,
      categories,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Отчёт за месяц', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Row(
            children: [
              ReportStatCard(title: 'Доходы', value: totalIncome),
              ReportStatCard(title: 'Расходы', value: totalExpense),
              ReportStatCard(title: 'Баланс', value: balance),
            ],
          ),

          const SizedBox(height: 24),

          Text('Рекомендации', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          ...recommendations.map(
            (rec) => RecommendationTile(recommendation: rec),
          ),
        ],
      ),
    );
  }
}
