// Файл: lib/common/repositories/accounts_repository.dart.
// Назначение: изолирует доступ к данным и операции чтения/записи в локальное хранилище.

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/account_model.dart';
import '../models/account_operation_model.dart';
import '../services/account_calculation_service.dart';

class AccountsRepository {
  AccountsRepository(this._db);

  static const String mainAccountId = 'main_account';

  final AppDatabase _db;
  final _calculation = const AccountCalculationService();

  Future<List<AccountModel>> getAllAccounts({
    bool includeArchived = false,
  }) async {
    await syncMainAccountBalance();
    final query = _db.select(_db.accountsTable)
      ..orderBy([
        (table) =>
            OrderingTerm(expression: table.isDefault, mode: OrderingMode.desc),
        (table) => OrderingTerm(expression: table.createdAt),
      ]);

    if (!includeArchived) {
      query.where((table) => table.isArchived.equals(false));
    }

    final rows = await query.get();
    return rows.map(_fromTableData).toList();
  }

  Future<double> calculateMainBalance() async {
    final rows = await _db.select(_db.transactionsTable).get();
    return rows
        .where(
          (transaction) =>
              transaction.accountId == null ||
              transaction.accountId == mainAccountId,
        )
        .fold<double>(0, (sum, transaction) {
          return transaction.isExpense
              ? sum - transaction.amount
              : sum + transaction.amount;
        });
  }

  Future<void> syncMainAccountBalance() async {
    await ensureMainAccount();
    final balance = await calculateMainBalance();

    await (_db.update(
      _db.accountsTable,
    )..where((table) => table.id.equals(mainAccountId))).write(
      AccountsTableCompanion(
        balance: Value(balance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> adjustAccountBalance(String id, double delta) async {
    if (id == mainAccountId) {
      await syncMainAccountBalance();
      return;
    }

    final account = await getAccountById(id);
    if (account == null) return;

    await (_db.update(
      _db.accountsTable,
    )..where((table) => table.id.equals(id))).write(
      AccountsTableCompanion(
        balance: Value(account.balance + delta),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> addOperation({
    required String accountId,
    required AccountOperationType type,
    required double amount,
    String? note,
    String? plannedPaymentId,
    DateTime? createdAt,
  }) async {
    await _db
        .into(_db.accountOperationsTable)
        .insert(
          AccountOperationsTableCompanion.insert(
            id: const Uuid().v4(),
            accountId: accountId,
            type: type.name,
            amount: amount,
            note: Value(note),
            plannedPaymentId: Value(plannedPaymentId),
            createdAt: Value(createdAt ?? DateTime.now()),
          ),
        );
  }

  Future<void> applyManualOperation({
    required String accountId,
    required AccountOperationType type,
    required double amount,
    String? note,
    DateTime? createdAt,
  }) async {
    final delta = switch (type) {
      AccountOperationType.topUp => amount,
      AccountOperationType.withdraw => -amount,
      AccountOperationType.autoPayment => amount,
      AccountOperationType.interest => amount,
    };
    await adjustAccountBalance(accountId, delta);
    await addOperation(
      accountId: accountId,
      type: type,
      amount: amount,
      note: note,
      createdAt: createdAt,
    );
  }

  Future<void> updateOperation(AccountOperationModel operation) async {
    final existing = await _operationById(operation.id);
    if (existing == null || existing.accountId != operation.accountId) return;

    await (_db.update(
      _db.accountOperationsTable,
    )..where((table) => table.id.equals(operation.id))).write(
      AccountOperationsTableCompanion(
        type: Value(operation.type.name),
        amount: Value(operation.amount),
        note: Value(operation.note),
        plannedPaymentId: Value(operation.plannedPaymentId),
        createdAt: Value(operation.createdAt),
      ),
    );

    await adjustAccountBalance(
      operation.accountId,
      _operationDelta(operation) - _operationDelta(existing),
    );
  }

  Future<void> deleteOperation(String id) async {
    final existing = await _operationById(id);
    if (existing == null) return;

    await (_db.delete(
      _db.accountOperationsTable,
    )..where((table) => table.id.equals(id))).go();
    await adjustAccountBalance(existing.accountId, -_operationDelta(existing));
  }

  Future<int> accrueMonthlySavingsInterest({DateTime? now}) async {
    final effectiveNow = now ?? DateTime.now();
    final monthKey =
        '${effectiveNow.year}-${effectiveNow.month.toString().padLeft(2, '0')}';
    final accounts = await getAllAccounts(includeArchived: true);
    var accrued = 0;

    for (final account in accounts.where((item) => item.isSavings)) {
      final rate = account.interestRateAnnual ?? 0;
      if (account.isArchived || rate <= 0 || account.balance <= 0) continue;

      final note = 'interest:$monthKey';
      final existing =
          await (_db.select(_db.accountOperationsTable)
                ..where((table) => table.accountId.equals(account.id))
                ..where(
                  (table) =>
                      table.type.equals(AccountOperationType.interest.name),
                )
                ..where((table) => table.note.equals(note)))
              .getSingleOrNull();
      if (existing != null) continue;

      final interest = account.balance * rate / 100 / 12;
      if (interest <= 0) continue;

      await adjustAccountBalance(account.id, interest);
      await addOperation(
        accountId: account.id,
        type: AccountOperationType.interest,
        amount: interest,
        note: note,
        createdAt: effectiveNow,
      );
      accrued++;
    }

    return accrued;
  }

  Future<List<AccountOperationModel>> getOperations(String accountId) async {
    final rows =
        await (_db.select(_db.accountOperationsTable)
              ..where((table) => table.accountId.equals(accountId))
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.createdAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();

    return rows.map(_operationFromTableData).toList();
  }

  Future<AccountModel> ensureMainAccount() async {
    final existing = await getAccountById(mainAccountId);
    if (existing != null) return existing;

    final now = DateTime.now();
    final account = AccountModel(
      id: mainAccountId,
      name: 'Основной счет',
      type: AccountType.main,
      balance: 0,
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    );
    final accountWithSummary = account.copyWith(
      summary: _calculation.buildSummary(account, isRu: true),
    );
    await upsertAccount(accountWithSummary);
    return accountWithSummary;
  }

  Future<AccountModel?> getAccountById(String id) async {
    final row = await (_db.select(
      _db.accountsTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();

    return row == null ? null : _fromTableData(row);
  }

  Future<void> upsertAccount(AccountModel account) async {
    if (account.isDefault) {
      await _db
          .update(_db.accountsTable)
          .write(const AccountsTableCompanion(isDefault: Value(false)));
    }

    await _db
        .into(_db.accountsTable)
        .insertOnConflictUpdate(_toCompanion(account));
  }

  Future<AccountModel> saveAccount(AccountModel account) async {
    final accountWithSummary = account.copyWith(
      summary: _calculation.buildSummary(account, isRu: true),
      updatedAt: DateTime.now(),
    );
    await upsertAccount(accountWithSummary);
    return accountWithSummary;
  }

  Future<AccountModel> createAccount({
    required String name,
    required AccountType type,
    required double balance,
    double? creditLimit,
    double? interestRateAnnual,
    int? billingDay,
    int? paymentDay,
  }) async {
    final now = DateTime.now();
    final account = AccountModel(
      id: const Uuid().v4(),
      name: name,
      type: type,
      balance: balance,
      creditLimit: type == AccountType.credit ? creditLimit : null,
      interestRateAnnual: type == AccountType.main ? null : interestRateAnnual,
      billingDay: type == AccountType.credit ? billingDay : null,
      paymentDay: type == AccountType.credit ? paymentDay : null,
      createdAt: now,
      updatedAt: now,
    );
    final accountWithSummary = account.copyWith(
      summary: _calculation.buildSummary(account, isRu: true),
    );
    await upsertAccount(accountWithSummary);
    return accountWithSummary;
  }

  Future<void> archiveAccount(String id) async {
    if (id == mainAccountId) {
      throw StateError('Нельзя архивировать основной счет');
    }

    await (_db.update(
      _db.accountsTable,
    )..where((table) => table.id.equals(id))).write(
      AccountsTableCompanion(
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  AccountsTableCompanion _toCompanion(AccountModel account) {
    return AccountsTableCompanion(
      id: Value(account.id),
      name: Value(account.name),
      type: Value(account.type.name),
      balance: Value(account.balance),
      creditLimit: Value(account.creditLimit),
      interestRateAnnual: Value(account.interestRateAnnual),
      billingDay: Value(account.billingDay),
      paymentDay: Value(account.paymentDay),
      summary: Value(
        account.summary.trim().isEmpty
            ? _calculation.buildSummary(account, isRu: true)
            : account.summary,
      ),
      isDefault: Value(account.isDefault),
      isArchived: Value(account.isArchived),
      createdAt: Value(account.createdAt),
      updatedAt: Value(account.updatedAt),
    );
  }

  AccountModel _fromTableData(AccountsTableData row) {
    return AccountModel(
      id: row.id,
      name: row.name,
      type: AccountType.values.firstWhere(
        (type) => type.name == row.type,
        orElse: () => AccountType.main,
      ),
      balance: row.balance,
      creditLimit: row.creditLimit,
      interestRateAnnual: row.interestRateAnnual,
      billingDay: row.billingDay,
      paymentDay: row.paymentDay,
      summary: row.summary,
      isDefault: row.isDefault,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  AccountOperationModel _operationFromTableData(
    AccountOperationsTableData row,
  ) {
    return AccountOperationModel(
      id: row.id,
      accountId: row.accountId,
      type: AccountOperationType.values.firstWhere(
        (type) => type.name == row.type,
        orElse: () => AccountOperationType.topUp,
      ),
      amount: row.amount,
      note: row.note,
      plannedPaymentId: row.plannedPaymentId,
      createdAt: row.createdAt,
    );
  }

  Future<AccountOperationModel?> _operationById(String id) async {
    final row = await (_db.select(
      _db.accountOperationsTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();

    return row == null ? null : _operationFromTableData(row);
  }

  double _operationDelta(AccountOperationModel operation) {
    return switch (operation.type) {
      AccountOperationType.topUp => operation.amount,
      AccountOperationType.withdraw => -operation.amount,
      AccountOperationType.autoPayment => operation.amount,
      AccountOperationType.interest => operation.amount,
    };
  }
}
