enum PaymentFrequency { once, weekly, monthly, yearly }

class PlannedPayment {
  final String id;
  final String userId; // 🔥 Важно для будущей авторизации
  final String title;
  final double amount;
  final String categoryId;
  final String? subcategoryId;
  final DateTime nextPaymentDate;
  final PaymentFrequency frequency;
  final bool isActive;
  final int? remindBeforeDays; // Для уведомлений (1, 3, 7 дней)

  PlannedPayment({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.categoryId,
    this.subcategoryId,
    required this.nextPaymentDate,
    required this.frequency,
    this.isActive = true,
    this.remindBeforeDays,
  });

  // Метод для конвертации в реальную транзакцию
  Transaction toTransaction() {
    return Transaction(
      id: UniqueKey().toString(),
      userId: userId,
      amount: amount,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      date: DateTime.now(),
      // ... остальные поля
    );
  }

  // Метод расчета следующей даты
  DateTime calculateNextDate() {
    switch (frequency) {
      case PaymentFrequency.weekly:
        return DateTime(
          nextPaymentDate.year,
          nextPaymentDate.month,
          nextPaymentDate.day + 7,
        );
      case PaymentFrequency.monthly:
        return DateTime(
          nextPaymentDate.year,
          nextPaymentDate.month + 1,
          nextPaymentDate.day,
        );
      case PaymentFrequency.yearly:
        return DateTime(
          nextPaymentDate.year + 1,
          nextPaymentDate.month,
          nextPaymentDate.day,
        );
      default:
        return nextPaymentDate;
    }
  }
}
