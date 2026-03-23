import 'package:flutter/material.dart';

/// Модель категории с поддержкой подкатегорий, цветов и AI-тегов
class CategoryModel {
  final String id;
  final String name;
  final bool isExpense;

  /// 🔹 Хранится как int (codePoint), конвертируется в IconData при необходимости
  final int iconCode;

  /// 🔹 NEW: Родительская категория (для подкатегорий)
  final String? parentId;

  /// 🔹 NEW: Цвет в формате 0xFFRRGGBB
  final int color;

  /// 🔹 NEW: Пользовательская категория (дефолтные = false)
  final bool isCustom;

  /// 🔹 NEW: Архивная (мягкое удаление)
  final bool isArchived;

  /// 🔹 NEW: Порядок сортировки
  final int order;

  /// 🔹 NEW: AI-тег для аналитики
  final String? aiTag;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.isExpense,
    this.parentId,
    required this.color,
    this.isCustom = false,
    this.isArchived = false,
    this.order = 0,
    this.aiTag,
  });

  /// ✅ Геттер: является ли подкатегорией
  bool get isSubcategory => parentId != null;

  /// ✅ Геттер: конвертация в IconData (Material Icons)
  IconData get iconData => IconData(iconCode, fontFamily: 'MaterialIcons');

  /// ✅ Геттер: конвертация в Color
  Color get colorValue => Color(color);

  /// ✅ copyWith для неизменяемых обновлений
  CategoryModel copyWith({
    String? name,
    int? iconCode,
    int? color,
    String? parentId,
    bool? isCustom,
    bool? isArchived,
    int? order,
    String? aiTag,
  }) {
    return CategoryModel(
      id: id, // id неизменяем
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      isExpense: isExpense,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
      isArchived: isArchived ?? this.isArchived,
      order: order ?? this.order,
      aiTag: aiTag ?? this.aiTag,
    );
  }

  /// ✅ Для отладки
  @override
  String toString() =>
      'CategoryModel(id: $id, name: $name, isExpense: $isExpense)';

  /// ✅ Для сравнения в списках
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
