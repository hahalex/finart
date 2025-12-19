// import 'package:flutter/material.dart';
// import '../categories/mock_categories.dart';
// import '../../common/utils/app_theme.dart';

// /// Экран добавления дохода или расхода
// class AddTransactionScreen extends StatefulWidget {
//   const AddTransactionScreen({super.key});

//   @override
//   State<AddTransactionScreen> createState() => _AddTransactionScreenState();
// }

// class _AddTransactionScreenState extends State<AddTransactionScreen> {
//   bool isExpense = true;
//   Category? selectedCategory;
//   final TextEditingController amountController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final categories = mockCategories
//         .where((c) => c.isExpense == isExpense)
//         .toList();

//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// Переключатель: расход / доход
//             ToggleButtons(
//               isSelected: [isExpense, !isExpense],
//               borderRadius: BorderRadius.circular(12),
//               onPressed: (index) {
//                 setState(() {
//                   isExpense = index == 0;
//                   selectedCategory = null;
//                 });
//               },
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24),
//                   child: Text('Расход'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 24),
//                   child: Text('Доход'),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             /// Ввод суммы
//             TextField(
//               controller: amountController,
//               keyboardType: TextInputType.number,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//               decoration: const InputDecoration(
//                 hintText: '0 ₽',
//                 border: InputBorder.none,
//               ),
//             ),

//             const SizedBox(height: 16),

//             /// Категории
//             SizedBox(
//               height: 100,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: categories.map((category) {
//                   final isSelected = selectedCategory == category;
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedCategory = category;
//                       });
//                     },
//                     child: Container(
//                       width: 80,
//                       margin: const EdgeInsets.symmetric(horizontal: 8),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? AppTheme.primaryColor.withOpacity(0.15)
//                             : Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             category.icon,
//                             size: 32,
//                             color: AppTheme.primaryColor,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             category.name,
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),

//             const SizedBox(height: 16),

//             /// Описание
//             TextField(
//               controller: descriptionController,
//               decoration: const InputDecoration(
//                 hintText: 'Описание (необязательно)',
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const Spacer(),

//             /// Кнопка сохранения
//             ElevatedButton(
//               onPressed: () {
//                 // Пока ничего не сохраняем — логика будет позже
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 56),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               child: const Icon(Icons.check, size: 32),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
