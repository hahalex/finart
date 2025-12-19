import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/data/default_categories.dart';
import '../../../common/models/category_model.dart';

/// Провайдер списка категорий
final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return defaultCategories;
});
