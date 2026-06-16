// Файл: lib/features/analytics/widgets/report_stat_card.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';

import '../../../common/widgets/summary_card.dart';

class ReportStatCard extends StatelessWidget {
  const ReportStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(title: title, amount: value, color: color, icon: icon);
  }
}
