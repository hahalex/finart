import 'dart:io';

import 'package:finart_app/common/data/default_categories.dart';
import 'package:finart_app/common/localization/app_language.dart';
import 'package:finart_app/common/models/account_model.dart';
import 'package:finart_app/common/models/category_model.dart';
import 'package:finart_app/common/models/transaction_model.dart';
import 'package:finart_app/common/providers/accounts_provider.dart';
import 'package:finart_app/common/providers/categories_provider.dart';
import 'package:finart_app/common/providers/transactions_repository_provider.dart';
import 'package:finart_app/common/repositories/transactions_repository.dart';
import 'package:finart_app/common/utils/app_theme.dart';
import 'package:finart_app/common/widgets/main_navigation.dart';
import 'package:finart_app/features/analytics/domain/analytics_calculator.dart';
import 'package:finart_app/features/analytics/providers/analytics_provider.dart';
import 'package:finart_app/features/profile/data/user_repository.dart';
import 'package:finart_app/features/profile/domain/user_model.dart';
import 'package:finart_app/features/profile/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _navigationBudget = Duration(milliseconds: 300);
const _chartBuildBudget = Duration(seconds: 1);
const _memoryBudgetBytes = 200 * 1024 * 1024;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<CategoryModel> categories;
  late List<TransactionModel> transactions;
  late List<AccountModel> accounts;

  setUpAll(() {
    categories = [
      ...buildDefaultCategories(AppLanguage.english),
      ...buildDefaultSubcategories(AppLanguage.english),
    ];
    transactions = _buildTransactions(categories, days: 365, perDay: 12);
    accounts = [
      AccountModel(
        id: 'main_account',
        name: 'Main',
        type: AccountType.main,
        balance: 125000,
        isDefault: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];
  });

  testWidgets('tab transitions complete within 300 ms', (tester) async {
    await tester.pumpWidget(
      _performanceApp(transactions, categories, accounts),
    );
    await tester.pump();

    final transitionTimes = <Duration>[];
    for (final index in [1, 2, 3, 4, 0]) {
      final stopwatch = Stopwatch()..start();
      await tester.tap(find.byType(NavigationDestination).at(index));
      await tester.pump();
      stopwatch.stop();
      transitionTimes.add(stopwatch.elapsed);
    }

    final slowest = transitionTimes.reduce((a, b) => a > b ? a : b);
    expect(
      slowest,
      lessThanOrEqualTo(_navigationBudget),
      reason: 'Slowest tab transition was ${slowest.inMilliseconds} ms.',
    );
  });

  test('chart data builds within 1 second', () {
    final expenses = transactions.where((tx) => tx.isExpense).toList();
    final stopwatch = Stopwatch()..start();

    final byDay = AnalyticsCalculator.expensesByDay(expenses);
    final byWeek = AnalyticsCalculator.expensesByWeek(expenses, isRu: false);
    final byMonth = AnalyticsCalculator.expensesByMonth(expenses);
    final byCategory = AnalyticsCalculator.expensesByCategory(expenses);
    final anomalies = AnalyticsCalculator.detectAnomalyIndexes(byDay);

    stopwatch.stop();

    expect(byDay, isNotEmpty);
    expect(byWeek, isNotEmpty);
    expect(byMonth, isNotEmpty);
    expect(byCategory, isNotEmpty);
    expect(anomalies.length, greaterThanOrEqualTo(0));
    expect(
      stopwatch.elapsed,
      lessThanOrEqualTo(_chartBuildBudget),
      reason: 'Chart data build took ${stopwatch.elapsedMilliseconds} ms.',
    );
  });

  testWidgets('performance scenario adds no more than 200 MB RSS', (
    tester,
  ) async {
    final baselineRss = ProcessInfo.currentRss;

    await tester.pumpWidget(
      _performanceApp(transactions, categories, accounts),
    );
    await tester.pump();

    for (final index in [1, 3, 4, 0]) {
      await tester.tap(find.byType(NavigationDestination).at(index));
      await tester.pump();
    }

    final rss = ProcessInfo.currentRss;
    final delta = rss - baselineRss;
    expect(
      delta,
      lessThanOrEqualTo(_memoryBudgetBytes),
      reason:
          'Scenario RSS delta is ${(delta / 1024 / 1024).toStringAsFixed(1)} MB. '
          'Current test-process RSS is ${(rss / 1024 / 1024).toStringAsFixed(1)} MB. '
          'Budget is 200 MB additional RSS.',
    );
  });
}

Widget _performanceApp(
  List<TransactionModel> transactions,
  List<CategoryModel> categories,
  List<AccountModel> accounts,
) {
  return ProviderScope(
    overrides: [
      transactionsRepositoryProvider.overrideWith(
        (ref) => _FakeTransactionsRepository(transactions),
      ),
      allCategoriesProvider.overrideWith((ref) async => categories),
      accountsProvider.overrideWith((ref) async => accounts),
      userRepositoryProvider.overrideWith((ref) => _FakeUserRepository()),
      chartDataProvider.overrideWith(
        (ref) async => AnalyticsCalculator.expensesByWeek(
          transactions.where((tx) => tx.isExpense).toList(),
          isRu: false,
        ),
      ),
      categoryExpensesProvider.overrideWith(
        (ref) async => AnalyticsCalculator.expensesByCategory(
          transactions.where((tx) => tx.isExpense).toList(),
        ),
      ),
      analyticsComparisonProvider.overrideWith((ref) async => null),
      chartTrendValueProvider.overrideWith((ref) async => null),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('en'),
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainNavigation(),
    ),
  );
}

List<TransactionModel> _buildTransactions(
  List<CategoryModel> categories, {
  required int days,
  required int perDay,
}) {
  final expenseCategories = categories.where((c) => c.isExpense).toList();
  final incomeCategories = categories.where((c) => !c.isExpense).toList();
  final start = DateTime(2026, 1, 1);
  final result = <TransactionModel>[];

  for (var day = 0; day < days; day++) {
    final date = start.add(Duration(days: day));
    for (var index = 0; index < perDay; index++) {
      final isExpense = index % 5 != 0;
      final pool = isExpense ? expenseCategories : incomeCategories;
      final category = pool[(day + index) % pool.length];
      result.add(
        TransactionModel(
          id: 'tx_${day}_$index',
          amount: isExpense
              ? 80 + ((day + index) % 900).toDouble()
              : 1200 + ((day + index) % 2400).toDouble(),
          categoryId: category.id,
          createdAt: DateTime(date.year, date.month, date.day, 8 + index % 12),
          isExpense: isExpense,
          description: isExpense ? 'Expense $index' : 'Income $index',
        ),
      );
    }
  }

  return result;
}

class _FakeTransactionsRepository implements TransactionsRepository {
  _FakeTransactionsRepository(this.transactions);

  final List<TransactionModel> transactions;

  @override
  Future<List<TransactionModel>> getAllTransactions() async => transactions;

  @override
  Future<void> insertTransaction(TransactionModel transaction) async {}

  @override
  Future<void> deleteTransaction(String id) async {}

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {}
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<UserModel?> getUser() async =>
      const UserModel(id: '1', name: 'Perf Test');

  @override
  Future<void> saveUser(UserModel user) async {}
}
