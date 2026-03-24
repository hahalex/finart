import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/category_model.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/utils/app_theme.dart';

// TODO убрать все подкатегории - предупреждуения о том что нужно выбрать родительскую категорию достаточно
// ============================================================================
// 📝 ФОРМА: Создание/Редактирование категории
// ============================================================================

class CategoryFormDialog extends ConsumerStatefulWidget {
  final bool isExpense;
  final CategoryModel? category;
  final CategoryModel? parentCategory;
  final Function(CategoryModel) onSave;

  const CategoryFormDialog({
    super.key,
    required this.isExpense,
    this.category,
    this.parentCategory,
    required this.onSave,
  });

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  late final TextEditingController _nameController;
  late int _iconCode;
  late int _color;
  String? _selectedParentId;
  String? _aiTag;
  bool _isSubcategoryMode = false;

  // 🔹 Предустановленные иконки (Material Icons)
  static const _availableIcons = [
    Icons.fastfood,
    Icons.local_cafe,
    Icons.shopping_cart,
    Icons.directions_bus,
    Icons.local_taxi,
    Icons.flight,
    Icons.movie,
    Icons.sports_esports,
    Icons.music_note,
    Icons.home,
    Icons.work,
    Icons.school,
    Icons.favorite,
    Icons.health_and_safety,
    Icons.local_hospital,
    Icons.payments,
    Icons.account_balance,
    Icons.card_giftcard,
    Icons.category,
    Icons.attach_money,
    Icons.credit_card,
    Icons.shopping_bag,
  ];

  // 🔹 Предустановленные цвета
  static const _availableColors = [
    0xFFFF9800, // orange
    0xFF2196F3, // blue
    0xFF9C27B0, // purple
    0xFF4CAF50, // green
    0xFFF44336, // red
    0xFF607D8B, // blue grey
    0xFF795548, // brown
    0xFFE91E63, // pink
    0xFF00BCD4, // cyan
    0xFFFFC107, // amber
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _iconCode = widget.category?.iconCode ?? Icons.category.codePoint;
    _color = widget.category?.color ?? _availableColors.first;
    _selectedParentId = widget.parentCategory?.id ?? widget.category?.parentId;
    _aiTag = widget.category?.aiTag;
    _isSubcategoryMode = _selectedParentId != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    final isForcedSubcategory = widget.parentCategory != null;

    return AlertDialog(
      title: Text(isEdit ? 'Редактировать' : 'Новая категория'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Название
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название *',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              autofocus: true,
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            // 🔹 Выбор иконки
            Text('Иконка', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableIcons.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = _iconCode == icon.codePoint;
                  return GestureDetector(
                    onTap: () => setState(() => _iconCode = icon.codePoint),
                    child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.15)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(icon, color: Color(_color), size: 28),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Выбор цвета
            Text('Цвет', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((c) {
                final isSelected = _color == c;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: _getContrastText(Color(c)),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 🔹 Режим подкатегории
            if (!isForcedSubcategory) ...[
              Row(
                children: [
                  Text(
                    'Подкатегория',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isSubcategoryMode,
                    onChanged: (val) {
                      setState(() {
                        _isSubcategoryMode = val;
                        if (!val) _selectedParentId = null;
                      });
                    },
                  ),
                ],
              ),

              // 🔹 Выбор родителя (если режим подкатегории включён)
              if (_isSubcategoryMode) ...[
                const SizedBox(height: 8),
                _buildParentSelector(),
              ],
            ],

            // 🔹 AI-тег (опционально)
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'AI-тег (опционально)',
                hintText: 'food, transport, subscriptions...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onChanged: (val) =>
                  _aiTag = val.isEmpty ? null : val.toLowerCase().trim(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(isEdit ? 'Сохранить' : 'Создать'),
        ),
      ],
    );
  }

  /// 🔹 Виджет выбора родительской категории
  Widget _buildParentSelector() {
    final repo = ref.read(categoriesRepositoryProvider);

    return FutureBuilder<List<CategoryModel>>(
      future: repo.getRootCategories(widget.isExpense),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final roots = snapshot.data!;

        // Фильтруем: нельзя выбрать себя или свои подкатегории как родителя
        final availableRoots = roots.where((r) {
          if (widget.category == null) return true;
          return r.id != widget.category!.id;
        }).toList();

        if (availableRoots.isEmpty) {
          return Text(
            'Сначала создайте корневую категорию',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          );
        }

        return DropdownButtonFormField<String>(
          value: _selectedParentId?.isEmpty == true ? null : _selectedParentId,
          decoration: const InputDecoration(
            labelText: 'Родительская категория *',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          ),
          items: availableRoots.map((root) {
            return DropdownMenuItem(
              value: root.id,
              child: Row(
                children: [
                  Icon(root.iconData, size: 18, color: root.colorValue),
                  const SizedBox(width: 8),
                  Text(root.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedParentId = val),
          isExpanded: true,
          validator: (val) {
            if (_isSubcategoryMode && (val == null || val.isEmpty)) {
              return 'Выберите родителя';
            }
            return null;
          },
        );
      },
    );
  }

  /// 🔹 Сохранение категории
  void _save() {
    // Валидация названия
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название категории')),
      );
      return;
    }

    // Валидация родителя (если режим подкатегории)
    if (_isSubcategoryMode &&
        (_selectedParentId == null || _selectedParentId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите родительскую категорию')),
      );
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

  /// 🔹 Генерация уникального ID
  String _generateId(String name) {
    final base = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9а-яё]'), '_');
    return '${base}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 🔹 Контрастный текст для цвета фона
  Color _getContrastText(Color bg) {
    return bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }
}
