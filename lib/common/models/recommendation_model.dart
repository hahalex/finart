enum RecommendationType { warning, success, info, tip }

enum RecommendationPriority { high, medium, low }

class Recommendation {
  /// Уникальный id рекомендации
  final String id;

  /// Заголовок
  final String title;

  /// Описание / пояснение
  final String? description;

  /// Тип (warning / success / tip ...)
  final RecommendationType type;

  /// Приоритет показа
  final RecommendationPriority priority;

  /// Можно ли скрыть пользователем
  final bool dismissible;

  /// Скрыта ли пользователем
  final bool isHidden;

  /// Когда рекомендация была показана впервые
  final DateTime shownAt;

  const Recommendation({
    required this.id,
    required this.title,
    this.description,
    this.type = RecommendationType.info,
    this.priority = RecommendationPriority.medium,
    this.dismissible = true,
    required this.shownAt,
    this.isHidden = false,
  });

  Recommendation copyWith({
    String? id,
    String? title,
    String? description,
    RecommendationType? type,
    RecommendationPriority? priority,
    bool? dismissible,
    bool? isHidden,
    DateTime? shownAt,
  }) {
    return Recommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      dismissible: dismissible ?? this.dismissible,
      isHidden: isHidden ?? this.isHidden,
      shownAt: shownAt ?? this.shownAt,
    );
  }
}
