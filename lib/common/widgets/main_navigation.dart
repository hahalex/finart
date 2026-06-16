// Файл: lib/common/widgets/main_navigation.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytics/charts_screen.dart';
import '../../features/analytics/reports_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/transactions/add_transaction_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../localization/app_strings.dart';
import '../providers/navigation_provider.dart';
import '../utils/app_theme.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  // Порядок экранов должен совпадать с порядком кнопок в нижнем меню:
  // Записи -> Графики -> Добавить -> Отчеты -> Профиль.
  static const List<Widget> _screens = [
    TransactionsScreen(),
    ChartsScreen(),
    AddTransactionScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(bottomNavIndexProvider),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    final currentIndex = ref.read(bottomNavIndexProvider);
    if (currentIndex == index) return;

    // Меняем только индекс: PageView ниже сам перескочит на нужный экран.
    // jumpToPage используется вместо animateToPage, чтобы не было визуального
    // "проезда" через промежуточные вкладки.
    ref.read(bottomNavIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    ref.listen<int>(bottomNavIndexProvider, (previous, next) {
      if (previous == next || !_pageController.hasClients) return;
      _pageController.jumpToPage(next);
    });

    return Scaffold(
      body: RepaintBoundary(
        // PageView хранит состояние экранов между переключениями вкладок.
        // Пользователь не листает его свайпом: навигация идет только снизу.
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            if (ref.read(bottomNavIndexProvider) != index) {
              ref.read(bottomNavIndexProvider.notifier).state = index;
            }
          },
          children: _screens,
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        // Обертка нижнего меню рисует верхнюю границу и мягкую тень.
        // Цвета берутся из темы, поэтому меню одинаково работает в light/dark.
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, -6),
              color: AppTheme.subtleShadowOf(context),
            ),
          ],
        ),
        child: NavigationBar(
          // Каждая кнопка ведет на экран с тем же индексом в _screens.
          selectedIndex: currentIndex,
          onDestinationSelected: _selectTab,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.list_alt_outlined),
              selectedIcon: const Icon(Icons.list_alt_rounded),
              label: strings.entries,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart_rounded),
              label: strings.charts,
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline_rounded),
              selectedIcon: const Icon(Icons.add_circle_rounded),
              label: strings.add,
            ),
            NavigationDestination(
              icon: const Icon(Icons.analytics_outlined),
              selectedIcon: const Icon(Icons.analytics_rounded),
              label: strings.reports,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: strings.profile,
            ),
          ],
        ),
      ),
    );
  }
}
