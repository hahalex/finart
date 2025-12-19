import 'package:flutter/material.dart';

/// Модель категории дохода или расхода.
/// Позже будет сохраняться в БД и приходить с backend.
class CategoryModel {
  /// Уникальный идентификатор (пока строка)
  final String id;

  /// Название категории
  final String name;

  /// Иконка категории
  final IconData icon;

  /// Является ли категорией расхода
  final bool isExpense;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
  });
}
