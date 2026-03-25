import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/categories_provider.dart';
import '../transactions/providers/transactions_notifier.dart';
import 'providers/ai_provider.dart';

class AiCategorizationScreen extends ConsumerStatefulWidget {
  const AiCategorizationScreen({super.key});

  @override
  ConsumerState<AiCategorizationScreen> createState() =>
      _AiCategorizationScreenState();
}

class _AiCategorizationScreenState
    extends ConsumerState<AiCategorizationScreen> {
  final controller = TextEditingController();

  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  /// ============================================================
  /// 🔥 ЗАПУСК AI
  /// ============================================================
  Future<void> _runAI() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final categories = await ref.read(allCategoriesProvider.future);

      /// ✅ ВСЕ категории (и доходы, и расходы)
      final allActiveCategories = categories
          .where((c) => !c.isArchived)
          .toList();

      final service = ref.read(aiServiceProvider);

      final data = await service.categorizeBatch(
        text: text,
        categories: allActiveCategories,
      );

      /// ❗ БЕЗ ФИЛЬТРАЦИИ — берём всё как есть
      setState(() {
        results = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('💥 AI SCREEN ERROR: $e');
      setState(() => isLoading = false);
    }
  }

  /// ============================================================
  /// 🔥 СОХРАНЕНИЕ ВСЕХ ТРАНЗАКЦИЙ
  /// ============================================================
  void _saveAll() {
    final notifier = ref.read(transactionsProvider.notifier);

    for (final item in results) {
      final amount = item['amount'];
      final isExpense = item['is_expense'];

      /// защита от кривых данных
      if (amount == null || isExpense == null) continue;

      notifier.addTransaction(
        amount: amount,
        categoryId: item['category_id'] ?? '',
        isExpense: isExpense,
        description: item['text'],
      );
    }

    Navigator.pop(context);
  }

  /// ============================================================
  /// UI
  /// ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI категоризация'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
              setState(() => results.clear());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 ВВОД
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText:
                    'Пример:\nкофе 3€\nтакси 10€\nпродукты 25€\nзарплата 1000€',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 КНОПКА AI
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _runAI,
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Обработать список'),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 РЕЗУЛЬТАТЫ (ВСЕ ВМЕСТЕ)
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('Нет данных'))
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = results[index];
                        final isExpense = item['is_expense'] == true;

                        return ListTile(
                          leading: Icon(
                            isExpense
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: isExpense ? Colors.red : Colors.green,
                          ),
                          title: Text(item['text'] ?? ''),
                          subtitle: Text(
                            'Сумма: ${item['amount']} | Категория: ${item['category_id'] ?? '—'}',
                          ),
                        );
                      },
                    ),
            ),

            /// 🔹 СОХРАНИТЬ ВСЁ
            if (results.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAll,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Добавить все операции'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
