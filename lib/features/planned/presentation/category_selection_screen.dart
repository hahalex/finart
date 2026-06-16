// Файл: lib/features/planned/presentation/category_selection_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/localization/app_strings.dart';
import '../../../common/models/category_model.dart';
import '../../../common/providers/categories_provider.dart';
import '../../../common/widgets/category_picker.dart';

class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({
    super.key,
    required this.isExpense,
    this.selectedCategoryId,
  });

  final bool isExpense;
  final String? selectedCategoryId;

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen> {
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.isRu ? 'Выберите категорию' : 'Choose category'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (categories) {
          CategoryModel? selectedCategory;

          if (widget.selectedCategoryId != null) {
            for (final category in categories) {
              if (category.id == widget.selectedCategoryId) {
                selectedCategory = category;
                break;
              }
            }
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(strings.isRu ? 'Расход' : 'Expense'),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(strings.isRu ? 'Доход' : 'Income'),
                      ),
                    ],
                    selected: {_isExpense},
                    onSelectionChanged: (value) {
                      setState(() => _isExpense = value.first);
                    },
                  ),
                ),
              ),
              Expanded(
                child: CategoryPicker(
                  isExpense: _isExpense,
                  selectedCategory: selectedCategory?.isExpense == _isExpense
                      ? selectedCategory
                      : null,
                  onSelected: (category) {
                    Navigator.pop(context, category);
                  },
                  mode: CategoryPickerMode.list,
                  showSubcategories: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
