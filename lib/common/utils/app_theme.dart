import 'package:flutter/material.dart';

/// Общая тема приложения FinArt.
/// Здесь задаются цвета, шрифты и стили.
class AppTheme {
  /// Основной цвет приложения
  static const Color primaryColor = Color(0xFF4F46E5);

  /// Цвет доходов
  static const Color incomeColor = Color(0xFF16A34A);

  /// Цвет расходов
  static const Color expenseColor = Color(0xFFDC2626);

  /// Цвет фона
  static const Color backgroundColor = Color(0xFFF9FAFB);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
