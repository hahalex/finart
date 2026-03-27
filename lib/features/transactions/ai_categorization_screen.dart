import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/categories_provider.dart';
import '../transactions/providers/transactions_notifier.dart';
import 'providers/ai_provider.dart';
import '../../../main.dart';

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

  String _cleanText(String text) {
    final cleaned = text.replaceAll(RegExp(r'[\d.,€$₽]+'), '').trim();
    return cleaned.isEmpty ? text : cleaned;
  }

  void _showMessage(String text) {
    final messenger = messengerKey.currentState;

    if (messenger == null) {
      debugPrint('❌ NO MESSENGER');
      return;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 🔥 ЛЮБАЯ ОШИБКА = ОДНО СООБЩЕНИЕ
  Future<void> _runAI() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final categories = await ref.read(allCategoriesProvider.future);

      final active = categories.where((c) => !c.isArchived).toList();

      final service = ref.read(aiServiceProvider);

      final data = await service.categorizeBatch(
        text: text,
        categories: active,
      );

      final cleaned = data.map((e) {
        return {...e, "text": _cleanText(e['text'] ?? '')};
      }).toList();

      if (!mounted) return;

      setState(() {
        results = cleaned;
      });
    } catch (e, s) {
      debugPrint('💥 AI CRASH: $e');
      debugPrint('$s');

      /// 💥 ВСЕГДА одно сообщение
      _showMessage('Невозможно подключиться к функции AI');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _removeItem(int index) {
    setState(() {
      results.removeAt(index);
    });
  }

  Future<void> _editItem(int index) async {
    final item = results[index];
    final categories = await ref.read(allCategoriesProvider.future);

    String text = item['text'] ?? '';
    String? selectedCategory = item['category_id'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: text),
                onChanged: (v) => text = v,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .where((c) => !c.isArchived)
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => selectedCategory = v,
                decoration: const InputDecoration(labelText: 'Категория'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  results[index]['text'] = text;
                  results[index]['category_id'] = selectedCategory;
                });
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _saveAll() {
    final notifier = ref.read(transactionsProvider.notifier);

    for (final item in results) {
      final amount = item['amount'];
      final isExpense = item['is_expense'];

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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _runAI,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Обработать список'),
              ),
            ),
            const SizedBox(height: 16),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editItem(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (results.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAll,
                  child: const Text('Добавить все операции'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
