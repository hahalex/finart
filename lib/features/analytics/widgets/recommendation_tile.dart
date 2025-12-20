import 'package:flutter/material.dart';
import '../../../common/models/recommendation_model.dart';

IconData _iconForType(RecommendationType type) {
  switch (type) {
    case RecommendationType.warning:
      return Icons.warning_amber_rounded;
    case RecommendationType.success:
      return Icons.check_circle_outline;
    case RecommendationType.tip:
      return Icons.lightbulb_outline;
    case RecommendationType.info:
      return Icons.info_outline;
  }
}

/// Виджет одной рекомендации
class RecommendationTile extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationTile({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconForType(recommendation.type),
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (recommendation.description != null) ...[
                    const SizedBox(height: 4),
                    Text(recommendation.description!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
