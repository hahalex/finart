import 'package:finart_app/common/models/account_model.dart';
import 'package:finart_app/common/models/category_model.dart';
import 'package:finart_app/common/providers/accounts_provider.dart';
import 'package:finart_app/common/providers/categories_provider.dart';
import 'package:finart_app/features/transactions/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows today as default transaction date', (tester) async {
    await tester.pumpWidget(_wrap(const AddTransactionScreen()));
    await tester.pumpAndSettle();

    final today = MaterialLocalizations.of(
      tester.element(find.byType(AddTransactionScreen)),
    ).formatCompactDate(DateTime.now());

    expect(find.text('Date'), findsOneWidget);
    expect(find.text(today), findsOneWidget);
  });

  testWidgets('preselects account passed through initialAccountId', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const AddTransactionScreen(initialAccountId: 'savings')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Savings'), findsOneWidget);
  });
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      accountsProvider.overrideWith((ref) async => _accounts),
      allCategoriesProvider.overrideWith((ref) async => _categories),
    ],
    child: MaterialApp(home: child),
  );
}

final _accounts = [
  AccountModel(
    id: 'main_account',
    name: 'Main',
    type: AccountType.main,
    balance: 1000,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ),
  AccountModel(
    id: 'savings',
    name: 'Savings',
    type: AccountType.savings,
    balance: 5000,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ),
];

const _categories = [
  CategoryModel(
    id: 'food',
    name: 'Food',
    iconCode: 0xe57a,
    isExpense: true,
    color: 0xFFE57373,
  ),
  CategoryModel(
    id: 'salary',
    name: 'Salary',
    iconCode: 0xe8e5,
    isExpense: false,
    color: 0xFF81C784,
  ),
];
