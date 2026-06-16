// Файл: lib/features/profile/dev_menu_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/localization/app_strings.dart';
import '../../common/providers/notification_service_provider.dart';
import '../../common/providers/notification_settings_provider.dart';
import '../../common/providers/planned_payments_provider.dart';
import '../../common/providers/planned_repository_provider.dart';
import '../../common/utils/app_theme.dart';
import '../../features/transactions/providers/transactions_notifier.dart';
import 'dev_data_service.dart';

class DevMenuScreen extends ConsumerStatefulWidget {
  const DevMenuScreen({super.key});

  @override
  ConsumerState<DevMenuScreen> createState() => _DevMenuScreenState();
}

class _DevMenuScreenState extends ConsumerState<DevMenuScreen> {
  String? _busyAction;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);

    // Карточки сценариев seed-данных. Каждый сценарий наполняет приложение
    // разным набором транзакций, платежей и счетов для демонстрации.
    final scenarios = [
      _DevScenario(
        id: 'small',
        title: strings.devScenarioSmallSet,
        subtitle: strings.devScenarioSmallSetSubtitle,
        icon: Icons.auto_graph_outlined,
        accent: colors.primary,
        scenario: DevSeedScenario.smallSet,
      ),
      _DevScenario(
        id: 'large',
        title: strings.devScenarioLargeSet,
        subtitle: strings.devScenarioLargeSetSubtitle,
        icon: Icons.stacked_line_chart_rounded,
        accent: colors.income,
        scenario: DevSeedScenario.largeSet,
      ),
      _DevScenario(
        id: 'skewed',
        title: strings.devScenarioSkewed,
        subtitle: strings.devScenarioSkewedSubtitle,
        icon: Icons.pie_chart_outline_rounded,
        accent: colors.expense,
        scenario: DevSeedScenario.skewedCategories,
      ),
      _DevScenario(
        id: 'planned',
        title: strings.devScenarioPlanned,
        subtitle: strings.devScenarioPlannedSubtitle,
        icon: Icons.event_repeat_outlined,
        accent: colors.secondary,
        scenario: DevSeedScenario.manyPlannedPayments,
      ),
      _DevScenario(
        id: 'mixed',
        title: strings.devScenarioMixed,
        subtitle: strings.devScenarioMixedSubtitle,
        icon: Icons.dataset_linked_outlined,
        accent: _chartAccent(context),
        scenario: DevSeedScenario.mixedScenario,
      ),
      _DevScenario(
        id: 'mini_forecast',
        title: strings.devScenarioMiniForecast,
        subtitle: strings.devScenarioMiniForecastSubtitle,
        icon: Icons.trending_up_rounded,
        accent: colors.expense,
        scenario: DevSeedScenario.miniForecast,
      ),
      _DevScenario(
        id: 'mini_recurring',
        title: strings.devScenarioMiniRecurring,
        subtitle: strings.devScenarioMiniRecurringSubtitle,
        icon: Icons.repeat_rounded,
        accent: colors.secondary,
        scenario: DevSeedScenario.miniRecurring,
      ),
      _DevScenario(
        id: 'mini_trend',
        title: strings.devScenarioMiniTrend,
        subtitle: strings.devScenarioMiniTrendSubtitle,
        icon: Icons.show_chart_rounded,
        accent: _chartAccent(context),
        scenario: DevSeedScenario.miniTrend,
      ),
      _DevScenario(
        id: 'mini_large_tx',
        title: strings.devScenarioMiniLargeTransaction,
        subtitle: strings.devScenarioMiniLargeTransactionSubtitle,
        icon: Icons.priority_high_rounded,
        accent: colors.expense,
        scenario: DevSeedScenario.miniLargeTransaction,
      ),
      _DevScenario(
        id: 'mini_concentration',
        title: strings.devScenarioMiniConcentration,
        subtitle: strings.devScenarioMiniConcentrationSubtitle,
        icon: Icons.donut_large_rounded,
        accent: colors.primary,
        scenario: DevSeedScenario.miniConcentration,
      ),
      _DevScenario(
        id: 'mini_history',
        title: strings.devScenarioMiniHistory,
        subtitle: strings.devScenarioMiniHistorySubtitle,
        icon: Icons.manage_search_rounded,
        accent: colors.income,
        scenario: DevSeedScenario.miniHistoryAnalyzer,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.devMenu)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            // Верхняя информационная плашка объясняет назначение dev-меню.
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: colors.surfaceSoft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.devMenu,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.devMenuDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            strings.devMenuSeedSection,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...scenarios.map(
            (scenario) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScenarioCard(
                // Нажатие на карточку сценария сначала показывает подтверждение,
                // затем запускает генерацию данных.
                scenario: scenario,
                isBusy: _busyAction == scenario.id,
                onRun: () => _confirmAndRunScenario(scenario),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            strings.devMenuDangerSection,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _DangerCard(
            // Опасная кнопка очищает тестовые данные.
            title: strings.devActionClearDatabase,
            subtitle: strings.devActionClearDatabaseSubtitle,
            isBusy: _busyAction == 'clear',
            onTap: _confirmAndClearDatabase,
          ),
          const SizedBox(height: 12),
          _DangerCard(
            // Опасная кнопка пересоздает небольшой demo-набор с нуля.
            title: strings.devActionResetDemoData,
            subtitle: strings.devActionResetDemoDataSubtitle,
            isBusy: _busyAction == 'reset',
            onTap: _confirmAndResetDemoData,
          ),
        ],
      ),
    );
  }

  Color _chartAccent(BuildContext context) {
    final palette = AppTheme.analyticsChartPaletteOf(context);
    return palette.length > 1 ? palette[1] : AppTheme.colorsOf(context).primary;
  }

  Future<void> _confirmAndRunScenario(_DevScenario scenario) async {
    final strings = AppStrings.of(context);
    final confirmed = await _confirmAction(
      title: scenario.title,
      message: strings.devActionSeedConfirm,
    );
    if (!confirmed) return;

    await _runBusyAction(scenario.id, () async {
      final categories = await ref.read(devSeedCategoriesProvider.future);
      final result = await ref
          .read(devDataServiceProvider)
          .seedScenario(scenario: scenario.scenario, categories: categories);
      await _refreshAppState();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.devSeedCompleted(
              result.transactionsCreated,
              result.plannedPaymentsCreated,
              result.accountsCreated,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _confirmAndClearDatabase() async {
    final strings = AppStrings.of(context);
    final confirmed = await _confirmAction(
      title: strings.devActionClearDatabase,
      message: strings.devActionClearConfirm,
    );
    if (!confirmed) return;

    await _runBusyAction('clear', () async {
      await ref.read(devDataServiceProvider).clearGeneratedData();
      await _refreshAppState();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.devClearCompleted)));
    });
  }

  Future<void> _confirmAndResetDemoData() async {
    final strings = AppStrings.of(context);
    final confirmed = await _confirmAction(
      title: strings.devActionResetDemoData,
      message: strings.devActionResetConfirm,
    );
    if (!confirmed) return;

    await _runBusyAction('reset', () async {
      final categories = await ref.read(devSeedCategoriesProvider.future);
      final result = await ref
          .read(devDataServiceProvider)
          .resetAndSeed(
            scenario: DevSeedScenario.smallSet,
            categories: categories,
          );
      await _refreshAppState();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.devSeedCompleted(
              result.transactionsCreated,
              result.plannedPaymentsCreated,
              result.accountsCreated,
            ),
          ),
        ),
      );
    });
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
  }) async {
    final strings = AppStrings.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(strings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(strings.devMenuRunAction),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> _runBusyAction(
    String actionId,
    Future<void> Function() action,
  ) async {
    setState(() => _busyAction = actionId);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _busyAction = null);
      }
    }
  }

  Future<void> _refreshAppState() async {
    ref.invalidate(plannedPaymentsProvider);
    await ref.read(transactionsProvider.notifier).reload();

    final settings = ref.read(notificationSettingsProvider);
    final plannedPayments = await ref
        .read(plannedRepositoryProvider)
        .getAllPlannedPayments();
    await ref
        .read(notificationServiceProvider)
        .syncAll(
          settings: settings,
          plannedPayments: plannedPayments.where((p) => p.isActive).toList(),
        );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.isBusy,
    required this.onRun,
  });

  final _DevScenario scenario;
  final bool isBusy;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scenario.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(scenario.icon, color: scenario.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scenario.subtitle,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: isBusy ? null : onRun,
            child: isBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppStrings.of(context).devMenuRunAction),
          ),
        ],
      ),
    );
  }
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({
    required this.title,
    required this.subtitle,
    required this.isBusy,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final danger = AppTheme.colorsOf(context).expense;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: danger.withValues(alpha: 0.08),
        border: Border.all(color: danger.withValues(alpha: 0.25)),
      ),
      child: ListTile(
        leading: isBusy
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: danger),
              )
            : Icon(Icons.warning_amber_rounded, color: danger),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, color: danger),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: isBusy ? null : onTap,
      ),
    );
  }
}

class _DevScenario {
  const _DevScenario({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.scenario,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final DevSeedScenario scenario;
}
