// Файл: lib/common/services/data_transfer_service.dart.
// Назначение: содержит прикладной сервис с бизнес-логикой, фоновой обработкой или интеграциями.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';
import '../models/account_model.dart';
import '../models/account_operation_model.dart';
import '../models/category_model.dart';
import '../models/planned_payment_model.dart';
import '../models/transaction_model.dart';

class DataTransferService {
  DataTransferService(this._db);

  static const currentBackupVersion = 2;

  final AppDatabase _db;

  Future<File?> exportAllData() async {
    final payload = await _db.transaction(() async {
      final categories = await _db.select(_db.categoriesTable).get();
      final accounts = await _db.select(_db.accountsTable).get();
      final accountOperations = await _db
          .select(_db.accountOperationsTable)
          .get();
      final transactions = await _db.select(_db.transactionsTable).get();
      final plannedPayments = await _db.select(_db.plannedPaymentsTable).get();
      final aiLearning = await _db.select(_db.aiLearning).get();

      final data = <String, dynamic>{
        'version': currentBackupVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'categories': categories.map(_categoryToJson).toList(),
        'accounts': accounts.map(_accountToJson).toList(),
        'accountOperations': accountOperations
            .map(_accountOperationToJson)
            .toList(),
        'transactions': transactions.map(_transactionToJson).toList(),
        'plannedPayments': plannedPayments.map(_plannedPaymentToJson).toList(),
        'aiLearning': aiLearning.map(_aiLearningToJson).toList(),
      };

      data['metadata'] = {
        'schema': 'finart-json-v2',
        'counts': {
          'categories': categories.length,
          'accounts': accounts.length,
          'accountOperations': accountOperations.length,
          'transactions': transactions.length,
          'plannedPayments': plannedPayments.length,
          'aiLearning': aiLearning.length,
        },
      };
      (data['metadata'] as Map<String, dynamic>)['checksum'] = _checksumForData(
        data,
      );
      return data;
    });

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}finart_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );

    await Share.shareXFiles([XFile(file.path)], text: 'FinArt backup');
    return file;
  }

  Future<bool> importAllData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: false,
    );

    final path = result?.files.single.path;
    if (path == null) return false;

    final raw = await File(path).readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup root must be a JSON object');
    }

    _validateVersion(decoded);
    _validateChecksum(decoded);

    final parsed = _parseBackup(decoded);
    _validateLinks(parsed);

    await _db.transaction(() async {
      await _db.delete(_db.accountOperationsTable).go();
      await _db.delete(_db.transactionsTable).go();
      await _db.delete(_db.plannedPaymentsTable).go();
      await _db.delete(_db.aiLearning).go();
      await _db.delete(_db.categoriesTable).go();
      await _db.delete(_db.accountsTable).go();

      for (final category in parsed.categories) {
        await _db
            .into(_db.categoriesTable)
            .insert(
              CategoriesTableCompanion(
                id: Value(category.id),
                name: Value(category.name),
                iconCode: Value(category.iconCode),
                isExpense: Value(category.isExpense),
                parentId: Value(category.parentId),
                color: Value(category.color),
                isCustom: Value(category.isCustom),
                isArchived: Value(category.isArchived),
                order: Value(category.order),
                aiTag: Value(category.aiTag),
              ),
            );
      }

      final accounts = parsed.accounts.isEmpty
          ? [_defaultMainAccount()]
          : parsed.accounts;
      for (final account in accounts) {
        await _db
            .into(_db.accountsTable)
            .insert(
              AccountsTableCompanion(
                id: Value(account.id),
                name: Value(account.name),
                type: Value(account.type.name),
                balance: Value(account.balance),
                creditLimit: Value(account.creditLimit),
                interestRateAnnual: Value(account.interestRateAnnual),
                billingDay: Value(account.billingDay),
                paymentDay: Value(account.paymentDay),
                summary: Value(account.summary),
                isDefault: Value(account.isDefault),
                isArchived: Value(account.isArchived),
                createdAt: Value(account.createdAt),
                updatedAt: Value(account.updatedAt),
              ),
            );
      }

      for (final transaction in parsed.transactions) {
        await _db
            .into(_db.transactionsTable)
            .insert(
              TransactionsTableCompanion.insert(
                id: transaction.id,
                amount: transaction.amount,
                categoryId: transaction.categoryId,
                accountId: Value(transaction.accountId),
                description: Value(transaction.description),
                createdAt: transaction.createdAt,
                isExpense: transaction.isExpense,
              ),
            );
      }

      for (final payment in parsed.plannedPayments) {
        await _db
            .into(_db.plannedPaymentsTable)
            .insert(
              PlannedPaymentsTableCompanion(
                id: Value(payment.id),
                userId: Value(payment.userId),
                title: Value(payment.title),
                amount: Value(payment.amount),
                categoryId: Value(payment.categoryId),
                isExpense: Value(payment.isExpense),
                startDate: Value(payment.startDate),
                recurrence: Value(payment.recurrence),
                isActive: Value(payment.isActive),
                accountId: Value(payment.accountId),
                paymentType: Value(payment.paymentType.name),
                createdAt: Value(payment.createdAt),
              ),
            );
      }

      for (final operation in parsed.accountOperations) {
        await _db
            .into(_db.accountOperationsTable)
            .insert(
              AccountOperationsTableCompanion.insert(
                id: operation.id,
                accountId: operation.accountId,
                type: operation.type.name,
                amount: operation.amount,
                note: Value(operation.note),
                plannedPaymentId: Value(operation.plannedPaymentId),
                createdAt: Value(operation.createdAt),
              ),
            );
      }

      for (final item in parsed.aiLearning) {
        await _db
            .into(_db.aiLearning)
            .insert(
              AiLearningCompanion(
                keyword: Value(item.keyword),
                normalizedText: Value(item.normalizedText),
                categoryId: Value(item.categoryId),
                usageCount: Value(item.usageCount),
                createdAt: Value(item.createdAt),
              ),
            );
      }
    });

    return true;
  }

  static Map<String, dynamic> _categoryToJson(CategoriesTableData item) {
    return {
      'id': item.id,
      'name': item.name,
      'iconCode': item.iconCode,
      'isExpense': item.isExpense,
      'parentId': item.parentId,
      'color': item.color,
      'isCustom': item.isCustom,
      'isArchived': item.isArchived,
      'order': item.order,
      'aiTag': item.aiTag,
    };
  }

  static Map<String, dynamic> _accountToJson(AccountsTableData item) {
    return {
      'id': item.id,
      'name': item.name,
      'type': item.type,
      'balance': item.balance,
      'creditLimit': item.creditLimit,
      'interestRateAnnual': item.interestRateAnnual,
      'billingDay': item.billingDay,
      'paymentDay': item.paymentDay,
      'summary': item.summary,
      'isDefault': item.isDefault,
      'isArchived': item.isArchived,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _accountOperationToJson(
    AccountOperationsTableData item,
  ) {
    return {
      'id': item.id,
      'accountId': item.accountId,
      'type': item.type,
      'amount': item.amount,
      'note': item.note,
      'plannedPaymentId': item.plannedPaymentId,
      'createdAt': item.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _transactionToJson(TransactionsTableData item) {
    return {
      'id': item.id,
      'amount': item.amount,
      'categoryId': item.categoryId,
      'accountId': item.accountId,
      'description': item.description,
      'createdAt': item.createdAt.toIso8601String(),
      'isExpense': item.isExpense,
    };
  }

  static Map<String, dynamic> _plannedPaymentToJson(
    PlannedPaymentsTableData item,
  ) {
    return {
      'id': item.id,
      'userId': item.userId,
      'title': item.title,
      'amount': item.amount,
      'categoryId': item.categoryId,
      'isExpense': item.isExpense,
      'startDate': item.startDate.toIso8601String(),
      'recurrence': item.recurrence,
      'isActive': item.isActive,
      'accountId': item.accountId,
      'paymentType': item.paymentType,
      'createdAt': item.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _aiLearningToJson(AiLearningData item) {
    return {
      'keyword': item.keyword,
      'normalizedText': item.normalizedText,
      'categoryId': item.categoryId,
      'usageCount': item.usageCount,
      'createdAt': item.createdAt.toIso8601String(),
    };
  }

  static _ParsedBackup _parseBackup(Map<String, dynamic> json) {
    return _ParsedBackup(
      categories: _list(json, 'categories').map(_parseCategory).toList(),
      accounts: _list(json, 'accounts').map(_parseAccount).toList(),
      accountOperations: _list(
        json,
        'accountOperations',
      ).map(_parseAccountOperation).toList(),
      transactions: _list(json, 'transactions').map(_parseTransaction).toList(),
      plannedPayments: _list(
        json,
        'plannedPayments',
      ).map(_parsePlannedPayment).toList(),
      aiLearning: _list(json, 'aiLearning').map(_parseAiLearning).toList(),
    );
  }

  static CategoryModel _parseCategory(dynamic raw) {
    final item = _object(raw, 'category');
    return CategoryModel(
      id: _string(item, 'id'),
      name: _string(item, 'name'),
      iconCode: _int(item, 'iconCode'),
      isExpense: _bool(item, 'isExpense'),
      parentId: item['parentId'] as String?,
      color: _int(item, 'color'),
      isCustom: item['isCustom'] as bool? ?? false,
      isArchived: item['isArchived'] as bool? ?? false,
      order: item['order'] as int? ?? 0,
      aiTag: item['aiTag'] as String?,
    );
  }

  static AccountModel _parseAccount(dynamic raw) {
    final item = _object(raw, 'account');
    final type = _enumByName(
      AccountType.values,
      item['type'] as String? ?? AccountType.main.name,
      'account type',
    );
    return AccountModel(
      id: _string(item, 'id'),
      name: _string(item, 'name'),
      type: type,
      balance: _num(item, 'balance').toDouble(),
      creditLimit: (item['creditLimit'] as num?)?.toDouble(),
      interestRateAnnual: (item['interestRateAnnual'] as num?)?.toDouble(),
      billingDay: item['billingDay'] as int?,
      paymentDay: item['paymentDay'] as int?,
      summary: item['summary'] as String? ?? '',
      isDefault: item['isDefault'] as bool? ?? type == AccountType.main,
      isArchived: item['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(_string(item, 'createdAt')),
      updatedAt: DateTime.parse(_string(item, 'updatedAt')),
    );
  }

  static AccountOperationModel _parseAccountOperation(dynamic raw) {
    final item = _object(raw, 'accountOperation');
    return AccountOperationModel(
      id: _string(item, 'id'),
      accountId: _string(item, 'accountId'),
      type: _enumByName(
        AccountOperationType.values,
        item['type'] as String? ?? AccountOperationType.topUp.name,
        'account operation type',
      ),
      amount: _num(item, 'amount').toDouble(),
      note: item['note'] as String?,
      plannedPaymentId: item['plannedPaymentId'] as String?,
      createdAt: DateTime.parse(_string(item, 'createdAt')),
    );
  }

  static TransactionModel _parseTransaction(dynamic raw) {
    final item = _object(raw, 'transaction');
    return TransactionModel(
      id: _string(item, 'id'),
      amount: _num(item, 'amount').toDouble(),
      categoryId: _string(item, 'categoryId'),
      accountId: item['accountId'] as String?,
      description: item['description'] as String?,
      createdAt: DateTime.parse(_string(item, 'createdAt')),
      isExpense: _bool(item, 'isExpense'),
    );
  }

  static PlannedPaymentModel _parsePlannedPayment(dynamic raw) {
    final item = _object(raw, 'plannedPayment');
    return PlannedPaymentModel(
      id: _string(item, 'id'),
      userId: item['userId'] as String?,
      title: _string(item, 'title'),
      amount: _num(item, 'amount').toDouble(),
      categoryId: _string(item, 'categoryId'),
      isExpense: _bool(item, 'isExpense'),
      startDate: DateTime.parse(_string(item, 'startDate')),
      recurrence: _string(item, 'recurrence'),
      isActive: item['isActive'] as bool? ?? true,
      accountId: item['accountId'] as String?,
      paymentType: _enumByName(
        PlannedPaymentType.values,
        item['paymentType'] as String? ?? PlannedPaymentType.standard.name,
        'planned payment type',
      ),
      createdAt: DateTime.parse(_string(item, 'createdAt')),
    );
  }

  static AiLearningData _parseAiLearning(dynamic raw) {
    final item = _object(raw, 'aiLearning');
    final keyword = _string(item, 'keyword');
    return AiLearningData(
      keyword: keyword,
      normalizedText:
          item['normalizedText'] as String? ?? keyword.toLowerCase().trim(),
      categoryId: _string(item, 'categoryId'),
      usageCount: item['usageCount'] as int? ?? 1,
      createdAt: DateTime.parse(_string(item, 'createdAt')),
    );
  }

  static void _validateVersion(Map<String, dynamic> json) {
    final version = (json['version'] as num?)?.toInt() ?? 1;
    if (version > currentBackupVersion) {
      throw FormatException(
        'Backup version $version is newer than supported version $currentBackupVersion',
      );
    }
  }

  static void _validateChecksum(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    if (metadata is! Map<String, dynamic>) return;

    final expected = metadata['checksum'];
    if (expected is! String || expected.isEmpty) return;

    final actual = _checksumForData(json);
    if (actual != expected) {
      throw const FormatException('Backup checksum mismatch');
    }
  }

  static void _validateLinks(_ParsedBackup parsed) {
    final categoryIds = <String>{};
    final categoriesById = <String, CategoryModel>{};
    for (final category in parsed.categories) {
      if (!categoryIds.add(category.id)) {
        throw FormatException('Duplicate category id: ${category.id}');
      }
      categoriesById[category.id] = category;
    }

    for (final category in parsed.categories) {
      final parentId = category.parentId;
      if (parentId != null && !categoryIds.contains(parentId)) {
        throw FormatException(
          'Category ${category.id} has missing parent $parentId',
        );
      }
    }

    final accountIds = <String>{};
    for (final account in parsed.accounts) {
      if (!accountIds.add(account.id)) {
        throw FormatException('Duplicate account id: ${account.id}');
      }
    }
    if (parsed.accounts.isNotEmpty &&
        !accountIds.any((id) => id == 'main_account')) {
      throw const FormatException('Backup must contain the main account');
    }

    final transactionIds = <String>{};
    for (final transaction in parsed.transactions) {
      if (!transactionIds.add(transaction.id)) {
        throw FormatException('Duplicate transaction id: ${transaction.id}');
      }
      final category = categoriesById[transaction.categoryId];
      if (category == null) {
        throw FormatException(
          'Transaction ${transaction.id} references missing category ${transaction.categoryId}',
        );
      }
      if (category.isExpense != transaction.isExpense) {
        throw FormatException(
          'Transaction ${transaction.id} type conflicts with category ${category.id}',
        );
      }
      final accountId = transaction.accountId;
      if (accountId != null &&
          parsed.accounts.isNotEmpty &&
          !accountIds.contains(accountId)) {
        throw FormatException(
          'Transaction ${transaction.id} references missing account $accountId',
        );
      }
    }

    final plannedPaymentIds = <String>{};
    for (final payment in parsed.plannedPayments) {
      if (!plannedPaymentIds.add(payment.id)) {
        throw FormatException('Duplicate planned payment id: ${payment.id}');
      }
      final category = categoriesById[payment.categoryId];
      if (category == null) {
        throw FormatException(
          'Planned payment ${payment.id} references missing category ${payment.categoryId}',
        );
      }
      if (category.isExpense != payment.isExpense) {
        throw FormatException(
          'Planned payment ${payment.id} type conflicts with category ${category.id}',
        );
      }
      final accountId = payment.accountId;
      if (accountId != null &&
          parsed.accounts.isNotEmpty &&
          !accountIds.contains(accountId)) {
        throw FormatException(
          'Planned payment ${payment.id} references missing account $accountId',
        );
      }
      if (payment.paymentType.isTransfer && accountId == null) {
        throw FormatException(
          'Transfer planned payment ${payment.id} must reference an account',
        );
      }
    }

    for (final item in parsed.aiLearning) {
      if (!categoryIds.contains(item.categoryId)) {
        throw FormatException(
          'AI dictionary item ${item.keyword} references missing category ${item.categoryId}',
        );
      }
    }

    final operationIds = <String>{};
    for (final operation in parsed.accountOperations) {
      if (!operationIds.add(operation.id)) {
        throw FormatException(
          'Duplicate account operation id: ${operation.id}',
        );
      }
      if (parsed.accounts.isNotEmpty &&
          !accountIds.contains(operation.accountId)) {
        throw FormatException(
          'Account operation ${operation.id} references missing account ${operation.accountId}',
        );
      }
      final plannedPaymentId = operation.plannedPaymentId;
      if (plannedPaymentId != null &&
          !plannedPaymentIds.contains(plannedPaymentId)) {
        throw FormatException(
          'Account operation ${operation.id} references missing planned payment $plannedPaymentId',
        );
      }
    }
  }

  static String _checksumForData(Map<String, dynamic> source) {
    final copy = _deepCopy(source) as Map<String, dynamic>;
    final metadata = copy['metadata'];
    if (metadata is Map<String, dynamic>) {
      metadata.remove('checksum');
    }
    final canonical = _canonicalJson(copy);
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static String _canonicalJson(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return '{${keys.map((key) => '${jsonEncode(key)}:${_canonicalJson(value[key])}').join(',')}}';
    }
    if (value is List) {
      return '[${value.map(_canonicalJson).join(',')}]';
    }
    return jsonEncode(value);
  }

  static Object? _deepCopy(Object? value) {
    return jsonDecode(jsonEncode(value));
  }

  static List<dynamic> _list(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return const [];
    if (value is List<dynamic>) return value;
    throw FormatException('$key must be a list');
  }

  static Map<String, dynamic> _object(dynamic value, String label) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('$label must be an object');
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException('$key must be a non-empty string');
  }

  static int _int(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    throw FormatException('$key must be an integer');
  }

  static num _num(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value;
    throw FormatException('$key must be a number');
  }

  static bool _bool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is bool) return value;
    throw FormatException('$key must be a boolean');
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String name,
    String label,
  ) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    throw FormatException('Unknown $label: $name');
  }

  static AccountModel _defaultMainAccount() {
    final now = DateTime.now();
    return AccountModel(
      id: 'main_account',
      name: 'Основной счет',
      type: AccountType.main,
      balance: 0,
      summary:
          'Основной счет синхронизируется с балансом записей за выбранный месяц.',
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _ParsedBackup {
  const _ParsedBackup({
    required this.categories,
    required this.accounts,
    required this.accountOperations,
    required this.transactions,
    required this.plannedPayments,
    required this.aiLearning,
  });

  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final List<AccountOperationModel> accountOperations;
  final List<TransactionModel> transactions;
  final List<PlannedPaymentModel> plannedPayments;
  final List<AiLearningData> aiLearning;
}
