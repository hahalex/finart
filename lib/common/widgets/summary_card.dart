// Файл: lib/common/widgets/summary_card.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // Карточка занимает треть строки итогов. Акцентная декорация дает
        // мягкий градиент, рамку и тень на основе переданного цвета.
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.accentCardDecoration(
          context,
          accent: color,
          radius: AppTheme.radiusLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // Верхняя иконка находится в полупрозрачной плашке того же цвета,
              // что и сумма, чтобы быстро считывать тип показателя.
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.mutedTextOf(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              // FittedBox не дает крупной сумме выйти за границы узкой карточки.
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  amount.toStringAsFixed(0),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
