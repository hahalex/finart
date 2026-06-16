// Файл: lib/common/widgets/date_header.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class DateHeader extends StatelessWidget {
  final String label;
  final double? paddingTop;

  const DateHeader({super.key, required this.label, this.paddingTop});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16, paddingTop ?? 20, 16, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.primary,
          fontSize: 15,
        ),
      ),
    );
  }
}
