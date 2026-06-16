import 'package:finart_app/common/utils/app_theme.dart';
import 'package:finart_app/common/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('summary cards are ordered as income balance expenses', (
    tester,
  ) async {
    await tester.pumpWidget(_summaryRow());

    final income = tester.getTopLeft(find.text('Income')).dx;
    final balance = tester.getTopLeft(find.text('Balance')).dx;
    final expenses = tester.getTopLeft(find.text('Expenses')).dx;

    expect(income, lessThan(balance));
    expect(balance, lessThan(expenses));
  });

  testWidgets('summary card row matches golden', (tester) async {
    await tester.pumpWidget(_summaryRow());

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/summary_card_row.png'),
    );
  });
}

Widget _summaryRow() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
          child: Row(
            children: const [
              SummaryCard(
                title: 'Income',
                amount: 1000,
                color: Colors.green,
                icon: Icons.arrow_downward_rounded,
              ),
              SummaryCard(
                title: 'Balance',
                amount: 700,
                color: Colors.blue,
                icon: Icons.account_balance_wallet_outlined,
              ),
              SummaryCard(
                title: 'Expenses',
                amount: 300,
                color: Colors.red,
                icon: Icons.arrow_upward_rounded,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
