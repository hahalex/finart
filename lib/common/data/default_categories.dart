// Файл: lib/common/data/default_categories.dart.
// Назначение: хранит исходные данные, локальные таблицы или вспомогательный слой данных.

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/category_model.dart';
import '../utils/app_theme.dart';

List<CategoryModel> buildDefaultCategories(AppLanguage language) {
  final isRu = language == AppLanguage.russian;

  return [
    CategoryModel(
      id: 'food',
      name: isRu ? 'Еда' : 'Food',
      iconCode: Icons.fastfood.codePoint,
      isExpense: true,
      color: _presetColorValue(1),
      order: 0,
      aiTag: 'food',
    ),
    CategoryModel(
      id: 'transport',
      name: isRu ? 'Транспорт' : 'Transport',
      iconCode: Icons.directions_bus.codePoint,
      isExpense: true,
      color: _presetColorValue(7),
      order: 1,
      aiTag: 'transport',
    ),
    CategoryModel(
      id: 'entertainment',
      name: isRu ? 'Развлечения' : 'Entertainment',
      iconCode: Icons.movie.codePoint,
      isExpense: true,
      color: _presetColorValue(11),
      order: 2,
      aiTag: 'entertainment',
    ),
    CategoryModel(
      id: 'games',
      name: isRu ? 'Игры' : 'Games',
      iconCode: Icons.sports_esports.codePoint,
      isExpense: true,
      color: _presetColorValue(4),
      order: 3,
      aiTag: 'entertainment',
    ),
    CategoryModel(
      id: 'subscriptions',
      name: isRu ? 'Подписки' : 'Subscriptions',
      iconCode: Icons.repeat.codePoint,
      isExpense: true,
      color: _presetColorValue(16),
      order: 4,
      aiTag: 'subscriptions',
    ),
    CategoryModel(
      id: 'salary',
      name: isRu ? 'Зарплата' : 'Salary',
      iconCode: Icons.payments.codePoint,
      isExpense: false,
      color: _presetColorValue(5),
      order: 0,
      aiTag: 'income',
    ),
    CategoryModel(
      id: 'gift',
      name: isRu ? 'Подарок' : 'Gift',
      iconCode: Icons.card_giftcard.codePoint,
      isExpense: false,
      color: _presetColorValue(13),
      order: 1,
      aiTag: 'income',
    ),
  ];
}

List<CategoryModel> buildDefaultSubcategories(AppLanguage language) {
  final isRu = language == AppLanguage.russian;

  return [
    CategoryModel(
      id: 'food_cafe',
      name: isRu ? 'Кафе' : 'Cafe',
      iconCode: Icons.local_cafe.codePoint,
      parentId: 'food',
      isExpense: true,
      color: _presetColorValue(0),
      isCustom: false,
      order: 0,
      aiTag: 'food',
    ),
    CategoryModel(
      id: 'food_groceries',
      name: isRu ? 'Продукты' : 'Groceries',
      iconCode: Icons.shopping_cart.codePoint,
      parentId: 'food',
      isExpense: true,
      color: _presetColorValue(1),
      isCustom: false,
      order: 1,
      aiTag: 'food',
    ),
    CategoryModel(
      id: 'transport_public',
      name: isRu ? 'Общественный транспорт' : 'Public transport',
      iconCode: Icons.directions_bus.codePoint,
      parentId: 'transport',
      isExpense: true,
      color: _presetColorValue(8),
      isCustom: false,
      order: 0,
      aiTag: 'transport',
    ),
    CategoryModel(
      id: 'transport_taxi',
      name: isRu ? 'Такси' : 'Taxi',
      iconCode: Icons.local_taxi.codePoint,
      parentId: 'transport',
      isExpense: true,
      color: _presetColorValue(9),
      isCustom: false,
      order: 1,
      aiTag: 'transport',
    ),
  ];
}

int _presetColorValue(int index) {
  return AppTheme.lightCategoryPresetColors[index].toARGB32();
}
