import 'package:flutter/material.dart';
import '../models/category_model.dart';

/// Стандартные категории с новыми полями (для первой инициализации)
final defaultCategories = [
  // 🔻 РАСХОДЫ
  CategoryModel(
    id: 'food',
    name: 'Еда',
    iconCode: Icons.fastfood.codePoint,
    isExpense: true,
    color: 0xFFFF9800, // оранжевый
    order: 0,
    aiTag: 'food',
  ),
  CategoryModel(
    id: 'transport',
    name: 'Транспорт',
    iconCode: Icons.directions_bus.codePoint,
    isExpense: true,
    color: 0xFF2196F3, // синий
    order: 1,
    aiTag: 'transport',
  ),
  CategoryModel(
    id: 'entertainment',
    name: 'Развлечения',
    iconCode: Icons.movie.codePoint,
    isExpense: true,
    color: 0xFF9C27B0, // фиолетовый
    order: 2,
    aiTag: 'entertainment',
  ),
  CategoryModel(
    id: 'games',
    name: 'Игры',
    iconCode: Icons.sports_esports.codePoint,
    isExpense: true,
    color: 0xFF4CAF50, // зелёный
    order: 3,
    aiTag: 'entertainment',
  ),
  CategoryModel(
    id: 'subscriptions',
    name: 'Подписки',
    iconCode: Icons.repeat.codePoint,
    isExpense: true,
    color: 0xFF607D8B, // серо-синий
    order: 4,
    aiTag: 'subscriptions',
  ),

  // 🔺 ДОХОДЫ
  CategoryModel(
    id: 'salary',
    name: 'Зарплата',
    iconCode: Icons.payments.codePoint,
    isExpense: false,
    color: 0xFF4CAF50,
    order: 0,
    aiTag: 'income',
  ),
  CategoryModel(
    id: 'gift',
    name: 'Подарок',
    iconCode: Icons.card_giftcard.codePoint,
    isExpense: false,
    color: 0xFFE91E63,
    order: 1,
    aiTag: 'income',
  ),
];

/// 🔹 Helper: создать подкатегорию для дефолтной категории
CategoryModel createSubcategory({
  required String id,
  required String name,
  required IconData icon,
  required String parentId,
  required bool isExpense,
  int color = 0xFF90A4AE,
  String? aiTag,
}) {
  return CategoryModel(
    id: id,
    name: name,
    iconCode: icon.codePoint,
    isExpense: isExpense,
    parentId: parentId,
    color: color,
    isCustom: false,
    order: 0,
    aiTag: aiTag,
  );
}

/// 🔹 Пример подкатегорий (можно использовать при расширении)
final defaultSubcategories = [
  // Еда → подкатегории
  createSubcategory(
    id: 'food_cafe',
    name: 'Кафе',
    icon: Icons.local_cafe,
    parentId: 'food',
    isExpense: true,
    color: 0xFFFFB74D,
    aiTag: 'food',
  ),
  createSubcategory(
    id: 'food_groceries',
    name: 'Продукты',
    icon: Icons.shopping_cart,
    parentId: 'food',
    isExpense: true,
    color: 0xFFFF9800,
    aiTag: 'food',
  ),

  // Транспорт → подкатегории
  createSubcategory(
    id: 'transport_public',
    name: 'Общественный',
    icon: Icons.directions_bus,
    parentId: 'transport',
    isExpense: true,
    aiTag: 'transport',
  ),
  createSubcategory(
    id: 'transport_taxi',
    name: 'Такси',
    icon: Icons.local_taxi,
    parentId: 'transport',
    isExpense: true,
    aiTag: 'transport',
  ),
];
