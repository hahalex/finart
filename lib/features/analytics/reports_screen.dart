import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/categories_provider.dart';
import '../analytics/providers/analytics_provider.dart';
import 'widgets/report_stat_card.dart';
import 'widgets/recommendation_tile.dart';

/// Экран "Отчёты"
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final categories = categoriesAsync.value ?? [];

    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final balance = ref.watch(balanceProvider);

    final recommendations = ref.watch(recommendationsProvider);

    final topCategory = ref.watch(topCategoryNameProvider);
    final topCategoryPercent = ref.watch(topCategoryPercentProvider);
    final top3Categories = ref.watch(top3CategoryNamesProvider);

    final selectedPeriod = ref.watch(selectedReportPeriodProvider);

    final savingsRate = totalIncome > 0
        ? ((balance / totalIncome) * 100).clamp(-999, 999)
        : 0.0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================================
          // HEADER
          // ==========================================================
          Text(
            'Финансовый отчёт',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            'Анализ текущего периода',
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 16),

          // ==========================================================
          // PERIOD SELECTOR
          // ==========================================================
          _PeriodSelector(),

          const SizedBox(height: 20),

          // ==========================================================
          // MAIN KPI
          // ==========================================================
          Row(
            children: [
              ReportStatCard(title: 'Доходы', value: totalIncome),
              ReportStatCard(title: 'Расходы', value: totalExpense),
              ReportStatCard(title: 'Баланс', value: balance),
            ],
          ),

          const SizedBox(height: 20),

          // ==========================================================
          // SAVINGS RATE
          // ==========================================================
          _InfoCard(
            title: 'Норма сбережений',
            child: Row(
              children: [
                const Icon(Icons.savings_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Доля сохранённых средств',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${savingsRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: savingsRate >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ==========================================================
          // TOP CATEGORY
          // ==========================================================
          if (topCategory != null)
            _InfoCard(
              title: 'Топ категория расходов',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topCategory,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (topCategoryPercent != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${topCategoryPercent.toStringAsFixed(0)}% от всех расходов',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: 20),

          // ==========================================================
          // TOP 3
          // ==========================================================
          if (top3Categories.isNotEmpty)
            _InfoCard(
              title: 'Топ 3 категории',
              child: Column(
                children: top3Categories.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key + 1}.',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 24),

          // ==========================================================
          // RECOMMENDATIONS
          // ==========================================================
          Text(
            'Персональные рекомендации',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          if (recommendations.isEmpty)
            _InfoCard(
              title: 'Нет рекомендаций',
              child: const Text(
                'Система пока не выявила значимых финансовых паттернов',
              ),
            )
          else
            ...recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecommendationTile(recommendation: rec),
              ),
            ),

          // ==========================================================
          // LOADING
          // ==========================================================
          if (categoriesAsync.isLoading && categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// 📅 PERIOD SELECTOR WIDGET
// ============================================================================

class _PeriodSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedReportPeriodProvider);

    void select(ReportPeriod period) {
      ref.read(selectedReportPeriodProvider.notifier).state = period;
    }

    Future<void> pickCustomRange() async {
      final now = DateTime.now();

      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 5),
        lastDate: now,
      );

      if (picked != null) {
        ref.read(selectedDateRangeProvider.notifier).state = picked;
        ref.read(selectedReportPeriodProvider.notifier).state =
            ReportPeriod.custom;
      }
    }

    Widget button(String label, ReportPeriod period) {
      final isSelected = selected == period;

      return GestureDetector(
        onTap: () => select(period),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          button('Год', ReportPeriod.year),
          const SizedBox(width: 8),
          button('6 мес', ReportPeriod.halfYear),
          const SizedBox(width: 8),
          button('Квартал', ReportPeriod.quarter),
          const SizedBox(width: 8),
          button('Месяц', ReportPeriod.currentMonth),
          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: pickCustomRange,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🧩 INFO CARD
// ============================================================================

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
