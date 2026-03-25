import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/categories_provider.dart';
import '../transactions/providers/transactions_notifier.dart';
import 'providers/ai_provider.dart';

class AiCategorizationScreen extends ConsumerStatefulWidget {
  final bool isExpense;

  const AiCategorizationScreen({super.key, required this.isExpense});

  @override
  ConsumerState<AiCategorizationScreen> createState() =>
      _AiCategorizationScreenState();
}

class _AiCategorizationScreenState
    extends ConsumerState<AiCategorizationScreen> {
  final controller = TextEditingController();

  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  Future<void> _runAI() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() => isLoading = true);

    final categories = await ref.read(allCategoriesProvider.future);

    final filtered = categories
        .where((c) => c.isExpense == widget.isExpense && !c.isArchived)
        .toList();

    final service = ref.read(aiServiceProvider);

    final data = await service.categorizeBatch(
      text: text,
      categories: filtered,
    );

    setState(() {
      results = data;
      isLoading = false;
    });
  }

  void _saveAll() {
    for (final item in results) {
      if (item['amount'] == null) continue;

      ref
          .read(transactionsProvider.notifier)
          .addTransaction(
            amount: item['amount'],
            categoryId: item['category_id'] ?? '',
            isExpense: item['is_expense'] ?? widget.isExpense,
            description: item['text'],
          );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI категоризация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 Большое поле
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

            /// 🔹 Кнопка AI
            ElevatedButton(
              onPressed: isLoading ? null : _runAI,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Обработать список'),
            ),

            const SizedBox(height: 16),

            /// 🔹 РЕЗУЛЬТАТЫ
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('Нет данных'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];

                        return ListTile(
                          leading: const Icon(Icons.auto_awesome),
                          title: Text(item['text'] ?? ''),
                          subtitle: Text(
                            'Сумма: ${item['amount']} | Категория: ${item['category_id']}',
                          ),
                        );
                      },
                    ),
            ),

            /// 🔹 СОХРАНИТЬ ВСЁ
            if (results.isNotEmpty)
              ElevatedButton(
                onPressed: _saveAll,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Добавить все операции'),
              ),
          ],
        ),
      ),
    );
  }
}
