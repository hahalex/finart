// Файл: lib/common/models/account_operation_model.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

enum AccountOperationType {
  topUp,
  withdraw,
  autoPayment,
  interest;

  String label(bool isRu) {
    return switch (this) {
      AccountOperationType.topUp => isRu ? 'Пополнение' : 'Top up',
      AccountOperationType.withdraw => isRu ? 'Снятие' : 'Withdraw',
      AccountOperationType.autoPayment => isRu ? 'Автоплатеж' : 'Auto payment',
      AccountOperationType.interest => isRu ? 'Проценты' : 'Interest',
    };
  }
}

class AccountOperationModel {
  const AccountOperationModel({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    this.note,
    this.plannedPaymentId,
    required this.createdAt,
  });

  final String id;
  final String accountId;
  final AccountOperationType type;
  final double amount;
  final String? note;
  final String? plannedPaymentId;
  final DateTime createdAt;

  AccountOperationModel copyWith({
    String? id,
    String? accountId,
    AccountOperationType? type,
    double? amount,
    String? note,
    bool clearNote = false,
    String? plannedPaymentId,
    bool clearPlannedPaymentId = false,
    DateTime? createdAt,
  }) {
    return AccountOperationModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: clearNote ? null : note ?? this.note,
      plannedPaymentId: clearPlannedPaymentId
          ? null
          : plannedPaymentId ?? this.plannedPaymentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
