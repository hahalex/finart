import 'package:flutter/material.dart';
import '../../../common/models/recommendation_model.dart';

class RecommendationTile extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationTile({super.key, required this.recommendation});

  IconData _iconForType(RecommendationType type) {
    switch (type) {
      case RecommendationType.warning:
        return Icons.warning_amber_rounded;
      case RecommendationType.success:
        return Icons.check_circle_outline_rounded;
      case RecommendationType.tip:
        return Icons.lightbulb_outline_rounded;
      case RecommendationType.info:
        return Icons.info_outline_rounded;
    }
  }

  Color _colorForType(BuildContext context, RecommendationType type) {
    switch (type) {
      case RecommendationType.warning:
        return Colors.orange;
      case RecommendationType.success:
        return Colors.green;
      case RecommendationType.tip:
        return Colors.purple;
      case RecommendationType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _colorForType(context, recommendation.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForType(recommendation.type),
              color: accentColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (recommendation.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    recommendation.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
