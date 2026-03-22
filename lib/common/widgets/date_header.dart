import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Заголовок группы по дате (например, "6 марта")
class DateHeader extends StatelessWidget {
  final String label;
  final double? paddingTop;

  const DateHeader({super.key, required this.label, this.paddingTop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, paddingTop ?? 20, 16, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
          fontSize: 15,
        ),
      ),
    );
  }
}
