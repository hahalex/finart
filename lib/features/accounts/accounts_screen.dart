// Файл: lib/features/accounts/accounts_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../common/localization/app_strings.dart';
import '../../common/models/account_operation_model.dart';
import '../../common/models/account_model.dart';
import '../../common/models/category_model.dart';
import '../../common/models/planned_payment_model.dart';
import '../../common/providers/accounts_provider.dart';
import '../../common/providers/accounts_repository_provider.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/providers/notification_service_provider.dart';
import '../../common/providers/notification_settings_provider.dart';
import '../../common/providers/planned_repository_provider.dart';
import '../../common/providers/selected_month_provider.dart';
import '../../common/utils/app_theme.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/providers/transactions_notifier.dart';
import '../planned/presentation/planned_list_screen.dart';
import '../planned/providers/planned_ui_providers.dart';

enum _AccountsFilter { all, credit, savings }

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  _AccountsFilter _filter = _AccountsFilter.all;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final accountsAsync = ref.watch(accountsProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final transactions = ref.watch(transactionsProvider);
    final (monthStart, monthEnd) = getMonthRange(selectedMonth);
    // Основной счет на странице "Счета" показывает тот же баланс месяца,
    // что и экран "Записи", поэтому считаем его из текущих транзакций.
    final entriesBalance = transactions
        .where(
          (transaction) =>
              (transaction.createdAt.isAfter(monthStart) ||
                  transaction.createdAt.isAtSameMomentAs(monthStart)) &&
              transaction.createdAt.isBefore(monthEnd),
        )
        .fold<double>(
          0,
          (sum, transaction) => transaction.isExpense
              ? sum - transaction.amount
              : sum + transaction.amount,
        );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(strings.accounts), centerTitle: true),
      body: SafeArea(
        child: accountsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (accounts) {
            final rawMainAccount = accounts
                .where((account) => account.isMain)
                .firstOrNull;
            final mainAccount = rawMainAccount?.copyWith(
              balance: entriesBalance,
            );
            final secondaryAccounts = accounts
                .where((account) => !account.isMain)
                .where(_matchesFilter)
                .toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                // Главный счет всегда стоит сверху отдельно от фильтруемого списка.
                if (mainAccount != null)
                  _AccountCard(
                    account: mainAccount,
                    isPrimary: true,
                    onTap: () => _openDetails(mainAccount),
                    onLongPress: () => _showForm(context, account: mainAccount),
                    onAction: null,
                  ),
                const SizedBox(height: 8),
                // Переключатель ниже меняет только список кредитных/накопительных
                // счетов, не затрагивая главный счет сверху.
                _AccountsFilterControl(
                  filter: _filter,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 12),
                if (secondaryAccounts.isEmpty)
                  _AccountsEmptyState(onCreate: () => _showForm(context))
                else
                  for (final account in secondaryAccounts)
                    _AccountCard(
                      account: account,
                      onTap: () => _openDetails(account),
                      onLongPress: () => _showForm(context, account: account),
                      onAction: (value) => _handleAccountAction(value, account),
                    ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Плавающая кнопка создает новый кредитный или накопительный счет.
        onPressed: () => _showForm(context),
        tooltip: strings.addAccount,
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _matchesFilter(AccountModel account) {
    return switch (_filter) {
      _AccountsFilter.all => true,
      _AccountsFilter.credit => account.isCredit,
      _AccountsFilter.savings => account.isSavings,
    };
  }

  Future<void> _handleAccountAction(String value, AccountModel account) async {
    // Все пункты меню с тремя точками маршрутизируются здесь.
    switch (value) {
      case 'info':
        await _showAccountInfo(account);
        break;
      case 'topUp':
        await _showOperationDialog(account, AccountOperationType.topUp);
        break;
      case 'withdraw':
        await _showOperationDialog(account, AccountOperationType.withdraw);
        break;
      case 'history':
        _openDetails(account);
        break;
      case 'attach':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AccountPlannedPaymentSelectionScreen(accountId: account.id),
          ),
        );
        ref.invalidate(plannedPaymentsListProvider);
        break;
      case 'create':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlannedListScreen(
              initialAccountId: account.id,
              openCreateOnStart: true,
            ),
          ),
        );
        ref.invalidate(plannedPaymentsListProvider);
        break;
      case 'archive':
        await _archiveAccount(account);
        break;
    }
  }

  Future<void> _showAccountInfo(AccountModel account) async {
    final strings = AppStrings.of(context);
    await showDialog<void>(
      // Сводка хранится в модели счета и пересчитывается при сохранении формы.
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.isRu ? 'Информация о счете' : 'Account info'),
        content: Text(
          account.summary.trim().isEmpty
              ? (strings.isRu
                    ? 'Сводка по счету пока не сформирована.'
                    : 'No saved account summary yet.')
              : account.summary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.close),
          ),
        ],
      ),
    );
  }

  void _openDetails(AccountModel account) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AccountDetailsScreen(account: account)),
    );
  }

  Future<void> _showOperationDialog(
    AccountModel account,
    AccountOperationType type,
  ) async {
    final strings = AppStrings.of(context);
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    await showDialog<void>(
      // Диалог ручной операции: пополнение/снятие попадает в историю счета.
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(type.label(strings.isRu)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: strings.amount),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(labelText: strings.note),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (amount <= 0) return;
              await ref
                  .read(accountsRepositoryProvider)
                  .applyManualOperation(
                    accountId: account.id,
                    type: type,
                    amount: amount,
                    note: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                  );
              ref.invalidate(accountsProvider);
              ref.invalidate(accountOperationsProvider(account.id));
              await _syncAccountNotifications();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(strings.save),
          ),
        ],
      ),
    );
  }

  Future<void> _archiveAccount(AccountModel account) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      // Архивация скрывает счет из списка, но не удаляет историю.
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.archiveAccount),
        content: Text(
          strings.isRu
              ? 'Счёт "${account.name}" будет скрыт из списка.'
              : 'Account "${account.name}" will be hidden from the list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.archive),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(accountsRepositoryProvider).archiveAccount(account.id);
    ref.invalidate(accountsProvider);
  }

  void _showForm(BuildContext context, {AccountModel? account}) {
    final strings = AppStrings.of(context);
    final nameController = TextEditingController(text: account?.name ?? '');
    final balanceController = TextEditingController(
      text: account == null ? '' : account.balance.toStringAsFixed(2),
    );
    final creditLimitController = TextEditingController(
      text: account?.creditLimit == null
          ? ''
          : account!.creditLimit!.toStringAsFixed(2),
    );
    final interestController = TextEditingController(
      text: account?.interestRateAnnual == null
          ? ''
          : account!.interestRateAnnual!.toStringAsFixed(2),
    );
    var billingDate = _dateForDay(account?.billingDay);
    var paymentDate = _dateForDay(account?.paymentDay);
    var type = account?.type ?? AccountType.credit;

    showDialog<void>(
      // Форма счета: редактирует название, тип, баланс, лимит, даты и ставку.
      // Для основного счета баланс заблокирован, потому что он считается из записей.
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isMain = type == AccountType.main;
            final isCredit = type == AccountType.credit;
            final isSavings = type == AccountType.savings;

            return AlertDialog(
              title: Text(
                account == null ? strings.addAccount : strings.editAccount,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: strings.accountName,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AccountType>(
                      // Тип счета: кредитный или накопительный. Основной счет
                      // доступен только при редактировании уже существующего main.
                      initialValue: type,
                      decoration: InputDecoration(
                        labelText: strings.accountType,
                      ),
                      items: [
                        if (account?.isMain == true)
                          DropdownMenuItem(
                            value: AccountType.main,
                            child: Text(AccountType.main.label(strings.isRu)),
                          ),
                        DropdownMenuItem(
                          value: AccountType.credit,
                          child: Text(AccountType.credit.label(strings.isRu)),
                        ),
                        DropdownMenuItem(
                          value: AccountType.savings,
                          child: Text(AccountType.savings.label(strings.isRu)),
                        ),
                      ],
                      onChanged: account?.isMain == true
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() => type = value);
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      // Стартовый баланс вторичного счета; для основного счета
                      // поле отключено и синхронизируется с экраном "Записи".
                      controller: balanceController,
                      enabled: !isMain,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(labelText: strings.balance),
                    ),
                    if (isCredit) ...[
                      const SizedBox(height: 12),
                      TextField(
                        // Кредитный лимит нужен для расчета закрытия долга
                        // и уведомления о полном погашении.
                        controller: creditLimitController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: strings.creditLimit,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DateField(
                        // День выписки выбирается календарем, но сохраняется
                        // только номер дня месяца.
                        label: strings.billingDay,
                        value: billingDate,
                        onTap: () async {
                          final picked = await _pickDate(context, billingDate);
                          if (picked != null) {
                            setDialogState(() => billingDate = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      _DateField(
                        // День платежа нужен для кредитных уведомлений.
                        label: strings.paymentDay,
                        value: paymentDate,
                        onTap: () async {
                          final picked = await _pickDate(context, paymentDate);
                          if (picked != null) {
                            setDialogState(() => paymentDate = picked);
                          }
                        },
                      ),
                    ],
                    if (isCredit || isSavings) ...[
                      const SizedBox(height: 12),
                      TextField(
                        // Процентная ставка используется в сводке и начислениях:
                        // кредит — расчет платежа, накопительный — проценты.
                        controller: interestController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: strings.interestRate,
                          suffixText: '%',
                        ),
                      ),
                    ],
                    if (isMain) ...[
                      const SizedBox(height: 12),
                      Text(
                        strings.mainAccountDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedTextOf(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final repository = ref.read(accountsRepositoryProvider);
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final currentMainBalance = account?.isMain == true
                        ? account!.balance
                        : null;
                    final balance =
                        currentMainBalance ??
                        double.tryParse(balanceController.text.trim()) ??
                        0;
                    final creditLimit = double.tryParse(
                      creditLimitController.text.trim(),
                    );
                    final interest = double.tryParse(
                      interestController.text.trim(),
                    );

                    AccountModel? savedAccount;
                    if (account == null) {
                      savedAccount = await repository.createAccount(
                        name: name,
                        type: type,
                        balance: balance,
                        creditLimit: creditLimit,
                        interestRateAnnual: interest,
                        billingDay: billingDate?.day,
                        paymentDay: paymentDate?.day,
                      );
                    } else {
                      savedAccount = await repository.saveAccount(
                        AccountModel(
                          id: account.id,
                          name: name,
                          type: account.isMain ? AccountType.main : type,
                          balance: balance,
                          creditLimit: isCredit ? creditLimit : null,
                          interestRateAnnual: isMain ? null : interest,
                          billingDay: isCredit ? billingDate?.day : null,
                          paymentDay: isCredit ? paymentDate?.day : null,
                          summary: '',
                          isDefault: account.isDefault,
                          isArchived: account.isArchived,
                          createdAt: account.createdAt,
                          updatedAt: account.updatedAt,
                        ),
                      );
                    }

                    ref.invalidate(accountsProvider);
                    await _syncAccountNotifications();
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (account == null && context.mounted) {
                      await _showAccountInfo(savedAccount);
                    }
                  },
                  child: Text(strings.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  DateTime? _dateForDay(int? day) {
    if (day == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, day.clamp(1, 28).toInt());
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? selected) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: selected ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
  }

  Future<void> _syncAccountNotifications() async {
    final settings = ref.read(notificationSettingsProvider);
    if (!settings.creditPaymentDayEnabled &&
        !settings.creditDebtClosedEnabled) {
      return;
    }
    final accounts = await ref
        .read(accountsRepositoryProvider)
        .getAllAccounts(includeArchived: true);
    final plannedPayments = await ref
        .read(plannedRepositoryProvider)
        .getAllPlannedPayments();
    await ref
        .read(notificationServiceProvider)
        .syncAll(
          settings: settings,
          plannedPayments: plannedPayments
              .where((payment) => payment.isActive)
              .toList(),
          accounts: accounts,
        );
  }
}

class AccountPlannedPaymentSelectionScreen extends ConsumerWidget {
  const AccountPlannedPaymentSelectionScreen({
    super.key,
    required this.accountId,
  });

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final categories = ref.watch(allCategoriesProvider).valueOrNull ?? [];
    final plannedPayments = ref.watch(
      plannedPaymentsListProvider(PlannedFilter.active),
    );
    final query = ref.watch(_plannedSelectionSearchProvider).toLowerCase();
    final categoryId = ref.watch(_plannedSelectionCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.chooseActivePlannedPayment)),
      body: plannedPayments.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (payments) {
          final filtered = payments.where((payment) {
            if (categoryId != null && payment.categoryId != categoryId) {
              return false;
            }
            if (query.isEmpty) return true;
            final categoryName =
                categories
                    .firstWhereOrNull(
                      (category) => category.id == payment.categoryId,
                    )
                    ?.name ??
                '';
            return '${payment.title} $categoryName'.toLowerCase().contains(
              query,
            );
          }).toList();

          if (filtered.isEmpty) {
            return Center(child: Text(strings.noActivePlannedPayments));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _PlannedSelectionFilters(categories: categories);
              }
              final payment = filtered[index - 1];
              return ListTile(
                tileColor: AppTheme.colorsOf(context).surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: const Icon(Icons.event_repeat_outlined),
                title: Text(payment.title),
                subtitle: Text(_paymentSubtitle(payment, strings.isRu)),
                trailing: payment.accountId == accountId
                    ? const Icon(Icons.check_circle)
                    : const Icon(Icons.chevron_right),
                onTap: () async {
                  await ref
                      .read(plannedRepositoryProvider)
                      .updatePlannedPayment(
                        payment.copyWith(
                          accountId: accountId,
                          paymentType: PlannedPaymentType.transfer,
                          isExpense: true,
                        ),
                      );
                  ref.invalidate(plannedPaymentsListProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.linkedPaymentSaved)),
                    );
                    Navigator.pop(context);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  String _paymentSubtitle(PlannedPaymentModel payment, bool isRu) {
    final sign = payment.isExpense ? '-' : '+';
    final type = payment.isExpense
        ? (isRu ? 'расход' : 'expense')
        : (isRu ? 'доход' : 'income');
    return '$sign${payment.amount.toStringAsFixed(2)} · $type';
  }
}

class AccountDetailsScreen extends ConsumerWidget {
  const AccountDetailsScreen({super.key, required this.account});

  final AccountModel account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final linkedPayments = ref.watch(
      plannedPaymentsListProvider(PlannedFilter.all),
    );
    final operations = ref.watch(accountOperationsProvider(account.id));

    return Scaffold(
      appBar: AppBar(title: Text(account.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransaction(context, ref),
        tooltip: strings.isRu ? 'Добавить операцию' : 'Add transaction',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _AccountCard(
            account: account,
            onTap: () {},
            onLongPress: () {},
            onAction: null,
            isPrimary: account.isMain,
          ),
          const SizedBox(height: 12),
          Text(
            strings.linkedRecurringPayments,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          linkedPayments.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (error, _) => Text('Error: $error'),
            data: (payments) {
              final items = payments
                  .where((payment) => payment.accountId == account.id)
                  .toList();
              if (items.isEmpty) {
                return Text(strings.noActivePlannedPayments);
              }
              return Column(
                children: [
                  for (final payment in items)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          payment.paymentType.isTransfer
                              ? Icons.swap_horiz_rounded
                              : Icons.event_repeat_outlined,
                        ),
                        title: Text(payment.title),
                        subtitle: Text(
                          _plannedPaymentDetails(payment, strings.isRu),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'unlink') {
                              await _confirmUnlinkPayment(
                                context,
                                ref,
                                payment,
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'unlink',
                              child: Text(strings.isRu ? 'Отвязать' : 'Unlink'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            strings.accountOperations,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          operations.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (error, _) => Text('Error: $error'),
            data: (items) {
              if (items.isEmpty) {
                return Text(strings.isRu ? 'История пуста' : 'No history yet');
              }
              return Column(
                children: [
                  for (final operation in items)
                    ListTile(
                      leading: Icon(_operationIcon(operation.type)),
                      title: Text(operation.type.label(strings.isRu)),
                      subtitle: Text(
                        operation.note?.isNotEmpty == true
                            ? operation.note!
                            : '${operation.createdAt.day}.${operation.createdAt.month}.${operation.createdAt.year}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(operation.amount.toStringAsFixed(2)),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await _showEditOperationDialog(
                                  context,
                                  ref,
                                  operation,
                                );
                              } else if (value == 'delete') {
                                await _confirmDeleteOperation(
                                  context,
                                  ref,
                                  operation,
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(strings.isRu ? 'Изменить' : 'Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  strings.isRu ? 'Удалить' : 'Delete',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openAddTransaction(BuildContext context, WidgetRef ref) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialAccountId: account.id),
      ),
    );
    ref.invalidate(accountsProvider);
    ref.invalidate(accountOperationsProvider(account.id));
  }

  Future<void> _showEditOperationDialog(
    BuildContext context,
    WidgetRef ref,
    AccountOperationModel operation,
  ) async {
    final strings = AppStrings.of(context);
    final amountController = TextEditingController(
      text: operation.amount.toString(),
    );
    final noteController = TextEditingController(text: operation.note ?? '');
    var selectedType = operation.type;
    var selectedDate = operation.createdAt;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                strings.isRu ? 'Изменить операцию' : 'Edit operation',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<AccountOperationType>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: strings.isRu ? 'Тип' : 'Type',
                      ),
                      items: [
                        for (final type in AccountOperationType.values)
                          DropdownMenuItem(
                            value: type,
                            child: Text(type.label(strings.isRu)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(labelText: strings.amount),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(labelText: strings.note),
                    ),
                    const SizedBox(height: 8),
                    _DateField(
                      label: strings.isRu ? 'Дата' : 'Date',
                      value: selectedDate,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              selectedDate.hour,
                              selectedDate.minute,
                              selectedDate.second,
                              selectedDate.millisecond,
                              selectedDate.microsecond,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountController.text.trim()) ?? 0;
                    if (amount <= 0) return;

                    await ref
                        .read(accountsRepositoryProvider)
                        .updateOperation(
                          operation.copyWith(
                            type: selectedType,
                            amount: amount,
                            note: noteController.text.trim().isEmpty
                                ? null
                                : noteController.text.trim(),
                            clearNote: noteController.text.trim().isEmpty,
                            createdAt: selectedDate,
                          ),
                        );
                    ref.invalidate(accountsProvider);
                    ref.invalidate(accountOperationsProvider(account.id));
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: Text(strings.save),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    noteController.dispose();
  }

  Future<void> _confirmDeleteOperation(
    BuildContext context,
    WidgetRef ref,
    AccountOperationModel operation,
  ) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.isRu ? 'Удалить операцию?' : 'Delete operation?'),
        content: Text(
          strings.isRu
              ? 'Операция будет удалена из истории, а баланс счета пересчитан.'
              : 'The operation will be removed from history and the account balance will be recalculated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.isRu ? 'Удалить' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(accountsRepositoryProvider).deleteOperation(operation.id);
    ref.invalidate(accountsProvider);
    ref.invalidate(accountOperationsProvider(account.id));
  }

  String _plannedPaymentDetails(PlannedPaymentModel payment, bool isRu) {
    final type = payment.paymentType.isTransfer
        ? (isRu ? 'Перевод между счетами' : 'Account transfer')
        : payment.isExpense
        ? (isRu ? 'Расход' : 'Expense')
        : (isRu ? 'Доход' : 'Income');
    final recurrence = _recurrenceLabel(payment.recurrence, isRu);
    final date =
        '${payment.startDate.day}.${payment.startDate.month}.${payment.startDate.year}';
    return isRu
        ? '${payment.amount.toStringAsFixed(2)} · $type\n$recurrence · начало $date'
        : '${payment.amount.toStringAsFixed(2)} · $type\n$recurrence · starts $date';
  }

  String _recurrenceLabel(String recurrence, bool isRu) {
    return switch (recurrence) {
      'daily' => isRu ? 'Ежедневно' : 'Daily',
      'weekly' => isRu ? 'Еженедельно' : 'Weekly',
      'every:weeks:2' => isRu ? 'Раз в 2 недели' : 'Every 2 weeks',
      'monthly' => isRu ? 'Ежемесячно' : 'Monthly',
      'every:months:3' => isRu ? 'Раз в 3 месяца' : 'Every 3 months',
      'weekdays:1,2,3,4,5' => isRu ? 'По будням' : 'Weekdays',
      'yearly' => isRu ? 'Ежегодно' : 'Yearly',
      'none' => isRu ? 'Разово' : 'One-time',
      _ => recurrence,
    };
  }

  Future<void> _confirmUnlinkPayment(
    BuildContext context,
    WidgetRef ref,
    PlannedPaymentModel payment,
  ) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.isRu ? 'Отвязать платеж?' : 'Unlink payment?'),
        content: Text(
          strings.isRu
              ? 'Платеж "${payment.title}" останется в предстоящих платежах, но больше не будет связан со счетом.'
              : 'Payment "${payment.title}" will remain in upcoming payments, but will no longer be linked to this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.isRu ? 'Отвязать' : 'Unlink'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(plannedRepositoryProvider)
        .updatePlannedPayment(
          payment.copyWith(
            clearAccountId: true,
            paymentType: PlannedPaymentType.standard,
          ),
        );
    ref.invalidate(plannedPaymentsListProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.isRu ? 'Платеж отвязан' : 'Payment unlinked'),
        ),
      );
    }
  }

  IconData _operationIcon(AccountOperationType type) {
    return switch (type) {
      AccountOperationType.topUp => Icons.add_circle_outline,
      AccountOperationType.withdraw => Icons.remove_circle_outline,
      AccountOperationType.autoPayment => Icons.event_repeat_outlined,
      AccountOperationType.interest => Icons.percent_rounded,
    };
  }
}

final _plannedSelectionSearchProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);
final _plannedSelectionCategoryProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

class _PlannedSelectionFilters extends ConsumerWidget {
  const _PlannedSelectionFilters({required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return Column(
      children: [
        TextField(
          onChanged: (value) {
            ref.read(_plannedSelectionSearchProvider.notifier).state = value;
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: strings.isRu ? 'Название платежа' : 'Payment title',
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          initialValue: ref.watch(_plannedSelectionCategoryProvider),
          decoration: InputDecoration(
            labelText: strings.isRu ? 'Категория' : 'Category',
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(strings.isRu ? 'Все категории' : 'All categories'),
            ),
            for (final category in categories)
              DropdownMenuItem<String?>(
                value: category.id,
                child: Text(category.name),
              ),
          ],
          onChanged: (value) {
            ref.read(_plannedSelectionCategoryProvider.notifier).state = value;
          },
        ),
      ],
    );
  }
}

class _AccountsFilterControl extends StatelessWidget {
  const _AccountsFilterControl({required this.filter, required this.onChanged});

  final _AccountsFilter filter;
  final ValueChanged<_AccountsFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final items = [
      (_AccountsFilter.all, strings.allAccounts),
      (_AccountsFilter.credit, strings.creditAccounts),
      (_AccountsFilter.savings, strings.savingsAccounts),
    ];

    return Container(
      // Компактный фильтр Все/Кредитные/Накопительные для списка под главным
      // счетом. Рамка полупрозрачная, выбранный сегмент залит цветом счетов.
      height: 38,
      decoration: BoxDecoration(
        border: Border.all(width: 1.5, color: colors.accounts),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(item.$1),
                child: ColoredBox(
                  color: filter == item.$1
                      ? colors.accounts
                      : Colors.transparent,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          item.$2,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: filter == item.$1
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Переиспользуемая строка выбора даты в форме счета.
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        value == null
            ? AppStrings.of(context).isRu
                  ? 'Не выбрано'
                  : 'Not selected'
            : '${value!.day}.${value!.month}.${value!.year}',
      ),
      trailing: const Icon(Icons.calendar_today_outlined),
      onTap: onTap,
    );
  }
}

class _AccountsEmptyState extends StatelessWidget {
  const _AccountsEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);

    return Padding(
      // Пустое состояние вторичных счетов: иконка, текст и кнопка создания.
      padding: const EdgeInsets.all(AppTheme.pagePadding),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: colors.accounts,
          ),
          const SizedBox(height: 12),
          Text(
            strings.accountsComingSoon,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: Text(strings.addAccount),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.onTap,
    required this.onLongPress,
    required this.onAction,
    this.isPrimary = false,
  });

  final AccountModel account;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<String>? onAction;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = AppTheme.colorsOf(context);
    final accent = account.isMain ? colors.primary : colors.accounts;

    return Card(
      // Карточка счета. Нажатие открывает детали, долгое нажатие — форму
      // редактирования, меню с тремя точками — дополнительные действия.
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.all(isPrimary ? 18 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // Иконка счета лежит в мягкой акцентной плашке:
                // primary для главного счета, accounts для остальных.
                width: isPrimary ? 54 : 48,
                height: isPrimary ? 54 : 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(account.type.icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.type.label(strings.isRu),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedTextOf(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      // Чипы показывают важные параметры счета без перехода
                      // в детали: баланс, лимит, ставка, день платежа.
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _AccountChip(
                          label: strings.balance,
                          value: account.balance.toStringAsFixed(2),
                        ),
                        if (account.creditLimit != null)
                          _AccountChip(
                            label: strings.creditLimit,
                            value: account.creditLimit!.toStringAsFixed(2),
                          ),
                        if (account.interestRateAnnual != null)
                          _AccountChip(
                            label: strings.interestRateShort,
                            value:
                                '${account.interestRateAnnual!.toStringAsFixed(2)}%',
                          ),
                        if (account.paymentDay != null)
                          _AccountChip(
                            label: strings.paymentDayShort,
                            value: account.paymentDay.toString(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onAction != null)
                PopupMenuButton<String>(
                  // Меню действий доступно только для вторичных счетов.
                  onSelected: onAction,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'info',
                      child: Text(
                        strings.isRu ? 'Информация о счете' : 'Account info',
                      ),
                    ),
                    PopupMenuItem(value: 'topUp', child: Text(strings.topUp)),
                    PopupMenuItem(
                      value: 'withdraw',
                      child: Text(strings.withdraw),
                    ),
                    PopupMenuItem(
                      value: 'history',
                      child: Text(strings.history),
                    ),
                    PopupMenuItem(
                      value: 'attach',
                      child: Text(strings.attachRecurringPayment),
                    ),
                    PopupMenuItem(
                      value: 'create',
                      child: Text(strings.createRecurringPayment),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(strings.archive),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Container(
      // Маленький параметр внутри карточки счета. surfaceSoft отделяет чип
      // от фона карточки без сильного визуального шума.
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
