// Файл: lib/common/models/account_model.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

import 'package:flutter/material.dart';

enum AccountType {
  main,
  credit,
  savings;

  String label(bool isRu) {
    return switch (this) {
      AccountType.main => isRu ? 'Основной' : 'Main',
      AccountType.credit => isRu ? 'Кредитный' : 'Credit',
      AccountType.savings => isRu ? 'Накопительный' : 'Savings',
    };
  }

  IconData get icon {
    return switch (this) {
      AccountType.main => Icons.account_balance_wallet_outlined,
      AccountType.credit => Icons.credit_card_outlined,
      AccountType.savings => Icons.savings_outlined,
    };
  }
}

class AccountModel {
  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.creditLimit,
    this.interestRateAnnual,
    this.billingDay,
    this.paymentDay,
    this.summary = '',
    this.isDefault = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final double? creditLimit;
  final double? interestRateAnnual;
  final int? billingDay;
  final int? paymentDay;
  final String summary;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isMain => type == AccountType.main;
  bool get isCredit => type == AccountType.credit;
  bool get isSavings => type == AccountType.savings;

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    double? creditLimit,
    double? interestRateAnnual,
    int? billingDay,
    int? paymentDay,
    String? summary,
    bool? isDefault,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      interestRateAnnual: interestRateAnnual ?? this.interestRateAnnual,
      billingDay: billingDay ?? this.billingDay,
      paymentDay: paymentDay ?? this.paymentDay,
      summary: summary ?? this.summary,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
