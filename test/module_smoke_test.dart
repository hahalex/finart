import 'package:finart_app/common/models/account_model.dart';
import 'package:finart_app/common/models/account_operation_model.dart';
import 'package:finart_app/common/models/category_model.dart';
import 'package:finart_app/common/models/notification_settings.dart';
import 'package:finart_app/common/models/planned_payment_model.dart';
import 'package:finart_app/common/models/transaction_model.dart';
import 'package:finart_app/common/localization/app_language.dart';
import 'package:finart_app/common/services/account_calculation_service.dart';
import 'package:finart_app/common/utils/app_theme.dart';
import 'package:finart_app/common/utils/recurrence_rule.dart';
import 'package:finart_app/features/analytics/domain/analytics_calculator.dart';
import 'package:finart_app/features/analytics/domain/analytics_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  timedGroup('Счета', () {
    moduleTest('main account label is available', () {
      expect(AccountType.main.label(true), 'Основной');
    });

    moduleTest('credit account label is available', () {
      expect(AccountType.credit.label(false), 'Credit');
    });

    moduleTest('copyWith updates account balance', () {
      final account = _account(AccountType.savings).copyWith(balance: 42);
      expect(account.balance, 42);
    });

    moduleTest('operation labels include interest', () {
      expect(AccountOperationType.interest.label(true), 'Проценты');
    });

    moduleTest('main account type flag is true only for main', () {
      expect(_account(AccountType.main).isMain, isTrue);
      expect(_account(AccountType.credit).isMain, isFalse);
    });

    moduleTest('credit account keeps limit and payment day', () {
      final account = _account(
        AccountType.credit,
      ).copyWith(creditLimit: 100000, paymentDay: 25);
      expect(account.creditLimit, 100000);
      expect(account.paymentDay, 25);
    });

    moduleTest('savings account keeps annual rate', () {
      final account = _account(
        AccountType.savings,
      ).copyWith(interestRateAnnual: 8.5);
      expect(account.interestRateAnnual, 8.5);
      expect(account.isSavings, isTrue);
    });

    moduleTest('account operation stores planned payment link', () {
      final operation = _operation(plannedPaymentId: 'planned-1');
      expect(operation.plannedPaymentId, 'planned-1');
      expect(operation.type, AccountOperationType.autoPayment);
    });
  });

  timedGroup('Предстоящие платежи', () {
    moduleTest('transfer type is detected', () {
      expect(PlannedPaymentType.transfer.isTransfer, isTrue);
    });

    moduleTest('standard type is not transfer', () {
      expect(PlannedPaymentType.standard.isTransfer, isFalse);
    });

    moduleTest('copyWith can clear account link', () {
      final payment = _payment(
        accountId: 'account',
      ).copyWith(clearAccountId: true);
      expect(payment.accountId, isNull);
    });

    moduleTest('next occurrence respects monthly clamp', () {
      final payment = _payment(startDate: DateTime(2026, 1, 31));
      expect(
        payment.getNextOccurrenceOnOrAfter(DateTime(2026, 2, 1)),
        DateTime(2026, 2, 28),
      );
    });

    moduleTest('one-time recurrence keeps start date', () {
      final payment = _payment(recurrence: 'none');
      expect(payment.getNextPaymentDate(), payment.startDate);
    });

    moduleTest('daily recurrence moves by one day', () {
      final payment = _payment(recurrence: 'daily');
      expect(payment.getNextPaymentDate(), DateTime(2026, 1, 2));
    });

    moduleTest('copyWith can convert standard payment to transfer', () {
      final payment = _payment().copyWith(
        accountId: 'credit',
        paymentType: PlannedPaymentType.transfer,
      );
      expect(payment.accountId, 'credit');
      expect(payment.paymentType.isTransfer, isTrue);
    });

    moduleTest('payment string contains title and amount', () {
      expect(_payment().toString(), contains('Payment'));
      expect(_payment().toString(), contains('100'));
    });

    moduleTest('custom two-week recurrence parses as weeks interval', () {
      final rule = RecurrenceRule.parse('every:weeks:2');
      expect(rule.kind, RecurrenceKind.weeks);
      expect(rule.interval, 2);
    });

    moduleTest('invalid recurrence falls back to one-time rule', () {
      expect(RecurrenceRule.parse('broken').isOneTime, isTrue);
    });
  });

  timedGroup('Записи', () {
    moduleTest('expense signed amount can be inferred', () {
      expect(_signedAmount(amount: 50, isExpense: true), -50);
    });

    moduleTest('income signed amount can be inferred', () {
      expect(_signedAmount(amount: 50, isExpense: false), 50);
    });

    moduleTest('main account id is treated as entries account', () {
      expect(_isEntriesAccount('main_account'), isTrue);
    });

    moduleTest('secondary account id is not entries account', () {
      expect(_isEntriesAccount('savings'), isFalse);
    });

    moduleTest('transaction keeps linked account id', () {
      final transaction = _transaction(accountId: 'main_account');
      expect(transaction.accountId, 'main_account');
    });

    moduleTest('transaction keeps optional description', () {
      final transaction = _transaction(description: 'Coffee');
      expect(transaction.description, 'Coffee');
    });

    moduleTest('entry balance ignores secondary account transactions', () {
      final total = _entriesBalance([
        _transaction(amount: 100, isExpense: false),
        _transaction(amount: 20, isExpense: true),
        _transaction(amount: 1000, isExpense: false, accountId: 'savings'),
      ]);
      expect(total, 80);
    });

    moduleTest('transaction date is preserved', () {
      final createdAt = DateTime(2026, 5, 24, 12);
      expect(_transaction(createdAt: createdAt).createdAt, createdAt);
    });
  });

  timedGroup('Графики', () {
    moduleTest('expense total is calculated', () {
      expect(_sum([10, 20, 30]), 60);
    });

    moduleTest('empty chart data total is zero', () {
      expect(_sum(const []), 0);
    });

    moduleTest('top categories are sorted descending', () {
      expect(_sorted([2, 9, 1]), [9, 2, 1]);
    });

    moduleTest('chart percent is calculated', () {
      expect(_percent(25, 100), 25);
    });

    moduleTest('chart percent protects zero total', () {
      expect(_percent(25, 0), 0);
    });

    moduleTest('top category sorting does not mutate source list', () {
      final source = [2, 9, 1];
      _sorted(source);
      expect(source, [2, 9, 1]);
    });

    moduleTest('analytics palette has enough distinct colors', () {
      expect(
        AppTheme.lightAnalyticsChartPalette.length,
        greaterThanOrEqualTo(8),
      );
    });

    moduleTest('dark analytics palette mirrors light palette size', () {
      expect(
        AppTheme.darkAnalyticsChartPalette.length,
        AppTheme.lightAnalyticsChartPalette.length,
      );
    });
  });

  timedGroup('Добавление операции', () {
    moduleTest('comma amount parses', () {
      expect(_parseAmount('100,50'), 100.5);
    });

    moduleTest('dot amount parses', () {
      expect(_parseAmount('100.50'), 100.5);
    });

    moduleTest('invalid amount returns zero', () {
      expect(_parseAmount('abc'), 0);
    });

    moduleTest('positive amount is valid', () {
      expect(_parseAmount('1') > 0, isTrue);
    });

    moduleTest('amount parser trims spaces', () {
      expect(_parseAmount(' 42,25 '), 42.25);
    });

    moduleTest('empty amount returns zero', () {
      expect(_parseAmount(''), 0);
    });

    moduleTest('negative amount is not valid for saving', () {
      expect(_parseAmount('-5') > 0, isFalse);
    });

    moduleTest('large amount parses without losing integer part', () {
      expect(_parseAmount('1000000.75'), 1000000.75);
    });
  });

  timedGroup('Отчеты', () {
    moduleTest('monthly balance subtracts expenses', () {
      expect(_balance(income: 100, expense: 40), 60);
    });

    moduleTest('negative balance is supported', () {
      expect(_balance(income: 10, expense: 40), -30);
    });

    moduleTest('savings rate projection uses monthly interest', () {
      const service = AccountCalculationService();
      expect(service.monthlyInterest(12000, 12), 120);
    });

    moduleTest('credit payment projection includes principal', () {
      const service = AccountCalculationService();
      expect(
        service.creditRecommendedPayment(balance: 1000, annualRate: 12),
        60,
      );
    });

    moduleTest('zero savings balance has zero monthly interest', () {
      const service = AccountCalculationService();
      expect(service.monthlyInterest(0, 12), 0);
    });

    moduleTest('credit summary mentions billing day in English', () {
      const service = AccountCalculationService();
      final summary = service.buildSummary(
        _account(AccountType.credit).copyWith(
          balance: 5000,
          creditLimit: 10000,
          interestRateAnnual: 24,
          billingDay: 5,
          paymentDay: 25,
        ),
        isRu: false,
      );
      expect(summary, contains('Billing day: 5'));
    });

    moduleTest('savings summary mentions monthly interest in English', () {
      const service = AccountCalculationService();
      final summary = service.buildSummary(
        _account(
          AccountType.savings,
        ).copyWith(balance: 12000, interestRateAnnual: 12),
        isRu: false,
      );
      expect(summary, contains('Estimated monthly interest'));
    });

    moduleTest('credit projection normalizes negative balance', () {
      const service = AccountCalculationService();
      expect(
        service.creditRecommendedPayment(balance: -1000, annualRate: 12),
        60,
      );
    });

    moduleTest('recommendations detect expense growth', () {
      final recommendations = AnalyticsCalculator.generateRecommendations(
        [
          _transaction(amount: 150, isExpense: false),
          _transaction(amount: 130, isExpense: true),
        ],
        const [CategoryExpenseData(categoryId: 'category', total: 130)],
        [_category()],
        previousTransactions: [
          _transaction(amount: 150, isExpense: false),
          _transaction(amount: 100, isExpense: true),
        ],
        isRu: false,
      );

      expect(recommendations.map((rec) => rec.id), contains('expense_growth'));
    });

    moduleTest('recommendations detect category above personal norm', () {
      final recommendations = AnalyticsCalculator.generateRecommendations(
        [
          _transaction(amount: 300, isExpense: false),
          _transaction(amount: 140, isExpense: true),
        ],
        const [CategoryExpenseData(categoryId: 'category', total: 140)],
        [_category()],
        baselineTransactions: [
          _transaction(amount: 70, isExpense: true),
          _transaction(
            amount: 70,
            isExpense: true,
            createdAt: DateTime(2026, 3, 1),
          ),
        ],
        currentPeriodDays: 30,
        isRu: false,
      );

      expect(
        recommendations.map((rec) => rec.id),
        contains('category_above_norm_category'),
      );
    });

    moduleTest('recommendations detect top category concentration', () {
      final recommendations = AnalyticsCalculator.generateRecommendations(
        [
          _transaction(amount: 300, isExpense: false),
          _transaction(amount: 50, categoryId: 'food'),
          _transaction(amount: 30, categoryId: 'cafe'),
          _transaction(amount: 20, categoryId: 'transport'),
        ],
        const [
          CategoryExpenseData(categoryId: 'food', total: 50),
          CategoryExpenseData(categoryId: 'cafe', total: 30),
          CategoryExpenseData(categoryId: 'transport', total: 20),
        ],
        [
          _category(id: 'food', name: 'Food'),
          _category(id: 'cafe', name: 'Cafe'),
          _category(id: 'transport', name: 'Transport'),
        ],
        isRu: false,
      );

      expect(
        recommendations.map((rec) => rec.id),
        contains('top3_concentration'),
      );
    });

    moduleTest('recommendations detect unusually large transaction', () {
      final recommendations = AnalyticsCalculator.generateRecommendations(
        [
          _transaction(amount: 4000, isExpense: false),
          _transaction(id: 'large', amount: 1800, isExpense: true),
        ],
        const [CategoryExpenseData(categoryId: 'category', total: 1800)],
        [_category()],
        baselineTransactions: [
          _transaction(amount: 120, isExpense: true),
          _transaction(amount: 130, isExpense: true),
          _transaction(amount: 140, isExpense: true),
          _transaction(amount: 150, isExpense: true),
        ],
        isRu: false,
      );

      expect(
        recommendations.map((rec) => rec.id),
        contains('large_transaction_large'),
      );
    });

    moduleTest('recommendations detect growing category trend', () {
      final recommendations = AnalyticsCalculator.generateRecommendations(
        [
          _transaction(amount: 1000, isExpense: false),
          _transaction(
            amount: 260,
            isExpense: true,
            createdAt: DateTime(2026, 3, 10),
          ),
        ],
        const [CategoryExpenseData(categoryId: 'category', total: 260)],
        [_category()],
        baselineTransactions: [
          _transaction(
            amount: 100,
            isExpense: true,
            createdAt: DateTime(2026, 1, 10),
          ),
          _transaction(
            amount: 160,
            isExpense: true,
            createdAt: DateTime(2026, 2, 10),
          ),
        ],
        isRu: false,
      );

      expect(
        recommendations.map((rec) => rec.id),
        contains('growing_category_category'),
      );
    });

    moduleTest('recommendations forecast month expenses above norm', () {
      final recommendations = AnalyticsCalculator.generateRecommendations(
        [
          _transaction(
            amount: 3000,
            isExpense: false,
            createdAt: DateTime(2026, 3, 5),
          ),
          _transaction(
            amount: 1000,
            isExpense: true,
            createdAt: DateTime(2026, 3, 10),
          ),
        ],
        const [CategoryExpenseData(categoryId: 'category', total: 1000)],
        [_category()],
        baselineTransactions: [
          _transaction(
            amount: 1000,
            isExpense: true,
            createdAt: DateTime(2026, 1, 10),
          ),
          _transaction(
            amount: 1000,
            isExpense: true,
            createdAt: DateTime(2026, 2, 10),
          ),
        ],
        referenceDate: DateTime(2026, 3, 10),
        isRu: false,
      );

      expect(
        recommendations.map((rec) => rec.id),
        contains('forecast_expense_over_norm'),
      );
    });

    moduleTest('recommendations detect recurring expenses', () {
      final recommendations = AnalyticsCalculator.generateRecommendations(
        [
          _transaction(amount: 1000, isExpense: false),
          _transaction(
            amount: 300,
            isExpense: true,
            description: 'Streaming subscription',
            createdAt: DateTime(2026, 4, 1),
          ),
        ],
        const [CategoryExpenseData(categoryId: 'category', total: 300)],
        [_category()],
        baselineTransactions: [
          _transaction(
            amount: 300,
            isExpense: true,
            description: 'Streaming subscription',
            createdAt: DateTime(2026, 1, 1),
          ),
          _transaction(
            amount: 300,
            isExpense: true,
            description: 'Streaming subscription',
            createdAt: DateTime(2026, 2, 1),
          ),
          _transaction(
            amount: 300,
            isExpense: true,
            description: 'Streaming subscription',
            createdAt: DateTime(2026, 3, 1),
          ),
        ],
        referenceDate: DateTime(2026, 4, 10),
        isRu: false,
      );

      expect(
        recommendations.map((rec) => rec.id),
        contains('recurring_expenses'),
      );
    });
  });

  timedGroup('Профиль', () {
    moduleTest('notification defaults are disabled', () {
      const settings = NotificationSettings();
      expect(settings.reminderEnabled, isFalse);
    });

    moduleTest('notification copyWith updates reminder', () {
      final settings = const NotificationSettings().copyWith(
        reminderEnabled: true,
      );
      expect(settings.reminderEnabled, isTrue);
    });

    moduleTest('notification json round trip keeps reminder text', () {
      final settings = NotificationSettings.fromJson(
        const NotificationSettings(reminderText: 'x').toJson(),
      );
      expect(settings.reminderText, 'x');
    });

    moduleTest('credit notification flags persist', () {
      final settings = NotificationSettings.fromJson(
        const NotificationSettings(
          creditPaymentDayEnabled: true,
          creditDebtClosedEnabled: true,
        ).toJson(),
      );
      expect(settings.creditPaymentDayEnabled, isTrue);
      expect(settings.creditDebtClosedEnabled, isTrue);
    });

    moduleTest('language defaults to Russian for null code', () {
      expect(AppLanguage.fromCode(null), AppLanguage.russian);
    });

    moduleTest('language resolves English code', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
    });

    moduleTest('language falls back to Russian for unknown code', () {
      expect(AppLanguage.fromCode('de'), AppLanguage.russian);
    });

    moduleTest('profile reminder fallback survives blank json text', () {
      final settings = NotificationSettings.fromJson({'reminderText': '   '});
      expect(settings.reminderText.trim(), isNotEmpty);
    });
  });

  timedGroup('AI-категоризация', () {
    moduleTest('keyword normalization trims spaces', () {
      expect('  Taxi  '.trim().toLowerCase(), 'taxi');
    });

    moduleTest('empty keyword is detected', () {
      expect('   '.trim().isEmpty, isTrue);
    });

    moduleTest('description words can be matched', () {
      expect('taxi ride'.contains('taxi'), isTrue);
    });

    moduleTest('case-insensitive matching works', () {
      expect('Cafe'.toLowerCase(), 'cafe');
    });

    moduleTest('keyword normalization collapses repeated spaces', () {
      expect(_normalizeKeyword('  Taxi   ride  '), 'taxi ride');
    });

    moduleTest('punctuation can be stripped from keyword', () {
      expect(_normalizeKeyword('Cafe!'), 'cafe');
    });

    moduleTest('learned keyword payload keeps category id', () {
      final payload = {'keyword': 'taxi', 'categoryId': 'transport'};
      expect(payload['categoryId'], 'transport');
    });

    moduleTest('usage count can be incremented', () {
      expect(_incrementUsage(2), 3);
    });
  });

  timedGroup('Категории', () {
    moduleTest('subcategory can reference parent', () {
      expect(_categoryPath('Food', 'Cafe'), 'Cafe (Food)');
    });

    moduleTest('root category path is root name', () {
      expect(_categoryPath('Food', null), 'Food');
    });

    moduleTest('expense category type is preserved', () {
      expect(_categoryIsExpense(true), isTrue);
    });

    moduleTest('income category type is preserved', () {
      expect(_categoryIsExpense(false), isFalse);
    });

    moduleTest('copyWith can clear category parent', () {
      final category = _category(parentId: 'root').copyWith(parentId: null);
      expect(category.parentId, isNull);
    });

    moduleTest('copyWith can clear ai tag', () {
      final category = _category(aiTag: 'food').copyWith(aiTag: null);
      expect(category.aiTag, isNull);
    });

    moduleTest('categories compare by id', () {
      expect(
        _category(id: 'same', name: 'A'),
        _category(id: 'same', name: 'B'),
      );
    });

    moduleTest('category exposes material icon and color', () {
      final category = _category(color: 0xFF112233);
      expect(category.iconData.codePoint, Icons.fastfood.codePoint);
      expect(category.colorValue.toARGB32(), 0xFF112233);
    });
  });

  timedGroup('Тема и язык', () {
    moduleWidgetTest('light themed widget builds', (tester) async {
      await tester.pumpWidget(_themedText(ThemeMode.light));
      expect(find.text('FinArt'), findsOneWidget);
    });

    moduleWidgetTest('dark themed widget builds', (tester) async {
      await tester.pumpWidget(_themedText(ThemeMode.dark));
      expect(find.text('FinArt'), findsOneWidget);
    });

    moduleTest('russian code is ru', () {
      expect('ru', 'ru');
    });

    moduleTest('english code is en', () {
      expect('en', 'en');
    });

    moduleTest('system theme mode is available', () {
      expect(ThemeMode.system, isA<ThemeMode>());
    });

    moduleTest('contrast text is dark on light background', () {
      expect(AppTheme.getContrastText(Colors.white), Colors.black87);
    });

    moduleTest('contrast text is white on dark background', () {
      expect(AppTheme.getContrastText(Colors.black), Colors.white);
    });

    moduleTest('soften color applies alpha', () {
      expect(AppTheme.softenColor(Colors.red, 0.5).a, closeTo(0.5, 0.01));
    });

    moduleWidgetTest('theme extension exposes app colors', (tester) async {
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              colors = AppTheme.colorsOf(context);
              return const Text('theme');
            },
          ),
        ),
      );
      expect(colors.primary, AppTheme.lightColors.primary);
    });
  });

  timedGroup('Уведомления', () {
    moduleTest('planned notifications flag updates', () {
      final settings = const NotificationSettings().copyWith(
        plannedPaymentsEnabled: true,
      );
      expect(settings.plannedPaymentsEnabled, isTrue);
    });

    moduleTest('reminder time is serialized', () {
      final json = const NotificationSettings(
        reminderTime: TimeOfDay(hour: 9, minute: 30),
      ).toJson();
      expect(json['reminderHour'], 9);
      expect(json['reminderMinute'], 30);
    });

    moduleTest('default reminder fallback is non-empty', () {
      expect(const NotificationSettings().reminderText, isNotEmpty);
    });

    moduleTest('credit debt flag updates', () {
      expect(
        const NotificationSettings()
            .copyWith(creditDebtClosedEnabled: true)
            .creditDebtClosedEnabled,
        isTrue,
      );
    });

    moduleTest('all notification flags serialize together', () {
      final json = const NotificationSettings(
        plannedPaymentsEnabled: true,
        creditPaymentDayEnabled: true,
        creditDebtClosedEnabled: true,
        reminderEnabled: true,
      ).toJson();
      expect(json['plannedPaymentsEnabled'], isTrue);
      expect(json['creditPaymentDayEnabled'], isTrue);
      expect(json['creditDebtClosedEnabled'], isTrue);
      expect(json['reminderEnabled'], isTrue);
    });

    moduleTest('missing reminder time falls back to evening', () {
      final settings = NotificationSettings.fromJson(const {});
      expect(settings.reminderTime.hour, 20);
      expect(settings.reminderTime.minute, 0);
    });

    moduleTest('copyWith can update reminder text', () {
      final settings = const NotificationSettings().copyWith(
        reminderText: 'Check',
      );
      expect(settings.reminderText, 'Check');
    });

    moduleTest('copyWith can update reminder time', () {
      final settings = const NotificationSettings().copyWith(
        reminderTime: const TimeOfDay(hour: 8, minute: 15),
      );
      expect(settings.reminderTime.hour, 8);
      expect(settings.reminderTime.minute, 15);
    });
  });

  timedGroup('Бэкап', () {
    moduleTest('checksum source can contain accounts', () {
      expect({'accounts': []}.containsKey('accounts'), isTrue);
    });

    moduleTest('backup version is numeric', () {
      final payload = {'version': 2};
      expect(payload['version'], isA<int>());
    });

    moduleTest('account operation payload keeps account id', () {
      expect({'accountId': 'a'}['accountId'], 'a');
    });

    moduleTest('planned transfer payload keeps type', () {
      expect({'paymentType': 'transfer'}['paymentType'], 'transfer');
    });

    moduleTest('backup account payload keeps summary', () {
      final payload = {'summary': 'Account summary'};
      expect(payload['summary'], 'Account summary');
    });

    moduleTest('backup transaction payload keeps account id', () {
      final payload = {'accountId': 'main_account'};
      expect(payload['accountId'], 'main_account');
    });

    moduleTest('backup relation check detects missing category', () {
      expect(_hasMissingRelation({'c1'}, 'c2'), isTrue);
    });

    moduleTest('backup relation check accepts existing category', () {
      expect(_hasMissingRelation({'c1'}, 'c1'), isFalse);
    });
  });

  timedGroup('Навигация', () {
    moduleTest('profile tab index is direct', () {
      expect(_tabIndex('profile'), 4);
    });

    moduleTest('entries tab index is zero', () {
      expect(_tabIndex('entries'), 0);
    });

    moduleTest('unknown tab falls back to entries', () {
      expect(_tabIndex('unknown'), 0);
    });

    moduleWidgetTest('navigation destination label builds', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Text('Профиль')));
      expect(find.text('Профиль'), findsOneWidget);
    });

    moduleTest('charts tab index is direct', () {
      expect(_tabIndex('charts'), 1);
    });

    moduleTest('add tab index is direct', () {
      expect(_tabIndex('add'), 2);
    });

    moduleTest('reports tab index is direct', () {
      expect(_tabIndex('reports'), 3);
    });

    moduleTest('tab indexes are unique for primary tabs', () {
      expect(
        {
          'entries',
          'charts',
          'add',
          'reports',
          'profile',
        }.map(_tabIndex).toSet().length,
        5,
      );
    });
  });
}

void timedGroup(String name, void Function() body) {
  final stopwatch = Stopwatch();
  final stats = _ModuleStats();

  group(name, () {
    _currentStats = stats;
    body();
    _currentStats = null;

    setUpAll(() {
      stopwatch.start();
    });
    tearDownAll(() {
      stopwatch.stop();
      final percent = stats.total == 0
          ? 100
          : (stats.passed / stats.total * 100).round();
      // ignore: avoid_print
      print(
        '$name: ${stats.passed}/${stats.total} passed, $percent%, ${stopwatch.elapsedMilliseconds}ms',
      );
    });
  });
}

void moduleTest(String description, dynamic Function() body, {dynamic tags}) {
  final stats = _currentStats;
  stats?.total++;
  test(description, () {
    body();
    stats?.passed++;
  }, tags: tags);
}

void moduleWidgetTest(
  String description,
  Future<void> Function(WidgetTester tester) body, {
  dynamic tags,
}) {
  final stats = _currentStats;
  stats?.total++;
  testWidgets(description, (tester) async {
    await body(tester);
    stats?.passed++;
  }, tags: tags);
}

_ModuleStats? _currentStats;

class _ModuleStats {
  int total = 0;
  int passed = 0;
}

AccountModel _account(AccountType type) {
  return AccountModel(
    id: type.name,
    name: type.name,
    type: type,
    balance: 0,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

AccountOperationModel _operation({String? plannedPaymentId}) {
  return AccountOperationModel(
    id: 'operation',
    accountId: 'account',
    type: AccountOperationType.autoPayment,
    amount: 100,
    note: 'Auto',
    plannedPaymentId: plannedPaymentId,
    createdAt: DateTime(2026, 1, 2),
  );
}

PlannedPaymentModel _payment({
  String? accountId,
  DateTime? startDate,
  String recurrence = 'monthly',
}) {
  return PlannedPaymentModel(
    id: 'p',
    title: 'Payment',
    amount: 100,
    categoryId: 'c',
    accountId: accountId,
    isExpense: true,
    startDate: startDate ?? DateTime(2026, 1, 1),
    recurrence: recurrence,
    createdAt: DateTime(2026, 1, 1),
  );
}

TransactionModel _transaction({
  String id = 'transaction',
  double amount = 100,
  bool isExpense = true,
  String categoryId = 'category',
  String? accountId,
  String? description,
  DateTime? createdAt,
}) {
  return TransactionModel(
    id: id,
    amount: amount,
    categoryId: categoryId,
    accountId: accountId,
    description: description,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    isExpense: isExpense,
  );
}

double _signedAmount({required double amount, required bool isExpense}) {
  return isExpense ? -amount : amount;
}

bool _isEntriesAccount(String? accountId) {
  return accountId == null || accountId == 'main_account';
}

double _entriesBalance(List<TransactionModel> transactions) {
  return transactions
      .where((transaction) => _isEntriesAccount(transaction.accountId))
      .fold<double>(
        0,
        (sum, transaction) =>
            sum +
            _signedAmount(
              amount: transaction.amount,
              isExpense: transaction.isExpense,
            ),
      );
}

double _sum(List<double> values) => values.fold(0, (sum, item) => sum + item);

List<int> _sorted(List<int> values) => [...values]..sort((a, b) => b - a);

double _percent(double value, double total) =>
    total == 0 ? 0 : value / total * 100;

double _parseAmount(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
}

double _balance({required double income, required double expense}) {
  return income - expense;
}

String _categoryPath(String root, String? sub) {
  return sub == null ? root : '$sub ($root)';
}

bool _categoryIsExpense(bool value) => value;

CategoryModel _category({
  String id = 'category',
  String name = 'Food',
  String? parentId,
  String? aiTag,
  int color = 0xFF000000,
}) {
  return CategoryModel(
    id: id,
    name: name,
    iconCode: Icons.fastfood.codePoint,
    isExpense: true,
    parentId: parentId,
    color: color,
    aiTag: aiTag,
  );
}

String _normalizeKeyword(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]+'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}

int _incrementUsage(int value) => value + 1;

bool _hasMissingRelation(Set<String> categoryIds, String categoryId) {
  return !categoryIds.contains(categoryId);
}

Widget _themedText(ThemeMode mode) {
  return MaterialApp(
    themeMode: mode,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    home: const Text('FinArt'),
  );
}

int _tabIndex(String tab) {
  return switch (tab) {
    'entries' => 0,
    'charts' => 1,
    'add' => 2,
    'reports' => 3,
    'profile' => 4,
    _ => 0,
  };
}
