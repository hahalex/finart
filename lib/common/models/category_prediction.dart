// Файл: lib/common/models/category_prediction.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

class CategoryPrediction {
  final String categoryId;
  final double confidence;

  const CategoryPrediction({
    required this.categoryId,
    required this.confidence,
  });

  factory CategoryPrediction.fromJson(Map<String, dynamic> json) {
    return CategoryPrediction(
      categoryId: json['category_id'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}
