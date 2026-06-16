// Файл: lib/features/categories/category_form_dialog.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/localization/app_strings.dart';
import '../../common/models/category_model.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/utils/app_theme.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  const CategoryFormDialog({
    super.key,
    required this.isExpense,
    this.category,
    this.parentCategory,
    required this.onSave,
  });

  final bool isExpense;
  final CategoryModel? category;
  final CategoryModel? parentCategory;
  final ValueChanged<CategoryModel> onSave;

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _aiTagController;
  late int _iconCode;
  late int _color;
  String? _selectedParentId;
  String? _aiTag;
  bool _isSubcategoryMode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _aiTagController = TextEditingController(
      text: widget.category?.aiTag ?? '',
    );
    _iconCode = widget.category?.iconCode ?? Icons.category.codePoint;
    _color =
        widget.category?.color ??
        AppTheme.lightCategoryPresetColors.first.value;
    _selectedParentId = widget.parentCategory?.id ?? widget.category?.parentId;
    _aiTag = widget.category?.aiTag;
    _isSubcategoryMode = _selectedParentId != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aiTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final strings = AppStrings.of(context);
    final availableIcons = AppTheme.categoryPresetIcons;
    final availableColors = AppTheme.categoryPresetColorsOf(context);
    final isEdit = widget.category != null;
    final isForcedSubcategory = widget.parentCategory != null;

    return AlertDialog(
      title: Text(isEdit ? strings.editCategory : strings.newCategory),
      content: SingleChildScrollView(
        // SingleChildScrollView защищает форму от overflow на небольших экранах.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              // Название категории обязательно и показывается во всех списках.
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${strings.name} *',
                helperText: strings.isRu
                    ? 'Понятное имя для отображения в приложении'
                    : 'A clear name shown across the app',
              ),
              autofocus: true,
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            Text(strings.icon, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              // Сетка иконок: выбранная иконка подсвечивается рамкой primary.
              height: 144,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = availableIcons[index];
                  final isSelected = _iconCode == icon.codePoint;

                  return GestureDetector(
                    onTap: () => setState(() => _iconCode = icon.codePoint),
                    child: AnimatedContainer(
                      // AnimatedContainer дает мягкую смену рамки/фона при выборе.
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary.withOpacity(0.15)
                            : colors.surfaceSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(icon, color: Color(_color), size: 24),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(strings.color, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              // Цветовые кружки категории. Выбранный цвет получает толстую рамку
              // и галочку с контрастным цветом текста.
              spacing: 8,
              runSpacing: 8,
              children: availableColors.map((colorValue) {
                final value = colorValue.value;
                final isSelected = _color == value;

                return GestureDetector(
                  onTap: () => setState(() => _color = value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(value),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? colors.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: AppTheme.getContrastText(Color(value)),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (!isForcedSubcategory) ...[
              Row(
                children: [
                  Text(
                    strings.subcategory,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    // Переключает форму между основной категорией и подкатегорией.
                    value: _isSubcategoryMode,
                    onChanged: (value) {
                      setState(() {
                        _isSubcategoryMode = value;
                        if (!value) _selectedParentId = null;
                      });
                    },
                  ),
                ],
              ),
              if (_isSubcategoryMode) ...[
                const SizedBox(height: 8),
                _buildParentSelector(context),
              ],
            ],
            const SizedBox(height: 16),
            TextField(
              // AI-тег помогает автоматической категоризации связывать слова
              // из описания операции с этой категорией.
              controller: _aiTagController,
              decoration: InputDecoration(
                labelText: strings.aiTagOptional,
                hintText: 'food, transport, subscriptions...',
                helperText: strings.isRu
                    ? 'AI-тег помогает автоматической классификации. Можно указать ключевую тему или синоним.'
                    : 'AI tag helps automatic categorization. Use a theme, keyword, or synonym.',
              ),
              onChanged: (value) => _aiTag = value.trim().isEmpty
                  ? null
                  : value.toLowerCase().trim(),
            ),
            if ((_aiTag ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildHintChip(
                    context,
                    icon: Icons.auto_awesome_rounded,
                    label: strings.isRu
                        ? 'Текущий AI-тег: $_aiTag'
                        : 'Current AI tag: $_aiTag',
                  ),
                  _buildHintChip(
                    context,
                    icon: Icons.tips_and_updates_outlined,
                    label: strings.isRu
                        ? 'Пример: coffee, groceries, freelance'
                        : 'Example: coffee, groceries, freelance',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          // Закрывает форму без сохранения.
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        ElevatedButton(
          // Сохраняет категорию и возвращает ее в вызывающий экран.
          onPressed: () => _save(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEdit ? strings.save : strings.createCategory),
        ),
      ],
    );
  }

  Widget _buildParentSelector(BuildContext context) {
    final strings = AppStrings.of(context);
    final rootsAsync = ref.watch(
      widget.isExpense ? expenseCategoriesProvider : incomeCategoriesProvider,
    );

    return rootsAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (err, _) => Text('Error: $err'),
      data: (allRoots) {
        final roots = allRoots
            .where(
              (root) =>
                  widget.category == null || root.id != widget.category!.id,
            )
            .toList();

        if (roots.isEmpty) {
          return Text(
            strings.createRootCategoryFirst,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mutedTextOf(context),
            ),
          );
        }

        return DropdownButtonFormField<String>(
          value: _selectedParentId?.isEmpty == true ? null : _selectedParentId,
          decoration: InputDecoration(labelText: strings.parentCategory),
          items: roots.map((root) {
            return DropdownMenuItem<String>(
              value: root.id,
              child: Row(
                children: [
                  Icon(root.iconData, size: 18, color: root.colorValue),
                  const SizedBox(width: 8),
                  Expanded(child: Text(root.name)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedParentId = value),
          isExpanded: true,
        );
      },
    );
  }

  void _save(BuildContext context) {
    final strings = AppStrings.of(context);
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.categoryNameRequired)));
      return;
    }

    if (_isSubcategoryMode &&
        (_selectedParentId == null || _selectedParentId!.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.chooseParentCategory)));
      return;
    }

    final category = CategoryModel(
      id: widget.category?.id ?? _generateId(name),
      name: name,
      iconCode: _iconCode,
      isExpense: widget.isExpense,
      parentId: _isSubcategoryMode ? _selectedParentId : null,
      color: _color,
      isCustom: widget.category?.isCustom ?? true,
      isArchived: widget.category?.isArchived ?? false,
      order: widget.category?.order ?? 0,
      aiTag: _aiTag?.isNotEmpty == true ? _aiTag : null,
    );

    widget.onSave(category);
    Navigator.pop(context);
  }

  String _generateId(String name) {
    final base = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9а-яё]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return '${base}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Widget _buildHintChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
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
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
