import 'package:finart_app/common/models/account_model.dart';
import 'package:finart_app/common/services/account_calculation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = AccountCalculationService();

  group('AccountCalculationService', () {
    test('calculates monthly interest from annual rate', () {
      expect(service.monthlyInterest(120000, 12), 1200);
      expect(service.monthlyInterest(-120000, 12), 1200);
    });

    test('calculates recommended credit payment', () {
      expect(
        service.creditRecommendedPayment(balance: 100000, annualRate: 12),
        6000,
      );
    });

    test('builds saved credit summary with payment dates', () {
      final account = AccountModel(
        id: 'credit',
        name: 'Credit card',
        type: AccountType.credit,
        balance: -100000,
        interestRateAnnual: 12,
        billingDay: 5,
        paymentDay: 25,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final summary = service.buildSummary(account, isRu: true);

      expect(summary, contains('Кредитный счет'));
      expect(summary, contains('День выписки: 5'));
      expect(summary, contains('день платежа: 25'));
      expect(summary, contains('6000.00'));
    });

    test('builds savings summary with monthly accrual', () {
      final account = AccountModel(
        id: 'savings',
        name: 'Savings',
        type: AccountType.savings,
        balance: 120000,
        interestRateAnnual: 12,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final summary = service.buildSummary(account, isRu: true);

      expect(summary, contains('Накопительный счет'));
      expect(summary, contains('1200.00'));
    });
  });
}
