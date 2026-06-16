// Файл: lib/common/models/category_model.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class CategoryModel {
  static const _unset = Object();

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

  final String id;
  final String name;
  final bool isExpense;
  final int iconCode;
  final String? parentId;
  final int color;
  final bool isCustom;
  final bool isArchived;
  final int order;
  final String? aiTag;

  bool get isSubcategory => parentId != null;

  IconData get iconData {
    for (final icon in AppTheme.categoryPresetIcons) {
      if (icon.codePoint == iconCode) return icon;
    }
    return Icons.category_outlined;
  }

  Color get colorValue => Color(color);

  CategoryModel copyWith({
    String? name,
    int? iconCode,
    int? color,
    Object? parentId = _unset,
    bool? isCustom,
    bool? isArchived,
    int? order,
    Object? aiTag = _unset,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      isExpense: isExpense,
      parentId: identical(parentId, _unset)
          ? this.parentId
          : parentId as String?,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
      isArchived: isArchived ?? this.isArchived,
      order: order ?? this.order,
      aiTag: identical(aiTag, _unset) ? this.aiTag : aiTag as String?,
    );
  }

  @override
  String toString() =>
      'CategoryModel(id: $id, name: $name, isExpense: $isExpense)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
