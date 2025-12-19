import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/navigation_provider.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/analytics/charts_screen.dart';
import '../../features/analytics/reports_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/transactions/add_transaction_screen.dart';

/// Главный экран с нижней навигацией
class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  /// Список экранов для нижнего меню
  static const List<Widget> _screens = [
    TransactionsScreen(),
    ChartsScreen(),
    AddTransactionScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: _screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Записи'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Графики',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Добавить',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Отчёты'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
