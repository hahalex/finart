enum RecommendationType { warning, success, info, tip }

class Recommendation {
  final String title;
  final String? description;
  final RecommendationType type;

  const Recommendation({
    required this.title,
    this.description,
    this.type = RecommendationType.info,
  });
}
