import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/providers/categories_provider.dart';
import '../transactions/providers/transactions_notifier.dart';
import 'providers/ai_provider.dart';
import '../../../main.dart';
import '../../common/services/ai_categorization_service.dart';

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
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // 🚀 AI
  // ============================================================
  Future<void> _runAI() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final categories = await ref.read(allCategoriesProvider.future);
      final active = categories.where((c) => !c.isArchived).toList();

      final service = ref.read(aiServiceProvider);

      final result = await service.categorizeBatch(
        text: text,
        categories: active,
      );

      /// ❗ ошибки, но данные всё равно могут быть
      if (result.hasError) {
        switch (result.error) {
          case AiErrorType.noInternet:
            _showMessage('Нет интернета');
            break;
          case AiErrorType.timeout:
            _showMessage('AI не ответил');
            break;
          default:
            _showMessage('Ошибка AI');
        }
      }

      final cleaned = result.data.map((e) {
        return {...e, "text": _cleanText(e['text'] ?? '')};
      }).toList();

      if (!mounted) return;

      setState(() {
        results = cleaned;
      });
    } catch (e, s) {
      debugPrint('💥 AI CRASH: $e');
      debugPrint('$s');

      _showMessage('Невозможно подключиться к AI');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ============================================================
  // ✏️ EDIT
  // ============================================================
  Future<void> _editItem(int index) async {
    final item = results[index];
    final categories = await ref.read(allCategoriesProvider.future);

    final textController = TextEditingController(text: item['text'] ?? '');
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
                controller: textController,
                autofocus: true,
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
                  results[index]['text'] = textController.text;
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

    textController.dispose();
  }

  void _removeItem(int index) {
    setState(() {
      results.removeAt(index);
    });
  }

  // ============================================================
  // 🧠 ОБУЧЕНИЕ + СОХРАНЕНИЕ
  // ============================================================
  void _saveAll() {
    final notifier = ref.read(transactionsProvider.notifier);
    final aiService = ref.read(aiServiceProvider);

    for (final item in results) {
      final amount = item['amount'];
      final isExpense = item['is_expense'];
      final text = item['text'];
      final categoryId = item['category_id'];

      if (amount == null || isExpense == null || text == null) continue;

      /// 💾 сохраняем транзакцию
      notifier.addTransaction(
        amount: amount,
        categoryId: categoryId ?? '',
        isExpense: isExpense,
        description: text,
      );

      /// 🧠 ОБУЧАЕМ AI
      if (categoryId != null) {
        aiService.saveMapping(text, categoryId);
      }
    }

    _showMessage('Сохранено и обучено 🎉');

    Navigator.pop(context);
  }

  // ============================================================
  // UI
  // ============================================================
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
              maxLines: 10,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText:
                    'Каждая строка — отдельная операция\n\nПример:\nКофе 300\nТакси 520\nПятёрочка 1500',
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
