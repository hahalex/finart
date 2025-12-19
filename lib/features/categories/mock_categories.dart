import 'package:flutter/material.dart';

/// Модель категории (пока простая, без backend)
class Category {
  final String name;
  final IconData icon;
  final bool isExpense;

  const Category({
    required this.name,
    required this.icon,
    required this.isExpense,
  });
}

/// Встроенные категории (заглушка)
const List<Category> mockCategories = [
  Category(name: 'Еда', icon: Icons.fastfood, isExpense: true),
  Category(name: 'Транспорт', icon: Icons.directions_bus, isExpense: true),
  Category(name: 'Развлечения', icon: Icons.movie, isExpense: true),
  Category(name: 'Игры', icon: Icons.sports_esports, isExpense: true),

  Category(name: 'Зарплата', icon: Icons.work, isExpense: false),
  Category(name: 'Карманные', icon: Icons.payments, isExpense: false),
];
