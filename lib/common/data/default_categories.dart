import 'package:flutter/material.dart';
import '../models/category_model.dart';

/// Встроенные категории (будут загружаться при первом запуске)
const List<CategoryModel> defaultCategories = [
  CategoryModel(id: 'food', name: 'Еда', icon: Icons.fastfood, isExpense: true),
  CategoryModel(
    id: 'transport',
    name: 'Транспорт',
    icon: Icons.directions_bus,
    isExpense: true,
  ),
  CategoryModel(
    id: 'entertainment',
    name: 'Развлечения',
    icon: Icons.movie,
    isExpense: true,
  ),
  CategoryModel(
    id: 'games',
    name: 'Игры',
    icon: Icons.sports_esports,
    isExpense: true,
  ),
  CategoryModel(
    id: 'salary',
    name: 'Зарплата',
    icon: Icons.work,
    isExpense: false,
  ),
  CategoryModel(
    id: 'other_income',
    name: 'Прочее',
    icon: Icons.payments,
    isExpense: false,
  ),
];
