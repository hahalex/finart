import 'package:flutter/material.dart';

import '../../features/transactions/transactions_screen.dart';
import '../../features/analytics/charts_screen.dart';
import '../../features/analytics/reports_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/transactions/add_transaction_screen.dart';

/// Главный экран с нижней навигацией
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  /// Список экранов для нижнего меню
  final List<Widget> _screens = const [
    TransactionsScreen(),
    ChartsScreen(),
    AddTransactionScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
