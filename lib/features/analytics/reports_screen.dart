// Файл: lib/features/analytics/reports_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/localization/app_strings.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/utils/app_theme.dart';
import '../analytics/providers/analytics_provider.dart';
import 'widgets/recommendation_tile.dart';
import 'widgets/report_stat_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final balanceColor = AppTheme.balanceAccentOf(context);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final categories = categoriesAsync.value ?? [];

    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final balance = ref.watch(balanceProvider);
    final recommendations = ref.watch(recommendationsProvider);
    final topCategory = ref.watch(topCategoryNameProvider);
    final topCategoryPercent = ref.watch(topCategoryPercentProvider);
    final top3Categories = ref.watch(top3CategoryNamesProvider);
    final periodComparison = ref.watch(reportPeriodComparisonProvider);

    final savingsRate = totalIncome > 0
        ? ((balance / totalIncome) * 100).clamp(-999, 999)
        : 0.0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            strings.isRu ? 'Финансовый отчёт' : 'Financial report',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            strings.isRu
                ? 'Анализ текущего периода'
                : 'Analysis for the current period',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mutedTextOf(context),
            ),
          ),
          const SizedBox(height: 16),
          const _PeriodSelector(),
          const SizedBox(height: 20),
          Row(
            children: [
              // Три верхние карточки отчета повторяют логику экрана "Записи":
              // доходы, расходы и итоговый баланс выбранного периода.
              ReportStatCard(
                title: strings.isRu ? 'Доходы' : 'Income',
                value: totalIncome,
                color: colors.income,
                icon: Icons.arrow_downward_rounded,
              ),
              ReportStatCard(
                title: strings.isRu ? 'Баланс' : 'Balance',
                value: balance,
                color: balanceColor,
                icon: Icons.account_balance_wallet_outlined,
              ),
              ReportStatCard(
                title: strings.isRu ? 'Расходы' : 'Expenses',
                value: totalExpense,
                color: colors.expense,
                icon: Icons.arrow_upward_rounded,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoCard(
            // Карточка нормы сбережений показывает, какая доля дохода
            // остается после расходов.
            title: strings.isRu ? 'Норма сбережений' : 'Savings rate',
            child: Row(
              children: [
                const Icon(Icons.savings_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.isRu
                        ? 'Доля сохранённых средств'
                        : 'Share of income kept as savings',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${savingsRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: savingsRate >= 0 ? colors.income : colors.expense,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (periodComparison != null) ...[
            _InfoCard(
              title: strings.isRu ? 'Что изменилось' : 'What changed',
              child: Column(
                children: [
                  _DeltaRow(
                    label: strings.isRu ? 'Доходы' : 'Income',
                    delta: periodComparison.incomeDelta,
                    deltaPercent: periodComparison.incomeDeltaPercent,
                    positiveIsGood: true,
                  ),
                  const SizedBox(height: 10),
                  _DeltaRow(
                    label: strings.isRu ? 'Расходы' : 'Expenses',
                    delta: periodComparison.expenseDelta,
                    deltaPercent: periodComparison.expenseDeltaPercent,
                    positiveIsGood: false,
                  ),
                  const SizedBox(height: 10),
                  _DeltaRow(
                    label: strings.isRu ? 'Норма сбережений' : 'Savings rate',
                    delta:
                        periodComparison.currentSavingsRate -
                        periodComparison.previousSavingsRate,
                    deltaPercent: null,
                    positiveIsGood: true,
                    suffix: strings.isRu ? ' п.п.' : ' pp',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (topCategory != null)
            _InfoCard(
              // Самая крупная категория помогает быстро найти главный источник
              // расходов периода.
              title: strings.isRu
                  ? 'Топ категория расходов'
                  : 'Top expense category',
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
                      strings.isRu
                          ? '${topCategoryPercent.toStringAsFixed(0)}% от всех расходов'
                          : '${topCategoryPercent.toStringAsFixed(0)}% of all expenses',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedTextOf(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 20),
          if (top3Categories.isNotEmpty)
            _InfoCard(
              // Топ-3 категорий выводится списком без диаграммы, чтобы отчет
              // оставался компактным.
              title: strings.isRu
                  ? 'Топ 3 категории расходов'
                  : 'Top 3 expense categories',
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
          Text(
            strings.isRu
                ? 'Персональные рекомендации'
                : 'Personal recommendations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (recommendations.isEmpty)
            _InfoCard(
              title: strings.isRu ? 'Нет рекомендаций' : 'No recommendations',
              child: Text(
                strings.isRu
                    ? 'Система пока не выявила значимых финансовых паттернов'
                    : 'No significant financial patterns were detected yet',
              ),
            )
          else
            ...recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecommendationTile(recommendation: rec),
              ),
            ),
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

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({
    required this.label,
    required this.delta,
    required this.positiveIsGood,
    this.deltaPercent,
    this.suffix,
  });

  final String label;
  final double delta;
  final double? deltaPercent;
  final bool positiveIsGood;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isPositive = delta >= 0;
    final isGood = isPositive == positiveIsGood;
    final color = isGood ? colors.income : colors.expense;
    final icon = isPositive
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final sign = isPositive ? '+' : '';
    final percentText = deltaPercent == null
        ? ''
        : ' ($sign${deltaPercent!.toStringAsFixed(0)}%)';

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          '$sign${delta.toStringAsFixed(0)}${suffix ?? ''}$percentText',
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final selected = ref.watch(selectedReportPeriodProvider);

    void select(ReportPeriod period) {
      ref.read(selectedReportPeriodProvider.notifier).state = period;
      if (period != ReportPeriod.custom) {
        ref.read(reportDateRangeProvider.notifier).state = null;
      }
    }

    Future<void> pickCustomRange() async {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        // Иконка календаря справа открывает произвольный диапазон отчета.
        context: context,
        firstDate: DateTime(now.year - 5),
        lastDate: now,
      );

      if (picked != null) {
        ref.read(reportDateRangeProvider.notifier).state = picked;
        ref.read(selectedReportPeriodProvider.notifier).state =
            ReportPeriod.custom;
      }
    }

    Widget button(String label, ReportPeriod period) {
      final isSelected = selected == period;

      return GestureDetector(
        onTap: () => select(period),
        child: Container(
          // Кнопка периода: выбранная получает легкую primary-заливку,
          // остальные остаются прозрачными с рамкой.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: isSelected
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.22)
                  : AppTheme.colorsOf(context).border,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.mutedTextOf(context),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          button(strings.isRu ? 'Год' : 'Year', ReportPeriod.year),
          const SizedBox(width: 8),
          button(strings.isRu ? '6 мес' : '6 mo', ReportPeriod.halfYear),
          const SizedBox(width: 8),
          button(strings.isRu ? 'Квартал' : 'Quarter', ReportPeriod.quarter),
          const SizedBox(width: 8),
          button(strings.isRu ? 'Месяц' : 'Month', ReportPeriod.currentMonth),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Универсальная карточка отчета: поверхность, радиус, рамка и тень
      // централизованы в AppTheme.surfaceCardDecoration.
      padding: const EdgeInsets.all(AppTheme.pagePadding),
      decoration: AppTheme.surfaceCardDecoration(
        context,
        radius: AppTheme.radiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppTheme.itemGap),
          child,
        ],
      ),
    );
  }
}
