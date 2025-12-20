import 'package:flutter/material.dart';
import '../models/category_model.dart';

/// Стандартные категории приложения
final defaultCategories = [
  // Расходы
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

  // Доходы
  CategoryModel(
    id: 'salary',
    name: 'Зарплата',
    icon: Icons.payments,
    isExpense: false,
  ),
  CategoryModel(
    id: 'gift',
    name: 'Подарок',
    icon: Icons.card_giftcard,
    isExpense: false,
  ),
];
