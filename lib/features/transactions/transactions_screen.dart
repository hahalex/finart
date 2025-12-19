// import 'package:flutter/material.dart';

// import '../../common/widgets/summary_card.dart';
// import '../../common/widgets/transaction_tile.dart';
// import '../../common/utils/app_theme.dart';

// /// Экран "Записи" — главный экран приложения
// class TransactionsScreen extends StatelessWidget {
//   const TransactionsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         children: [
//           /// Шапка с датой и общей статистикой
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Text('Сегодня', style: Theme.of(context).textTheme.titleLarge),
//                 const SizedBox(height: 16),

//                 /// Карточки: доходы / расходы / баланс
//                 Row(
//                   children: const [
//                     SummaryCard(
//                       title: 'Доходы',
//                       amount: 3500,
//                       color: AppTheme.incomeColor,
//                     ),
//                     SummaryCard(
//                       title: 'Расходы',
//                       amount: 2100,
//                       color: AppTheme.expenseColor,
//                     ),
//                     SummaryCard(
//                       title: 'Баланс',
//                       amount: 1400,
//                       color: Colors.blue,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           /// Список операций
//           Expanded(
//             child: ListView(
//               children: const [
//                 TransactionTile(
//                   title: 'Покупка продуктов',
//                   category: 'Еда',
//                   amount: 1200,
//                   isExpense: true,
//                 ),
//                 TransactionTile(
//                   title: 'Проезд',
//                   category: 'Транспорт',
//                   amount: 300,
//                   isExpense: true,
//                 ),
//                 TransactionTile(
//                   title: 'Зарплата',
//                   category: 'Доход',
//                   amount: 3500,
//                   isExpense: false,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
