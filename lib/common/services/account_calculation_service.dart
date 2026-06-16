// Файл: lib/common/services/account_calculation_service.dart.
// Назначение: содержит прикладной сервис с бизнес-логикой, фоновой обработкой или интеграциями.

import '../models/account_model.dart';

class AccountCalculationService {
  const AccountCalculationService();

  double monthlyInterest(double balance, double annualRate) {
    return balance.abs() * annualRate / 100 / 12;
  }

  double creditRecommendedPayment({
    required double balance,
    required double annualRate,
    double minimumPrincipalShare = 0.05,
  }) {
    final normalizedBalance = balance.abs();
    final principal = normalizedBalance * minimumPrincipalShare;
    final interest = monthlyInterest(normalizedBalance, annualRate);
    return principal + interest;
  }

  String buildSummary(AccountModel account, {required bool isRu}) {
    final rate = account.interestRateAnnual ?? 0;
    final balance = account.balance.abs();

    if (account.isMain) {
      return isRu
          ? 'Основной счет используется для обычных записей и плановых платежей. Его баланс автоматически синхронизируется с балансом записей за выбранный месяц. Операции по кредитным и накопительным счетам в этот баланс не смешиваются.'
          : 'The main account is used for regular entries and upcoming payments. Its balance is synced with the entries balance for the selected month. Credit and savings account operations are kept separate.';
    }

    if (account.isCredit) {
      final payment = creditRecommendedPayment(
        balance: balance,
        annualRate: rate,
      );
      final billing =
          account.billingDay?.toString() ?? (isRu ? 'не выбран' : 'not set');
      final paymentDay =
          account.paymentDay?.toString() ?? (isRu ? 'не выбран' : 'not set');
      final limit = account.creditLimit;
      final available = limit == null ? null : limit - account.balance;
      final limitText = limit == null
          ? (isRu ? 'лимит не указан' : 'limit is not set')
          : (isRu
                ? 'лимит ${limit.toStringAsFixed(2)}, доступно примерно ${available!.toStringAsFixed(2)}'
                : 'limit ${limit.toStringAsFixed(2)}, available about ${available!.toStringAsFixed(2)}');
      return isRu
          ? 'Кредитный счет. Текущий баланс ${account.balance.toStringAsFixed(2)}, $limitText. Ставка ${rate.toStringAsFixed(2)}% годовых. День выписки: $billing, день платежа: $paymentDay. Ориентировочный ежемесячный процент: ${monthlyInterest(balance, rate).toStringAsFixed(2)}. Рекомендуемый платеж с учетом 5% тела долга: ${payment.toStringAsFixed(2)}. При привязке регулярного платежа перевод списывается с основного счета и увеличивает баланс этого кредитного счета.'
          : 'Credit account. Current balance ${account.balance.toStringAsFixed(2)}, $limitText. Annual rate ${rate.toStringAsFixed(2)}%. Billing day: $billing, payment day: $paymentDay. Estimated monthly interest: ${monthlyInterest(balance, rate).toStringAsFixed(2)}. Recommended payment with 5% principal share: ${payment.toStringAsFixed(2)}. A linked recurring payment deducts from the main account and increases this credit account balance.';
    }

    final monthly = monthlyInterest(balance, rate);
    return isRu
        ? 'Накопительный счет. Текущий баланс ${account.balance.toStringAsFixed(2)}. Ставка ${rate.toStringAsFixed(2)}% годовых. Ориентировочное начисление в месяц: ${monthly.toStringAsFixed(2)}. Пополнения и снятия хранятся в истории счета и не попадают в общий список Записи.'
        : 'Savings account. Current balance ${account.balance.toStringAsFixed(2)}. Annual rate ${rate.toStringAsFixed(2)}%. Estimated monthly interest: ${monthly.toStringAsFixed(2)}. Top-ups and withdrawals are stored in the account history and do not appear in Entries.';
  }
}
