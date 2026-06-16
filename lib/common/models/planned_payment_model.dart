// Файл: lib/common/models/planned_payment_model.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

import '../utils/recurrence_rule.dart';

class PlannedPaymentModel {
  PlannedPaymentModel({
    required this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.categoryId,
    this.accountId,
    this.paymentType = PlannedPaymentType.standard,
    required this.isExpense,
    required this.startDate,
    required this.recurrence,
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String? userId;
  final String title;
  final double amount;
  final String categoryId;
  final String? accountId;
  final PlannedPaymentType paymentType;
  final bool isExpense;
  final DateTime startDate;
  final String recurrence;
  final bool isActive;
  final DateTime createdAt;

  DateTime getNextPaymentDate() {
    return RecurrenceRule.parse(recurrence).nextAfter(startDate);
  }

  DateTime getNextOccurrenceOnOrAfter(DateTime from) {
    return RecurrenceRule.parse(
      recurrence,
    ).firstOccurrenceOnOrAfter(startDate, from);
  }

  PlannedPaymentModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? categoryId,
    String? accountId,
    bool clearAccountId = false,
    PlannedPaymentType? paymentType,
    bool? isExpense,
    DateTime? startDate,
    String? recurrence,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PlannedPaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: clearAccountId ? null : accountId ?? this.accountId,
      paymentType: paymentType ?? this.paymentType,
      isExpense: isExpense ?? this.isExpense,
      startDate: startDate ?? this.startDate,
      recurrence: recurrence ?? this.recurrence,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'PlannedPaymentModel(title: $title, amount: $amount)';
}

enum PlannedPaymentType {
  standard,
  transfer;

  bool get isTransfer => this == PlannedPaymentType.transfer;
}
