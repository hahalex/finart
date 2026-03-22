/// Модель запланированного платежа (доход или расход в будущем)
class PlannedPaymentModel {
  final String id;
  final String? userId;
  final String title;
  final double amount;
  final String categoryId;
  final bool isExpense;
  final DateTime startDate;
  final String recurrence; // 'none', 'daily', 'weekly', 'monthly', 'yearly'
  final bool isActive;
  final DateTime createdAt;

  PlannedPaymentModel({
    required this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.isExpense,
    required this.startDate,
    required this.recurrence,
    this.isActive = true,
    required this.createdAt,
  });

  /// Вычисляет следующую дату платежа на основе периодичности
  DateTime getNextPaymentDate() {
    switch (recurrence) {
      case 'daily':
        return startDate.add(const Duration(days: 1));
      case 'weekly':
        return startDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case 'yearly':
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      default:
        return startDate;
    }
  }

  /// Создаёт копию модели с изменёнными полями
  PlannedPaymentModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? categoryId,
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
