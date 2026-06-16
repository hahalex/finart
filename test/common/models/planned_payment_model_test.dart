import 'package:finart_app/common/models/planned_payment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlannedPaymentModel', () {
    test('calculates the next active recurring occurrence', () {
      final payment = PlannedPaymentModel(
        id: 'planned-1',
        title: 'Rent',
        amount: 1200,
        categoryId: 'housing',
        isExpense: true,
        startDate: DateTime(2026, 1, 31),
        recurrence: 'monthly',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(
        payment.getNextOccurrenceOnOrAfter(DateTime(2026, 2, 15)),
        DateTime(2026, 2, 28),
      );
    });

    test('keeps one-time payments at their start date', () {
      final payment = PlannedPaymentModel(
        id: 'planned-2',
        title: 'Gift',
        amount: 50,
        categoryId: 'gift',
        isExpense: false,
        startDate: DateTime(2026, 5, 1),
        recurrence: 'none',
        createdAt: DateTime(2026, 4, 1),
      );

      expect(
        payment.getNextOccurrenceOnOrAfter(DateTime(2026, 5, 23)),
        DateTime(2026, 5, 1),
      );
    });
  });
}
