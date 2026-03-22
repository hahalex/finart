import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/widgets/summary_card.dart';
import '../../common/widgets/transaction_tile.dart';
import '../../common/utils/app_theme.dart';
import '../transactions/providers/transactions_notifier.dart';
import '../transactions/providers/categories_provider.dart';
import '../../features/planned/presentation/planned_list_screen.dart'; // ✅ Новый импорт

/// Экран "Записи" — главный экран приложения
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);

    /// Сортируем операции по дате (новые сверху)
    final sortedTransactions = [...transactions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    /// Подсчёт аналитики
    final totalIncome = transactions
        .where((t) => !t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    return Scaffold(
      // ✅ Оборачиваем в Scaffold для поддержки FAB
      body: SafeArea(
        child: Column(
          children: [
            /// Шапка с датой и общей статистикой
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Сегодня',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  /// Карточки: доходы / расходы / баланс
                  Row(
                    children: [
                      SummaryCard(
                        title: 'Доходы',
                        amount: totalIncome,
                        color: AppTheme.incomeColor,
                      ),
                      SummaryCard(
                        title: 'Расходы',
                        amount: totalExpense,
                        color: AppTheme.expenseColor,
                      ),
                      SummaryCard(
                        title: 'Баланс',
                        amount: balance,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Список операций
            Expanded(
              child: sortedTransactions.isEmpty
                  ? const Center(
                      child: Text(
                        'Пока нет операций',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: sortedTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = sortedTransactions[index];

                        final category = categories.firstWhere(
                          (c) => c.id == transaction.categoryId,
                        );

                        return TransactionTile(
                          title: transaction.description ?? category.name,
                          category: category.name,
                          amount: transaction.amount,
                          isExpense: transaction.isExpense,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ✅ Плавающая кнопка для перехода к запланированным платежам
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlannedListScreen()),
          );
        },
        child: const Icon(Icons.event),
        tooltip: 'Предстоящие платежи',
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
