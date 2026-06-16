import 'package:finart_app/common/models/account_model.dart';
import 'package:finart_app/common/models/category_model.dart';
import 'package:finart_app/common/models/transaction_model.dart';
import 'package:finart_app/common/providers/accounts_provider.dart';
import 'package:finart_app/common/providers/categories_provider.dart';
import 'package:finart_app/common/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long press opens transaction edit sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountsProvider.overrideWith((ref) async => _accounts),
          allCategoriesProvider.overrideWith((ref) async => _categories),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TransactionTile(
              transaction: _transaction,
              title: 'Coffee',
              category: 'Food',
              amount: 120,
              isExpense: true,
              categoryIcon: Icons.restaurant_outlined,
              categoryColor: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await tester.longPress(find.text('Coffee'));
    await tester.pumpAndSettle();

    expect(find.text('Редактировать транзакцию'), findsOneWidget);
    expect(find.text('Сумма'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
  });
}

final _transaction = TransactionModel(
  id: 'tx-1',
  amount: 120,
  categoryId: 'food',
  accountId: 'main_account',
  createdAt: DateTime(2026, 5, 26),
  isExpense: true,
  description: 'Coffee',
);

final _accounts = [
  AccountModel(
    id: 'main_account',
    name: 'Main',
    type: AccountType.main,
    balance: 1000,
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
];
