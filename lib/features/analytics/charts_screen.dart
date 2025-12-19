// import 'package:flutter/material.dart';

// import 'mock_analytics.dart';
// import 'widgets/expenses_chart_placeholder.dart';
// import 'widgets/category_expense_tile.dart';

// /// Экран "Графики"
// class ChartsScreen extends StatelessWidget {
//   const ChartsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           /// Заголовок
//           Text(
//             'Расходы по месяцам',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),

//           const SizedBox(height: 16),

//           /// График
//           const ExpensesChartPlaceholder(),

//           const SizedBox(height: 24),

//           /// Подзаголовок
//           Text(
//             'Расходы по категориям',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),

//           const SizedBox(height: 8),

//           /// Список категорий
//           ...mockCategoryExpenses.map(
//             (expense) => CategoryExpenseTile(expense: expense),
//           ),
//         ],
//       ),
//     );
//   }
// }
