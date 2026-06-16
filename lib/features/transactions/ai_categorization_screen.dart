// Файл: lib/features/transactions/ai_categorization_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';
import '../../common/localization/app_strings.dart';
import '../../common/models/category_model.dart';
import '../../common/providers/ai_learning_provider.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/services/ai_categorization_service.dart';
import '../../common/utils/app_theme.dart';
import '../../common/widgets/category_picker.dart';
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
  final TextEditingController _inputController = TextEditingController();

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  int _requestSerial = 0;

  @override
  void dispose() {
    ref.read(aiServiceProvider).cancelActiveRequest();
    _inputController.dispose();
    super.dispose();
  }

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

  double? _extractAmount(String text) {
    final match = RegExp(r'(\d+[.,]?\d*)').firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(0)!.replaceAll(',', '.'));
  }

  List<Map<String, dynamic>> _manualFallbackResults({
    required List<Map<String, dynamic>> resolved,
    required List<String> unresolvedLines,
  }) {
    final results = <Map<String, dynamic>>[...resolved];
    for (final line in unresolvedLines) {
      results.add({
        'text': _cleanText(line),
        'category_id': null,
        'amount': _extractAmount(line),
        'is_expense': true,
      });
    }
    return results;
  }

  void _cancelAI() {
    ref.read(aiServiceProvider).cancelActiveRequest();
    _requestSerial++;
    if (mounted) {
      setState(() => _isLoading = false);
    }
    final strings = AppStrings.of(context);
    _showMessage(strings.isRu ? 'Запрос к AI отменён' : 'AI request cancelled');
  }

  void _showAiError(
    AppStrings strings,
    AiErrorType? error, {
    bool manualFallback = false,
  }) {
    final suffix = manualFallback
        ? (strings.isRu
              ? ' Черновики добавлены ниже для ручной проверки.'
              : ' Drafts were added below for manual review.')
        : '';

    switch (error) {
      case AiErrorType.noInternet:
        _showMessage(
          strings.isRu
              ? 'Потеряно соединение с сетью или AI-провайдер недоступен.$suffix'
              : 'Network connection was lost or the AI provider is unavailable.$suffix',
        );
        break;
      case AiErrorType.timeout:
        _showMessage(
          strings.isRu
              ? 'AI не ответил вовремя.$suffix'
              : 'AI did not respond in time.$suffix',
        );
        break;
      case AiErrorType.unauthorized:
        _showMessage(
          strings.isRu
              ? 'Неверный API-ключ AI.$suffix'
              : 'Invalid AI API key.$suffix',
        );
        break;
      case AiErrorType.rateLimited:
        _showMessage(
          strings.isRu
              ? 'Лимит запросов AI достигнут, попробуйте позже.$suffix'
              : 'AI rate limit reached, please try again later.$suffix',
        );
        break;
      case AiErrorType.server:
        _showMessage(
          strings.isRu
              ? 'AI-сервис временно недоступен.$suffix'
              : 'The AI service is temporarily unavailable.$suffix',
        );
        break;
      case AiErrorType.cancelled:
        break;
      case AiErrorType.unknown:
      case null:
        _showMessage(strings.isRu ? 'Ошибка AI.$suffix' : 'AI error.$suffix');
        break;
    }
  }

  Future<void> _runAI() async {
    final strings = AppStrings.of(context);
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final requestSerial = ++_requestSerial;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final categories = await ref.read(allCategoriesProvider.future);
      final active = categories.where((c) => !c.isArchived).toList();
      final service = ref.read(aiServiceProvider);

      final result = await service.categorizeBatch(
        text: text,
        categories: active,
      );

      if (!mounted || requestSerial != _requestSerial) return;

      final cleaned = result.data
          .map((item) => {...item, 'text': _cleanText('${item['text'] ?? ''}')})
          .toList();

      final nextResults =
          result.canFallbackToManual && result.unresolvedLines.isNotEmpty
          ? _manualFallbackResults(
              resolved: cleaned,
              unresolvedLines: result.unresolvedLines,
            )
          : cleaned;

      setState(() => _results = nextResults);

      if (result.hasError) {
        _showAiError(
          strings,
          result.error,
          manualFallback: result.unresolvedLines.isNotEmpty,
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'AI screen failed to process input',
        name: 'AI',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || requestSerial != _requestSerial) return;
      final fallback = _manualFallbackResults(
        resolved: const [],
        unresolvedLines: text
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList(),
      );
      setState(() => _results = fallback);
      _showMessage(
        strings.isRu
            ? 'Не удалось связаться с AI. Черновики добавлены для ручного выбора.'
            : 'Unable to reach AI. Drafts were added for manual review.',
      );
    } finally {
      if (mounted && requestSerial == _requestSerial) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editItem(int index) async {
    final categories = await ref.read(allCategoriesProvider.future);
    if (!mounted) return;

    final updated = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AiEditSheet(item: _results[index], categories: categories),
    );

    if (updated == null || !mounted) return;

    setState(() {
      _results[index] = {..._results[index], ...updated};
    });
  }

  void _removeItem(int index) {
    setState(() => _results.removeAt(index));
  }

  Future<void> _saveAll() async {
    final strings = AppStrings.of(context);
    final notifier = ref.read(transactionsProvider.notifier);
    final aiService = ref.read(aiServiceProvider);

    for (final item in _results) {
      final amount = item['amount'];
      final isExpense = item['is_expense'];
      final text = item['text'];
      final categoryId = item['category_id'];

      if (amount == null || isExpense == null || text == null) continue;

      await notifier.addTransaction(
        amount: amount,
        categoryId: categoryId ?? '',
        isExpense: isExpense,
        description: text,
      );

      if (categoryId != null) {
        await aiService.saveMapping(text.toString(), categoryId.toString());
      }
    }

    _showMessage(
      strings.isRu
          ? 'Операции добавлены и словарь обновлён'
          : 'Transactions saved and dictionary updated',
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _showDictionary() async {
    final strings = AppStrings.of(context);

    try {
      final entries = await ref.read(aiLearningServiceProvider).getEntries();
      final categories = await ref.read(allCategoriesProvider.future);
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Row(
              children: [
                Expanded(
                  child: Text(strings.isRu ? 'AI словарь' : 'AI dictionary'),
                ),
                Text('${entries.length}'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(dialogContext).size.height * 0.55,
              child: entries.isEmpty
                  ? Center(child: Text(strings.noData))
                  : ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final item = entries[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.memory_outlined),
                          title: Text(item.keyword),
                          subtitle: Text(
                            '${strings.isRu ? 'Категория' : 'Category'}: ${_categoryLabel(categories, item.categoryId)}',
                          ),
                          trailing: Text('x${item.usageCount}'),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(strings.close),
              ),
            ],
          );
        },
      );
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  String _categoryLabel(List<CategoryModel> categories, String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return '—';
    }

    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    if (category == null) {
      return categoryId;
    }

    if (!category.isSubcategory) {
      return category.name;
    }

    final parent = categories.firstWhereOrNull(
      (c) => c.id == category.parentId,
    );
    if (parent == null) {
      return category.name;
    }

    return '${category.name} (${parent.name})';
  }

  String _amountLabel(AppStrings strings, dynamic amount) {
    final value = amount is num
        ? amount.toDouble()
        : double.tryParse('$amount');
    if (value == null) {
      return strings.isRu ? 'Сумма не указана' : 'Amount not set';
    }

    final normalized = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);

    return strings.isRu ? 'Сумма: $normalized' : 'Amount: $normalized';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <CategoryModel>[];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(strings.isRu ? 'AI категоризация' : 'AI categorization'),
        actions: [
          IconButton(
            // Dev-кнопка показывает накопленный AI-словарь для отладки.
            tooltip: strings.isRu ? 'Dev: словарь' : 'Dev: dictionary',
            icon: const Icon(Icons.developer_mode_outlined),
            onPressed: _showDictionary,
          ),
          IconButton(
            // Очищает введенный текст и текущие результаты распознавания.
            tooltip: strings.isRu ? 'Очистить' : 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _inputController.clear();
              setState(() => _results.clear());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _InputCard(
              // Верхняя карточка принимает сырой список операций, по одной
              // операции на строку.
              controller: _inputController,
              isLoading: _isLoading,
              onProcess: _runAI,
              onCancel: _cancelAI,
            ),
            const SizedBox(height: 16),
            if (_results.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Center(
                  child: Text(
                    strings.noData,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.66),
                    ),
                  ),
                ),
              )
            else ...[
              Text(
                strings.isRu
                    ? 'Распознанные операции'
                    : 'Recognized transactions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._results.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isExpense = item['is_expense'] == true;
                final tint = isExpense ? colors.expense : colors.income;

                return Container(
                  // Карточка результата AI: слева тип операции, по центру
                  // распознанный текст/сумма/категория, справа редактирование.
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colors.border),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                        color: Colors.black.withOpacity(
                          Theme.of(context).brightness == Brightness.dark
                              ? 0.18
                              : 0.05,
                        ),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // Цвет иконки показывает расход или доход.
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: tint.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isExpense
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: tint,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['text']?.toString() ?? '',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _InfoChip(
                                    icon: Icons.payments_outlined,
                                    text: _amountLabel(strings, item['amount']),
                                  ),
                                  _InfoChip(
                                    icon: Icons.folder_outlined,
                                    text: _categoryLabel(
                                      categories,
                                      item['category_id']?.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              // Ручная правка распознанной операции.
                              tooltip: strings.isRu ? 'Редактировать' : 'Edit',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editItem(index),
                            ),
                            IconButton(
                              // Удаляет одну строку из результатов перед сохранением.
                              tooltip: strings.isRu ? 'Удалить' : 'Delete',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Сохраняет все распознанные операции пачкой.
                  onPressed: _saveAll,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                  ),
                  child: Text(
                    strings.isRu
                        ? 'Добавить все операции'
                        : 'Add all transactions',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.isLoading,
    required this.onProcess,
    required this.onCancel,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onProcess;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);

    return Container(
      // Карточка ввода: рамка и радиус отделяют AI-инструмент от результатов.
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.isRu ? 'Список операций' : 'Transaction list',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            strings.isRu
                ? 'Каждая строка будет обработана как отдельная операция'
                : 'Each line will be processed as a separate transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.66),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            strings.isRu
                ? 'Если сеть пропадёт, нераспознанные строки можно будет сразу исправить вручную'
                : 'If the network fails, unresolved rows will stay available for manual review',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.58),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            // Многострочное поле: каждая строка считается отдельной операцией.
            controller: controller,
            maxLines: 10,
            minLines: 8,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: strings.isRu
                  ? 'Кофе 300\nТакси 520\nПятёрочка 1500'
                  : 'Coffee 300\nTaxi 520\nGroceries 1500',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  // Запускает AI-обработку списка. Во время загрузки заменяется
                  // индикатором и блокирует повторный запуск.
                  onPressed: isLoading ? null : onProcess,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : Text(
                          strings.isRu ? 'Обработать список' : 'Process list',
                        ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                // Кнопка отмены активна только во время запроса.
                onPressed: isLoading ? onCancel : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text(strings.isRu ? 'Отмена' : 'Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 6),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _AiEditSheet extends StatefulWidget {
  const _AiEditSheet({required this.item, required this.categories});

  final Map<String, dynamic> item;
  final List<CategoryModel> categories;

  @override
  State<_AiEditSheet> createState() => _AiEditSheetState();
}

class _AiEditSheetState extends State<_AiEditSheet> {
  late final TextEditingController _textController;
  late final TextEditingController _amountController;
  late final bool _isExpense;
  String? _selectedCategoryId;
  bool _showPicker = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.item['text']?.toString() ?? '',
    );
    _amountController = TextEditingController(
      text: widget.item['amount']?.toString() ?? '',
    );
    _selectedCategoryId = widget.item['category_id']?.toString();
    _isExpense = widget.item['is_expense'] == true;
    _showPicker = _selectedCategoryId == null;
  }

  @override
  void dispose() {
    _textController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  CategoryModel? get _selectedCategory =>
      widget.categories.firstWhereOrNull((c) => c.id == _selectedCategoryId);

  String _categoryLabel(CategoryModel? category) {
    if (category == null) {
      return '—';
    }

    if (!category.isSubcategory) {
      return category.name;
    }

    final parent = widget.categories.firstWhereOrNull(
      (item) => item.id == category.parentId,
    );

    if (parent == null) {
      return category.name;
    }

    return '${category.name} (${parent.name})';
  }

  void _submit() {
    final parsedAmount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    Navigator.pop(context, {
      'text': _textController.text.trim(),
      'amount': parsedAmount ?? widget.item['amount'],
      'category_id': _selectedCategoryId,
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              offset: const Offset(0, -8),
              color: Colors.black.withOpacity(0.12),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.isRu
                                    ? 'Редактирование операции'
                                    : 'Edit transaction',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                strings.isRu
                                    ? 'Скорректируйте текст, сумму и категорию перед сохранением'
                                    : 'Adjust text, amount, and category before saving',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.66),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _textController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: strings.isRu ? 'Описание' : 'Description',
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: strings.isRu ? 'Сумма' : 'Amount',
                        prefixIcon: const Icon(Icons.payments_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedCategory == null
                            ? colors.surfaceSoft
                            : _selectedCategory!.colorValue.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _selectedCategory == null
                              ? colors.border
                              : _selectedCategory!.colorValue.withOpacity(0.40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _selectedCategory == null
                                      ? colors.surface
                                      : _selectedCategory!.colorValue
                                            .withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _selectedCategory?.iconData ??
                                      Icons.category_outlined,
                                  color:
                                      _selectedCategory?.colorValue ??
                                      colors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      strings.isRu
                                          ? 'Выбранная категория'
                                          : 'Selected category',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.66),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedCategory == null
                                          ? (strings.isRu
                                                ? 'Категория пока не выбрана'
                                                : 'No category selected yet')
                                          : _categoryLabel(_selectedCategory),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _showPicker = !_showPicker);
                            },
                            icon: Icon(
                              _showPicker
                                  ? Icons.expand_less_rounded
                                  : Icons.tune_rounded,
                            ),
                            label: Text(
                              _showPicker
                                  ? (strings.isRu
                                        ? 'Скрыть выбор категорий'
                                        : 'Hide category picker')
                                  : (strings.isRu
                                        ? 'Открыть выбор категорий'
                                        : 'Open category picker'),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Container(
                        margin: const EdgeInsets.only(top: 14),
                        height: 340,
                        decoration: BoxDecoration(
                          color: colors.surfaceSoft,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: colors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: CategoryPicker(
                            isExpense: _isExpense,
                            selectedCategory: _selectedCategory,
                            mode: CategoryPickerMode.list,
                            onSelected: (category) {
                              setState(() {
                                _selectedCategoryId = category.id;
                                _showPicker = false;
                              });
                            },
                          ),
                        ),
                      ),
                      crossFadeState: _showPicker
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 180),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                      ),
                      child: Text(strings.save),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
