// Файл: lib/features/profile/dev_data_service.dart.
// Назначение: содержит часть логики приложения FinArt.

import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../common/database/app_database.dart';
import '../../common/models/category_model.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/providers/database_provider.dart';

enum DevSeedScenario {
  smallSet,
  largeSet,
  skewedCategories,
  manyPlannedPayments,
  mixedScenario,
  miniForecast,
  miniRecurring,
  miniTrend,
  miniLargeTransaction,
  miniConcentration,
  miniHistoryAnalyzer,
}

class DevSeedResult {
  const DevSeedResult({
    required this.transactionsCreated,
    required this.plannedPaymentsCreated,
    required this.accountsCreated,
  });

  final int transactionsCreated;
  final int plannedPaymentsCreated;
  final int accountsCreated;
}

class DevDataService {
  DevDataService(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Future<DevSeedResult> seedScenario({
    required DevSeedScenario scenario,
    required List<CategoryModel> categories,
  }) async {
    final activeCategories = categories.where((c) => !c.isArchived).toList();
    final expenseCategories = _preferredCategories(
      activeCategories,
      isExpense: true,
    );
    final incomeCategories = _preferredCategories(
      activeCategories,
      isExpense: false,
    );

    if (expenseCategories.isEmpty || incomeCategories.isEmpty) {
      throw Exception('Not enough categories for seeding');
    }

    if (_isMiniScenario(scenario)) {
      return _seedMiniScenario(
        scenario: scenario,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
      );
    }

    final config = _scenarioConfig(scenario);
    final random = Random(DateTime.now().microsecondsSinceEpoch);
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);

    final transactions = <TransactionsTableCompanion>[];
    final plannedPayments = <PlannedPaymentsTableCompanion>[];
    final accounts = <AccountsTableCompanion>[];
    final accountOperations = <AccountOperationsTableCompanion>[];

    for (var dayOffset = 0; dayOffset < config.days; dayOffset++) {
      final date = endDate.subtract(
        Duration(days: config.days - dayOffset - 1),
      );
      final dailyExpenseCount = _randomBetween(
        random,
        config.minDailyExpenses,
        config.maxDailyExpenses,
      );
      final dailyIncomeCount = _randomBetween(
        random,
        config.minDailyIncomes,
        config.maxDailyIncomes,
      );

      for (var i = 0; i < dailyExpenseCount; i++) {
        final category = _pickCategory(
          random,
          expenseCategories,
          weighted: config.skewedTopCategories,
        );

        final amount = _generateAmount(
          random,
          date: date,
          category: category,
          isExpense: true,
          scenario: scenario,
        );

        final createdAt = DateTime(
          date.year,
          date.month,
          date.day,
          _randomBetween(random, 7, 22),
          _randomBetween(random, 0, 59),
        );

        transactions.add(
          TransactionsTableCompanion.insert(
            id: _uuid.v4(),
            amount: amount,
            categoryId: category.id,
            description: Value(_buildDescription(category, true, random)),
            createdAt: createdAt,
            isExpense: true,
          ),
        );
      }

      for (var i = 0; i < dailyIncomeCount; i++) {
        final category = _pickCategory(
          random,
          incomeCategories,
          weighted: false,
        );

        final amount = _generateAmount(
          random,
          date: date,
          category: category,
          isExpense: false,
          scenario: scenario,
        );

        final createdAt = DateTime(
          date.year,
          date.month,
          date.day,
          _randomBetween(random, 7, 22),
          _randomBetween(random, 0, 59),
        );

        transactions.add(
          TransactionsTableCompanion.insert(
            id: _uuid.v4(),
            amount: amount,
            categoryId: category.id,
            description: Value(_buildDescription(category, false, random)),
            createdAt: createdAt,
            isExpense: false,
          ),
        );
      }
    }

    for (var i = 0; i < config.plannedPayments; i++) {
      final isExpense = random.nextDouble() < config.expenseShare;
      final category = _pickCategory(
        random,
        isExpense ? expenseCategories : incomeCategories,
        weighted: isExpense && config.skewedTopCategories,
      );
      final startDate = now.add(Duration(days: _randomBetween(random, 1, 90)));
      final recurrence = _pickRecurrence(random, scenario);

      plannedPayments.add(
        PlannedPaymentsTableCompanion(
          id: Value(_uuid.v4()),
          title: Value(_buildPlannedTitle(category, isExpense, i)),
          amount: Value(
            _generateAmount(
              random,
              date: startDate,
              category: category,
              isExpense: isExpense,
              scenario: scenario,
            ),
          ),
          categoryId: Value(category.id),
          isExpense: Value(isExpense),
          startDate: Value(startDate),
          recurrence: Value(recurrence),
          isActive: const Value(true),
          createdAt: Value(now),
        ),
      );
    }

    if (scenario == DevSeedScenario.manyPlannedPayments ||
        scenario == DevSeedScenario.mixedScenario) {
      final creditAccountId = _uuid.v4();
      final savingsAccountId = _uuid.v4();
      accounts.addAll([
        AccountsTableCompanion(
          id: Value(creditAccountId),
          name: const Value('Demo Credit Card'),
          type: const Value('credit'),
          balance: const Value(24000),
          creditLimit: const Value(120000),
          interestRateAnnual: const Value(24),
          billingDay: const Value(5),
          paymentDay: const Value(25),
          summary: const Value('Demo credit account for linked payments.'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        AccountsTableCompanion(
          id: Value(savingsAccountId),
          name: const Value('Demo Savings'),
          type: const Value('savings'),
          balance: const Value(85000),
          interestRateAnnual: const Value(8),
          summary: const Value('Demo savings account with monthly interest.'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);
      accountOperations.add(
        AccountOperationsTableCompanion.insert(
          id: _uuid.v4(),
          accountId: savingsAccountId,
          type: 'topUp',
          amount: 85000,
          note: const Value('Initial demo savings balance'),
          createdAt: Value(now),
        ),
      );
      if (expenseCategories.isNotEmpty) {
        plannedPayments.add(
          PlannedPaymentsTableCompanion(
            id: Value(_uuid.v4()),
            title: const Value('Demo credit payment'),
            amount: const Value(5000),
            categoryId: Value(expenseCategories.first.id),
            accountId: Value(creditAccountId),
            paymentType: const Value('transfer'),
            isExpense: const Value(true),
            startDate: Value(now.add(const Duration(days: 7))),
            recurrence: const Value('monthly'),
            isActive: const Value(true),
            createdAt: Value(now),
          ),
        );
      }
    }

    await _db.transaction(() async {
      await _db.batch((batch) {
        if (accounts.isNotEmpty) {
          batch.insertAll(_db.accountsTable, accounts);
        }
        if (accountOperations.isNotEmpty) {
          batch.insertAll(_db.accountOperationsTable, accountOperations);
        }
        batch.insertAll(_db.transactionsTable, transactions);
        batch.insertAll(_db.plannedPaymentsTable, plannedPayments);
      });
    });

    return DevSeedResult(
      transactionsCreated: transactions.length,
      plannedPaymentsCreated: plannedPayments.length,
      accountsCreated: accounts.length,
    );
  }

  Future<void> clearGeneratedData() async {
    await _db.transaction(() async {
      await _db.delete(_db.transactionsTable).go();
      await _db.delete(_db.plannedPaymentsTable).go();
      await _db.delete(_db.accountOperationsTable).go();
      await (_db.delete(
        _db.accountsTable,
      )..where((table) => table.id.equals('main_account').not())).go();
      await _db.delete(_db.aiLearning).go();
    });
  }

  Future<DevSeedResult> _seedMiniScenario({
    required DevSeedScenario scenario,
    required List<CategoryModel> expenseCategories,
    required List<CategoryModel> incomeCategories,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final incomeCategory = incomeCategories.first;
    final expenseA = expenseCategories[0];
    final expenseB = expenseCategories.length > 1
        ? expenseCategories[1]
        : expenseA;
    final expenseC = expenseCategories.length > 2
        ? expenseCategories[2]
        : expenseA;
    final expenseD = expenseCategories.length > 3
        ? expenseCategories[3]
        : expenseA;
    final transactions = <TransactionsTableCompanion>[];

    void addTx({
      required DateTime date,
      required double amount,
      required CategoryModel category,
      required bool isExpense,
      required String description,
    }) {
      transactions.add(
        TransactionsTableCompanion.insert(
          id: _uuid.v4(),
          amount: amount,
          categoryId: category.id,
          description: Value(description),
          createdAt: DateTime(date.year, date.month, date.day, 12),
          isExpense: isExpense,
        ),
      );
    }

    void addIncome(DateTime date, double amount) {
      addTx(
        date: date,
        amount: amount,
        category: incomeCategory,
        isExpense: false,
        description: 'Mini income',
      );
    }

    switch (scenario) {
      case DevSeedScenario.miniForecast:
        for (var i = 1; i <= 3; i++) {
          addTx(
            date: _sameDayInMonth(today, -i),
            amount: 900,
            category: expenseA,
            isExpense: true,
            description: 'Mini baseline monthly spending',
          );
        }
        addIncome(today, 12000);
        addTx(
          date: today,
          amount: 5200,
          category: expenseA,
          isExpense: true,
          description: 'Mini current month acceleration',
        );
        break;
      case DevSeedScenario.miniRecurring:
        for (var i = 4; i >= 0; i--) {
          addTx(
            date: _sameDayInMonth(today, -i),
            amount: 650,
            category: expenseA,
            isExpense: true,
            description: 'Mini streaming subscription',
          );
        }
        addIncome(today, 1800);
        break;
      case DevSeedScenario.miniTrend:
        addTx(
          date: _sameDayInMonth(today, -2),
          amount: 700,
          category: expenseA,
          isExpense: true,
          description: 'Mini category trend month 1',
        );
        addTx(
          date: _sameDayInMonth(today, -1),
          amount: 1100,
          category: expenseA,
          isExpense: true,
          description: 'Mini category trend month 2',
        );
        addTx(
          date: today,
          amount: 1700,
          category: expenseA,
          isExpense: true,
          description: 'Mini category trend month 3',
        );
        addIncome(today, 7000);
        break;
      case DevSeedScenario.miniLargeTransaction:
        for (var i = 1; i <= 4; i++) {
          addTx(
            date: _sameDayInMonth(today, -i),
            amount: 220 + i * 10,
            category: expenseA,
            isExpense: true,
            description: 'Mini normal category purchase',
          );
        }
        addIncome(today, 9000);
        addTx(
          date: today,
          amount: 3600,
          category: expenseA,
          isExpense: true,
          description: 'Mini unusually large purchase',
        );
        break;
      case DevSeedScenario.miniConcentration:
        addIncome(today, 5000);
        addTx(
          date: today,
          amount: 1700,
          category: expenseA,
          isExpense: true,
          description: 'Mini top category one',
        );
        addTx(
          date: today,
          amount: 1200,
          category: expenseB,
          isExpense: true,
          description: 'Mini top category two',
        );
        addTx(
          date: today,
          amount: 900,
          category: expenseC,
          isExpense: true,
          description: 'Mini top category three',
        );
        addTx(
          date: today,
          amount: 250,
          category: expenseD,
          isExpense: true,
          description: 'Mini small tail category',
        );
        break;
      case DevSeedScenario.miniHistoryAnalyzer:
        addTx(
          date: _sameDayInMonth(today, -8),
          amount: 450,
          category: expenseA,
          isExpense: true,
          description: 'Mini historical norm early',
        );
        addTx(
          date: _sameDayInMonth(today, -7),
          amount: 520,
          category: expenseA,
          isExpense: true,
          description: 'Mini historical norm later',
        );
        addTx(
          date: _sameDayInMonth(today, -5),
          amount: 1000,
          category: expenseA,
          isExpense: true,
          description: 'Mini previous period expense',
        );
        addTx(
          date: _sameDayInMonth(today, -5),
          amount: 9000,
          category: incomeCategory,
          isExpense: false,
          description: 'Mini previous period income',
        );
        addIncome(today, 5200);
        addTx(
          date: today,
          amount: 2600,
          category: expenseA,
          isExpense: true,
          description: 'Mini current above norm expense',
        );
        break;
      case DevSeedScenario.smallSet:
      case DevSeedScenario.largeSet:
      case DevSeedScenario.skewedCategories:
      case DevSeedScenario.manyPlannedPayments:
      case DevSeedScenario.mixedScenario:
        throw StateError('Mini seeder received a regular scenario');
    }

    await _db.batch((batch) {
      batch.insertAll(_db.transactionsTable, transactions);
    });

    return DevSeedResult(
      transactionsCreated: transactions.length,
      plannedPaymentsCreated: 0,
      accountsCreated: 0,
    );
  }

  Future<DevSeedResult> resetAndSeed({
    required DevSeedScenario scenario,
    required List<CategoryModel> categories,
  }) async {
    await clearGeneratedData();
    return seedScenario(scenario: scenario, categories: categories);
  }

  List<CategoryModel> _preferredCategories(
    List<CategoryModel> categories, {
    required bool isExpense,
  }) {
    final scoped = categories.where((c) => c.isExpense == isExpense).toList();
    final subcategories = scoped.where((c) => c.isSubcategory).toList();
    return subcategories.isNotEmpty ? subcategories : scoped;
  }

  CategoryModel _pickCategory(
    Random random,
    List<CategoryModel> categories, {
    required bool weighted,
  }) {
    if (!weighted || categories.length < 3) {
      return categories[random.nextInt(categories.length)];
    }

    final top = categories.take(3).toList();
    if (random.nextDouble() < 0.72) {
      return top[random.nextInt(top.length)];
    }
    return categories[random.nextInt(categories.length)];
  }

  _SeedConfig _scenarioConfig(DevSeedScenario scenario) {
    return switch (scenario) {
      DevSeedScenario.smallSet => const _SeedConfig(
        days: 365,
        minDailyExpenses: 1,
        maxDailyExpenses: 10,
        minDailyIncomes: 1,
        maxDailyIncomes: 10,
        plannedPayments: 6,
        expenseShare: 0.72,
        skewedTopCategories: false,
      ),
      DevSeedScenario.largeSet => const _SeedConfig(
        days: 365,
        minDailyExpenses: 1,
        maxDailyExpenses: 10,
        minDailyIncomes: 1,
        maxDailyIncomes: 10,
        plannedPayments: 24,
        expenseShare: 0.78,
        skewedTopCategories: false,
      ),
      DevSeedScenario.skewedCategories => const _SeedConfig(
        days: 365,
        minDailyExpenses: 1,
        maxDailyExpenses: 10,
        minDailyIncomes: 1,
        maxDailyIncomes: 10,
        plannedPayments: 14,
        expenseShare: 0.84,
        skewedTopCategories: true,
      ),
      DevSeedScenario.manyPlannedPayments => const _SeedConfig(
        days: 365,
        minDailyExpenses: 1,
        maxDailyExpenses: 10,
        minDailyIncomes: 1,
        maxDailyIncomes: 10,
        plannedPayments: 60,
        expenseShare: 0.70,
        skewedTopCategories: false,
      ),
      DevSeedScenario.mixedScenario => const _SeedConfig(
        days: 365,
        minDailyExpenses: 1,
        maxDailyExpenses: 10,
        minDailyIncomes: 1,
        maxDailyIncomes: 10,
        plannedPayments: 18,
        expenseShare: 0.76,
        skewedTopCategories: true,
      ),
      DevSeedScenario.miniForecast ||
      DevSeedScenario.miniRecurring ||
      DevSeedScenario.miniTrend ||
      DevSeedScenario.miniLargeTransaction ||
      DevSeedScenario.miniConcentration ||
      DevSeedScenario.miniHistoryAnalyzer => throw StateError(
        'Mini scenarios use _seedMiniScenario',
      ),
    };
  }

  bool _isMiniScenario(DevSeedScenario scenario) {
    return switch (scenario) {
      DevSeedScenario.miniForecast ||
      DevSeedScenario.miniRecurring ||
      DevSeedScenario.miniTrend ||
      DevSeedScenario.miniLargeTransaction ||
      DevSeedScenario.miniConcentration ||
      DevSeedScenario.miniHistoryAnalyzer => true,
      _ => false,
    };
  }

  DateTime _sameDayInMonth(DateTime base, int monthOffset) {
    final targetMonth = DateTime(base.year, base.month + monthOffset);
    final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
    final day = base.day.clamp(1, lastDay);
    return DateTime(targetMonth.year, targetMonth.month, day);
  }

  int _randomBetween(Random random, int min, int max) {
    return min + random.nextInt(max - min + 1);
  }

  double _generateAmount(
    Random random, {
    required DateTime date,
    required CategoryModel category,
    required bool isExpense,
    required DevSeedScenario scenario,
  }) {
    if (!isExpense) {
      final base = scenario == DevSeedScenario.largeSet ? 900 : 650;
      final amount = base + random.nextInt(2600) + random.nextDouble() * 99;
      return amount * _incomePeriodMultiplier(date, scenario);
    }

    final expenseBase = switch (scenario) {
      DevSeedScenario.smallSet => 80,
      DevSeedScenario.largeSet => 60,
      DevSeedScenario.skewedCategories => 120,
      DevSeedScenario.manyPlannedPayments => 70,
      DevSeedScenario.mixedScenario => 90,
      DevSeedScenario.miniForecast ||
      DevSeedScenario.miniRecurring ||
      DevSeedScenario.miniTrend ||
      DevSeedScenario.miniLargeTransaction ||
      DevSeedScenario.miniConcentration ||
      DevSeedScenario.miniHistoryAnalyzer => throw StateError(
        'Mini scenarios use fixed amounts',
      ),
    };

    final categoryFactor = _categoryAmountFactor(category);
    final amount =
        expenseBase + random.nextInt(1800) + random.nextDouble() * 99;
    return amount * categoryFactor * _expensePeriodMultiplier(date, scenario);
  }

  double _expensePeriodMultiplier(DateTime date, DevSeedScenario scenario) {
    final ageDays = DateTime.now().difference(date).inDays;
    final monthFactor = 1 + ((date.month % 4) * 0.04);

    final recentFactor = switch (scenario) {
      DevSeedScenario.smallSet => ageDays < 90 ? 1.10 : 1.0,
      DevSeedScenario.largeSet => ageDays < 90 ? 1.22 : 1.0,
      DevSeedScenario.skewedCategories => ageDays < 90 ? 1.42 : 1.0,
      DevSeedScenario.manyPlannedPayments => ageDays < 90 ? 1.08 : 1.0,
      DevSeedScenario.mixedScenario => ageDays < 90 ? 1.48 : 1.0,
      DevSeedScenario.miniForecast ||
      DevSeedScenario.miniRecurring ||
      DevSeedScenario.miniTrend ||
      DevSeedScenario.miniLargeTransaction ||
      DevSeedScenario.miniConcentration ||
      DevSeedScenario.miniHistoryAnalyzer => 1.0,
    };

    final currentMonthSpike =
        ageDays < 31 &&
            (scenario == DevSeedScenario.skewedCategories ||
                scenario == DevSeedScenario.mixedScenario)
        ? 1.18
        : 1.0;

    return monthFactor * recentFactor * currentMonthSpike;
  }

  double _incomePeriodMultiplier(DateTime date, DevSeedScenario scenario) {
    final ageDays = DateTime.now().difference(date).inDays;
    final mildSeasonality = 1 + ((date.month % 3) * 0.03);

    final recentFactor = switch (scenario) {
      DevSeedScenario.mixedScenario => ageDays < 90 ? 0.78 : 1.0,
      DevSeedScenario.skewedCategories => ageDays < 90 ? 0.92 : 1.0,
      DevSeedScenario.miniForecast ||
      DevSeedScenario.miniRecurring ||
      DevSeedScenario.miniTrend ||
      DevSeedScenario.miniLargeTransaction ||
      DevSeedScenario.miniConcentration ||
      DevSeedScenario.miniHistoryAnalyzer => 1.0,
      _ => 1.0,
    };

    return mildSeasonality * recentFactor;
  }

  double _categoryAmountFactor(CategoryModel category) {
    final hash = category.id.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return 0.85 + (hash % 55) / 100;
  }

  String _buildDescription(
    CategoryModel category,
    bool isExpense,
    Random random,
  ) {
    final suffixes = isExpense
        ? ['daily', 'store', 'order', 'check', 'purchase']
        : ['salary', 'bonus', 'transfer', 'refund', 'income'];
    final suffix = suffixes[random.nextInt(suffixes.length)];
    return '${category.name} $suffix';
  }

  String _buildPlannedTitle(CategoryModel category, bool isExpense, int index) {
    final prefix = isExpense ? 'Planned' : 'Expected';
    return '$prefix ${category.name} ${index + 1}';
  }

  String _pickRecurrence(Random random, DevSeedScenario scenario) {
    if (scenario == DevSeedScenario.manyPlannedPayments) {
      return [
        'weekly',
        'every:weeks:2',
        'monthly',
        'every:months:3',
        'weekdays:1,2,3,4,5',
        'yearly',
      ][random.nextInt(6)];
    }
    return [
      'none',
      'weekly',
      'every:weeks:2',
      'monthly',
      'every:months:3',
      'yearly',
    ][random.nextInt(6)];
  }
}

class _SeedConfig {
  const _SeedConfig({
    required this.days,
    required this.minDailyExpenses,
    required this.maxDailyExpenses,
    required this.minDailyIncomes,
    required this.maxDailyIncomes,
    required this.plannedPayments,
    required this.expenseShare,
    required this.skewedTopCategories,
  });

  final int days;
  final int minDailyExpenses;
  final int maxDailyExpenses;
  final int minDailyIncomes;
  final int maxDailyIncomes;
  final int plannedPayments;
  final double expenseShare;
  final bool skewedTopCategories;
}

final devDataServiceProvider = Provider<DevDataService>((ref) {
  final db = ref.watch(databaseProvider);
  return DevDataService(db);
});

final devSeedCategoriesProvider = FutureProvider<List<CategoryModel>>((
  ref,
) async {
  return ref.read(categoriesRepositoryProvider).getAllCategories();
});
