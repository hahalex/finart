// import 'package:flutter/material.dart';

// import 'mock_reports.dart';
// import 'widgets/report_stat_card.dart';
// import 'widgets/recommendation_tile.dart';

// /// Экран "Отчёты"
// class ReportsScreen extends StatelessWidget {
//   const ReportsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final report = mockMonthlyReport;

//     return SafeArea(
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           /// Заголовок
//           Text('Отчёт за месяц', style: Theme.of(context).textTheme.titleLarge),

//           const SizedBox(height: 16),

//           /// Карточки статистики
//           Row(
//             children: [
//               ReportStatCard(
//                 title: 'Средний доход',
//                 value: report.averageIncome,
//               ),
//               ReportStatCard(
//                 title: 'Средний расход',
//                 value: report.averageExpense,
//               ),
//               ReportStatCard(
//                 title: 'Средний баланс',
//                 value: report.averageBalance,
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           /// Рекомендации
//           Text('Рекомендации', style: Theme.of(context).textTheme.titleMedium),

//           const SizedBox(height: 8),

//           ...report.recommendations.map(
//             (text) => RecommendationTile(text: text),
//           ),
//         ],
//       ),
//     );
//   }
// }
