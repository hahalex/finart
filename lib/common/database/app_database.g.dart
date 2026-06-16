// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isExpenseMeta = const VerificationMeta(
    'isExpense',
  );
  @override
  late final GeneratedColumn<bool> isExpense = GeneratedColumn<bool>(
    'is_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_expense" IN (0, 1))',
    ),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _aiTagMeta = const VerificationMeta('aiTag');
  @override
  late final GeneratedColumn<String> aiTag = GeneratedColumn<String>(
    'ai_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconCode,
    isExpense,
    parentId,
    color,
    isCustom,
    isArchived,
    order,
    aiTag,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('is_expense')) {
      context.handle(
        _isExpenseMeta,
        isExpense.isAcceptableOrUnknown(data['is_expense']!, _isExpenseMeta),
      );
    } else if (isInserting) {
      context.missing(_isExpenseMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    if (data.containsKey('ai_tag')) {
      context.handle(
        _aiTagMeta,
        aiTag.isAcceptableOrUnknown(data['ai_tag']!, _aiTagMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      isExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_expense'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      aiTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_tag'],
      ),
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final String id;
  final String name;
  final int iconCode;
  final bool isExpense;
  final String? parentId;
  final int color;
  final bool isCustom;
  final bool isArchived;
  final int order;
  final String? aiTag;
  const CategoriesTableData({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.isExpense,
    this.parentId,
    required this.color,
    required this.isCustom,
    required this.isArchived,
    required this.order,
    this.aiTag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_code'] = Variable<int>(iconCode);
    map['is_expense'] = Variable<bool>(isExpense);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['color'] = Variable<int>(color);
    map['is_custom'] = Variable<bool>(isCustom);
    map['is_archived'] = Variable<bool>(isArchived);
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || aiTag != null) {
      map['ai_tag'] = Variable<String>(aiTag);
    }
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      iconCode: Value(iconCode),
      isExpense: Value(isExpense),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      color: Value(color),
      isCustom: Value(isCustom),
      isArchived: Value(isArchived),
      order: Value(order),
      aiTag: aiTag == null && nullToAbsent
          ? const Value.absent()
          : Value(aiTag),
    );
  }

  factory CategoriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      isExpense: serializer.fromJson<bool>(json['isExpense']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      color: serializer.fromJson<int>(json['color']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      order: serializer.fromJson<int>(json['order']),
      aiTag: serializer.fromJson<String?>(json['aiTag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconCode': serializer.toJson<int>(iconCode),
      'isExpense': serializer.toJson<bool>(isExpense),
      'parentId': serializer.toJson<String?>(parentId),
      'color': serializer.toJson<int>(color),
      'isCustom': serializer.toJson<bool>(isCustom),
      'isArchived': serializer.toJson<bool>(isArchived),
      'order': serializer.toJson<int>(order),
      'aiTag': serializer.toJson<String?>(aiTag),
    };
  }

  CategoriesTableData copyWith({
    String? id,
    String? name,
    int? iconCode,
    bool? isExpense,
    Value<String?> parentId = const Value.absent(),
    int? color,
    bool? isCustom,
    bool? isArchived,
    int? order,
    Value<String?> aiTag = const Value.absent(),
  }) => CategoriesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    iconCode: iconCode ?? this.iconCode,
    isExpense: isExpense ?? this.isExpense,
    parentId: parentId.present ? parentId.value : this.parentId,
    color: color ?? this.color,
    isCustom: isCustom ?? this.isCustom,
    isArchived: isArchived ?? this.isArchived,
    order: order ?? this.order,
    aiTag: aiTag.present ? aiTag.value : this.aiTag,
  );
  CategoriesTableData copyWithCompanion(CategoriesTableCompanion data) {
    return CategoriesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      isExpense: data.isExpense.present ? data.isExpense.value : this.isExpense,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      color: data.color.present ? data.color.value : this.color,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      order: data.order.present ? data.order.value : this.order,
      aiTag: data.aiTag.present ? data.aiTag.value : this.aiTag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('isExpense: $isExpense, ')
          ..write('parentId: $parentId, ')
          ..write('color: $color, ')
          ..write('isCustom: $isCustom, ')
          ..write('isArchived: $isArchived, ')
          ..write('order: $order, ')
          ..write('aiTag: $aiTag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconCode,
    isExpense,
    parentId,
    color,
    isCustom,
    isArchived,
    order,
    aiTag,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCode == this.iconCode &&
          other.isExpense == this.isExpense &&
          other.parentId == this.parentId &&
          other.color == this.color &&
          other.isCustom == this.isCustom &&
          other.isArchived == this.isArchived &&
          other.order == this.order &&
          other.aiTag == this.aiTag);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> iconCode;
  final Value<bool> isExpense;
  final Value<String?> parentId;
  final Value<int> color;
  final Value<bool> isCustom;
  final Value<bool> isArchived;
  final Value<int> order;
  final Value<String?> aiTag;
  final Value<int> rowid;
  const CategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.parentId = const Value.absent(),
    this.color = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.order = const Value.absent(),
    this.aiTag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    required String id,
    required String name,
    required int iconCode,
    required bool isExpense,
    this.parentId = const Value.absent(),
    required int color,
    this.isCustom = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.order = const Value.absent(),
    this.aiTag = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       iconCode = Value(iconCode),
       isExpense = Value(isExpense),
       color = Value(color);
  static Insertable<CategoriesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? iconCode,
    Expression<bool>? isExpense,
    Expression<String>? parentId,
    Expression<int>? color,
    Expression<bool>? isCustom,
    Expression<bool>? isArchived,
    Expression<int>? order,
    Expression<String>? aiTag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCode != null) 'icon_code': iconCode,
      if (isExpense != null) 'is_expense': isExpense,
      if (parentId != null) 'parent_id': parentId,
      if (color != null) 'color': color,
      if (isCustom != null) 'is_custom': isCustom,
      if (isArchived != null) 'is_archived': isArchived,
      if (order != null) 'order': order,
      if (aiTag != null) 'ai_tag': aiTag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? iconCode,
    Value<bool>? isExpense,
    Value<String?>? parentId,
    Value<int>? color,
    Value<bool>? isCustom,
    Value<bool>? isArchived,
    Value<int>? order,
    Value<String?>? aiTag,
    Value<int>? rowid,
  }) {
    return CategoriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      isExpense: isExpense ?? this.isExpense,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
      isArchived: isArchived ?? this.isArchived,
      order: order ?? this.order,
      aiTag: aiTag ?? this.aiTag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (isExpense.present) {
      map['is_expense'] = Variable<bool>(isExpense.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (aiTag.present) {
      map['ai_tag'] = Variable<String>(aiTag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('isExpense: $isExpense, ')
          ..write('parentId: $parentId, ')
          ..write('color: $color, ')
          ..write('isCustom: $isCustom, ')
          ..write('isArchived: $isArchived, ')
          ..write('order: $order, ')
          ..write('aiTag: $aiTag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTableTable extends AccountsTable
    with TableInfo<$AccountsTableTable, AccountsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interestRateAnnualMeta =
      const VerificationMeta('interestRateAnnual');
  @override
  late final GeneratedColumn<double> interestRateAnnual =
      GeneratedColumn<double>(
        'interest_rate_annual',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _billingDayMeta = const VerificationMeta(
    'billingDay',
  );
  @override
  late final GeneratedColumn<int> billingDay = GeneratedColumn<int>(
    'billing_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentDayMeta = const VerificationMeta(
    'paymentDay',
  );
  @override
  late final GeneratedColumn<int> paymentDay = GeneratedColumn<int>(
    'payment_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    balance,
    creditLimit,
    interestRateAnnual,
    billingDay,
    paymentDay,
    summary,
    isDefault,
    isArchived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('interest_rate_annual')) {
      context.handle(
        _interestRateAnnualMeta,
        interestRateAnnual.isAcceptableOrUnknown(
          data['interest_rate_annual']!,
          _interestRateAnnualMeta,
        ),
      );
    }
    if (data.containsKey('billing_day')) {
      context.handle(
        _billingDayMeta,
        billingDay.isAcceptableOrUnknown(data['billing_day']!, _billingDayMeta),
      );
    }
    if (data.containsKey('payment_day')) {
      context.handle(
        _paymentDayMeta,
        paymentDay.isAcceptableOrUnknown(data['payment_day']!, _paymentDayMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      ),
      interestRateAnnual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate_annual'],
      ),
      billingDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}billing_day'],
      ),
      paymentDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_day'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AccountsTableTable createAlias(String alias) {
    return $AccountsTableTable(attachedDatabase, alias);
  }
}

class AccountsTableData extends DataClass
    implements Insertable<AccountsTableData> {
  final String id;
  final String name;
  final String type;
  final double balance;
  final double? creditLimit;
  final double? interestRateAnnual;
  final int? billingDay;
  final int? paymentDay;
  final String summary;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AccountsTableData({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.creditLimit,
    this.interestRateAnnual,
    this.billingDay,
    this.paymentDay,
    required this.summary,
    required this.isDefault,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['balance'] = Variable<double>(balance);
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<double>(creditLimit);
    }
    if (!nullToAbsent || interestRateAnnual != null) {
      map['interest_rate_annual'] = Variable<double>(interestRateAnnual);
    }
    if (!nullToAbsent || billingDay != null) {
      map['billing_day'] = Variable<int>(billingDay);
    }
    if (!nullToAbsent || paymentDay != null) {
      map['payment_day'] = Variable<int>(paymentDay);
    }
    map['summary'] = Variable<String>(summary);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountsTableCompanion toCompanion(bool nullToAbsent) {
    return AccountsTableCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      balance: Value(balance),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      interestRateAnnual: interestRateAnnual == null && nullToAbsent
          ? const Value.absent()
          : Value(interestRateAnnual),
      billingDay: billingDay == null && nullToAbsent
          ? const Value.absent()
          : Value(billingDay),
      paymentDay: paymentDay == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDay),
      summary: Value(summary),
      isDefault: Value(isDefault),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AccountsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      balance: serializer.fromJson<double>(json['balance']),
      creditLimit: serializer.fromJson<double?>(json['creditLimit']),
      interestRateAnnual: serializer.fromJson<double?>(
        json['interestRateAnnual'],
      ),
      billingDay: serializer.fromJson<int?>(json['billingDay']),
      paymentDay: serializer.fromJson<int?>(json['paymentDay']),
      summary: serializer.fromJson<String>(json['summary']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'balance': serializer.toJson<double>(balance),
      'creditLimit': serializer.toJson<double?>(creditLimit),
      'interestRateAnnual': serializer.toJson<double?>(interestRateAnnual),
      'billingDay': serializer.toJson<int?>(billingDay),
      'paymentDay': serializer.toJson<int?>(paymentDay),
      'summary': serializer.toJson<String>(summary),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AccountsTableData copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    Value<double?> creditLimit = const Value.absent(),
    Value<double?> interestRateAnnual = const Value.absent(),
    Value<int?> billingDay = const Value.absent(),
    Value<int?> paymentDay = const Value.absent(),
    String? summary,
    bool? isDefault,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AccountsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    balance: balance ?? this.balance,
    creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
    interestRateAnnual: interestRateAnnual.present
        ? interestRateAnnual.value
        : this.interestRateAnnual,
    billingDay: billingDay.present ? billingDay.value : this.billingDay,
    paymentDay: paymentDay.present ? paymentDay.value : this.paymentDay,
    summary: summary ?? this.summary,
    isDefault: isDefault ?? this.isDefault,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AccountsTableData copyWithCompanion(AccountsTableCompanion data) {
    return AccountsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      balance: data.balance.present ? data.balance.value : this.balance,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      interestRateAnnual: data.interestRateAnnual.present
          ? data.interestRateAnnual.value
          : this.interestRateAnnual,
      billingDay: data.billingDay.present
          ? data.billingDay.value
          : this.billingDay,
      paymentDay: data.paymentDay.present
          ? data.paymentDay.value
          : this.paymentDay,
      summary: data.summary.present ? data.summary.value : this.summary,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('interestRateAnnual: $interestRateAnnual, ')
          ..write('billingDay: $billingDay, ')
          ..write('paymentDay: $paymentDay, ')
          ..write('summary: $summary, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    balance,
    creditLimit,
    interestRateAnnual,
    billingDay,
    paymentDay,
    summary,
    isDefault,
    isArchived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.balance == this.balance &&
          other.creditLimit == this.creditLimit &&
          other.interestRateAnnual == this.interestRateAnnual &&
          other.billingDay == this.billingDay &&
          other.paymentDay == this.paymentDay &&
          other.summary == this.summary &&
          other.isDefault == this.isDefault &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountsTableCompanion extends UpdateCompanion<AccountsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> balance;
  final Value<double?> creditLimit;
  final Value<double?> interestRateAnnual;
  final Value<int?> billingDay;
  final Value<int?> paymentDay;
  final Value<String> summary;
  final Value<bool> isDefault;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AccountsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.balance = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.interestRateAnnual = const Value.absent(),
    this.billingDay = const Value.absent(),
    this.paymentDay = const Value.absent(),
    this.summary = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsTableCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.balance = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.interestRateAnnual = const Value.absent(),
    this.billingDay = const Value.absent(),
    this.paymentDay = const Value.absent(),
    this.summary = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<AccountsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? balance,
    Expression<double>? creditLimit,
    Expression<double>? interestRateAnnual,
    Expression<int>? billingDay,
    Expression<int>? paymentDay,
    Expression<String>? summary,
    Expression<bool>? isDefault,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (balance != null) 'balance': balance,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (interestRateAnnual != null)
        'interest_rate_annual': interestRateAnnual,
      if (billingDay != null) 'billing_day': billingDay,
      if (paymentDay != null) 'payment_day': paymentDay,
      if (summary != null) 'summary': summary,
      if (isDefault != null) 'is_default': isDefault,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<double>? balance,
    Value<double?>? creditLimit,
    Value<double?>? interestRateAnnual,
    Value<int?>? billingDay,
    Value<int?>? paymentDay,
    Value<String>? summary,
    Value<bool>? isDefault,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AccountsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      interestRateAnnual: interestRateAnnual ?? this.interestRateAnnual,
      billingDay: billingDay ?? this.billingDay,
      paymentDay: paymentDay ?? this.paymentDay,
      summary: summary ?? this.summary,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (interestRateAnnual.present) {
      map['interest_rate_annual'] = Variable<double>(interestRateAnnual.value);
    }
    if (billingDay.present) {
      map['billing_day'] = Variable<int>(billingDay.value);
    }
    if (paymentDay.present) {
      map['payment_day'] = Variable<int>(paymentDay.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('interestRateAnnual: $interestRateAnnual, ')
          ..write('billingDay: $billingDay, ')
          ..write('paymentDay: $paymentDay, ')
          ..write('summary: $summary, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountOperationsTableTable extends AccountOperationsTable
    with TableInfo<$AccountOperationsTableTable, AccountOperationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountOperationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedPaymentIdMeta = const VerificationMeta(
    'plannedPaymentId',
  );
  @override
  late final GeneratedColumn<String> plannedPaymentId = GeneratedColumn<String>(
    'planned_payment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    type,
    amount,
    note,
    plannedPaymentId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_operations_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountOperationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('planned_payment_id')) {
      context.handle(
        _plannedPaymentIdMeta,
        plannedPaymentId.isAcceptableOrUnknown(
          data['planned_payment_id']!,
          _plannedPaymentIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountOperationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountOperationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      plannedPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_payment_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountOperationsTableTable createAlias(String alias) {
    return $AccountOperationsTableTable(attachedDatabase, alias);
  }
}

class AccountOperationsTableData extends DataClass
    implements Insertable<AccountOperationsTableData> {
  final String id;
  final String accountId;
  final String type;
  final double amount;
  final String? note;
  final String? plannedPaymentId;
  final DateTime createdAt;
  const AccountOperationsTableData({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    this.note,
    this.plannedPaymentId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || plannedPaymentId != null) {
      map['planned_payment_id'] = Variable<String>(plannedPaymentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountOperationsTableCompanion toCompanion(bool nullToAbsent) {
    return AccountOperationsTableCompanion(
      id: Value(id),
      accountId: Value(accountId),
      type: Value(type),
      amount: Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      plannedPaymentId: plannedPaymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedPaymentId),
      createdAt: Value(createdAt),
    );
  }

  factory AccountOperationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountOperationsTableData(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
      plannedPaymentId: serializer.fromJson<String?>(json['plannedPaymentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String?>(note),
      'plannedPaymentId': serializer.toJson<String?>(plannedPaymentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AccountOperationsTableData copyWith({
    String? id,
    String? accountId,
    String? type,
    double? amount,
    Value<String?> note = const Value.absent(),
    Value<String?> plannedPaymentId = const Value.absent(),
    DateTime? createdAt,
  }) => AccountOperationsTableData(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    note: note.present ? note.value : this.note,
    plannedPaymentId: plannedPaymentId.present
        ? plannedPaymentId.value
        : this.plannedPaymentId,
    createdAt: createdAt ?? this.createdAt,
  );
  AccountOperationsTableData copyWithCompanion(
    AccountOperationsTableCompanion data,
  ) {
    return AccountOperationsTableData(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      plannedPaymentId: data.plannedPaymentId.present
          ? data.plannedPaymentId.value
          : this.plannedPaymentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountOperationsTableData(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('plannedPaymentId: $plannedPaymentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    type,
    amount,
    note,
    plannedPaymentId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountOperationsTableData &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.plannedPaymentId == this.plannedPaymentId &&
          other.createdAt == this.createdAt);
}

class AccountOperationsTableCompanion
    extends UpdateCompanion<AccountOperationsTableData> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> type;
  final Value<double> amount;
  final Value<String?> note;
  final Value<String?> plannedPaymentId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AccountOperationsTableCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.plannedPaymentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountOperationsTableCompanion.insert({
    required String id,
    required String accountId,
    required String type,
    required double amount,
    this.note = const Value.absent(),
    this.plannedPaymentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       type = Value(type),
       amount = Value(amount);
  static Insertable<AccountOperationsTableData> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<String>? plannedPaymentId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (plannedPaymentId != null) 'planned_payment_id': plannedPaymentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountOperationsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? type,
    Value<double>? amount,
    Value<String?>? note,
    Value<String?>? plannedPaymentId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AccountOperationsTableCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      plannedPaymentId: plannedPaymentId ?? this.plannedPaymentId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (plannedPaymentId.present) {
      map['planned_payment_id'] = Variable<String>(plannedPaymentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountOperationsTableCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('plannedPaymentId: $plannedPaymentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isExpenseMeta = const VerificationMeta(
    'isExpense',
  );
  @override
  late final GeneratedColumn<bool> isExpense = GeneratedColumn<bool>(
    'is_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_expense" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    categoryId,
    accountId,
    description,
    createdAt,
    isExpense,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_expense')) {
      context.handle(
        _isExpenseMeta,
        isExpense.isAcceptableOrUnknown(data['is_expense']!, _isExpenseMeta),
      );
    } else if (isInserting) {
      context.missing(_isExpenseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_expense'],
      )!,
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final String id;
  final double amount;
  final String categoryId;
  final String? accountId;
  final String? description;
  final DateTime createdAt;
  final bool isExpense;
  const TransactionsTableData({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.accountId,
    this.description,
    required this.createdAt,
    required this.isExpense,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_expense'] = Variable<bool>(isExpense);
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      amount: Value(amount),
      categoryId: Value(categoryId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      isExpense: Value(isExpense),
    );
  }

  factory TransactionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isExpense: serializer.fromJson<bool>(json['isExpense']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<String>(categoryId),
      'accountId': serializer.toJson<String?>(accountId),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isExpense': serializer.toJson<bool>(isExpense),
    };
  }

  TransactionsTableData copyWith({
    String? id,
    double? amount,
    String? categoryId,
    Value<String?> accountId = const Value.absent(),
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    bool? isExpense,
  }) => TransactionsTableData(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    accountId: accountId.present ? accountId.value : this.accountId,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    isExpense: isExpense ?? this.isExpense,
  );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isExpense: data.isExpense.present ? data.isExpense.value : this.isExpense,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isExpense: $isExpense')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    categoryId,
    accountId,
    description,
    createdAt,
    isExpense,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.isExpense == this.isExpense);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<String> id;
  final Value<double> amount;
  final Value<String> categoryId;
  final Value<String?> accountId;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<bool> isExpense;
  final Value<int> rowid;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    required String id,
    required double amount,
    required String categoryId,
    this.accountId = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime createdAt,
    required bool isExpense,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt),
       isExpense = Value(isExpense);
  static Insertable<TransactionsTableData> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<String>? categoryId,
    Expression<String>? accountId,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<bool>? isExpense,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (isExpense != null) 'is_expense': isExpense,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<double>? amount,
    Value<String>? categoryId,
    Value<String?>? accountId,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<bool>? isExpense,
    Value<int>? rowid,
  }) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isExpense: isExpense ?? this.isExpense,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isExpense.present) {
      map['is_expense'] = Variable<bool>(isExpense.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isExpense: $isExpense, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserTableTable extends UserTable
    with TableInfo<$UserTableTable, UserTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, avatarPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
    );
  }

  @override
  $UserTableTable createAlias(String alias) {
    return $UserTableTable(attachedDatabase, alias);
  }
}

class UserTableData extends DataClass implements Insertable<UserTableData> {
  final String id;
  final String name;
  final String? avatarPath;
  const UserTableData({required this.id, required this.name, this.avatarPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    return map;
  }

  UserTableCompanion toCompanion(bool nullToAbsent) {
    return UserTableCompanion(
      id: Value(id),
      name: Value(name),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
    );
  }

  factory UserTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'avatarPath': serializer.toJson<String?>(avatarPath),
    };
  }

  UserTableData copyWith({
    String? id,
    String? name,
    Value<String?> avatarPath = const Value.absent(),
  }) => UserTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
  );
  UserTableData copyWithCompanion(UserTableCompanion data) {
    return UserTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, avatarPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarPath == this.avatarPath);
}

class UserTableCompanion extends UpdateCompanion<UserTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> avatarPath;
  final Value<int> rowid;
  const UserTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTableCompanion.insert({
    required String id,
    required String name,
    this.avatarPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<UserTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? avatarPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? avatarPath,
    Value<int>? rowid,
  }) {
    return UserTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedPaymentsTableTable extends PlannedPaymentsTable
    with TableInfo<$PlannedPaymentsTableTable, PlannedPaymentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedPaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('standard'),
  );
  static const VerificationMeta _isExpenseMeta = const VerificationMeta(
    'isExpense',
  );
  @override
  late final GeneratedColumn<bool> isExpense = GeneratedColumn<bool>(
    'is_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_expense" IN (0, 1))',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    amount,
    categoryId,
    accountId,
    paymentType,
    isExpense,
    startDate,
    recurrence,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_payments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedPaymentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    }
    if (data.containsKey('is_expense')) {
      context.handle(
        _isExpenseMeta,
        isExpense.isAcceptableOrUnknown(data['is_expense']!, _isExpenseMeta),
      );
    } else if (isInserting) {
      context.missing(_isExpenseMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    } else if (isInserting) {
      context.missing(_recurrenceMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedPaymentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedPaymentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      )!,
      isExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_expense'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlannedPaymentsTableTable createAlias(String alias) {
    return $PlannedPaymentsTableTable(attachedDatabase, alias);
  }
}

class PlannedPaymentsTableData extends DataClass
    implements Insertable<PlannedPaymentsTableData> {
  final String id;
  final String? userId;
  final String title;
  final double amount;
  final String categoryId;
  final String? accountId;
  final String paymentType;
  final bool isExpense;
  final DateTime startDate;
  final String recurrence;
  final bool isActive;
  final DateTime createdAt;
  const PlannedPaymentsTableData({
    required this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.categoryId,
    this.accountId,
    required this.paymentType,
    required this.isExpense,
    required this.startDate,
    required this.recurrence,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['payment_type'] = Variable<String>(paymentType);
    map['is_expense'] = Variable<bool>(isExpense);
    map['start_date'] = Variable<DateTime>(startDate);
    map['recurrence'] = Variable<String>(recurrence);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlannedPaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PlannedPaymentsTableCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      title: Value(title),
      amount: Value(amount),
      categoryId: Value(categoryId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      paymentType: Value(paymentType),
      isExpense: Value(isExpense),
      startDate: Value(startDate),
      recurrence: Value(recurrence),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory PlannedPaymentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedPaymentsTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      paymentType: serializer.fromJson<String>(json['paymentType']),
      isExpense: serializer.fromJson<bool>(json['isExpense']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<String>(categoryId),
      'accountId': serializer.toJson<String?>(accountId),
      'paymentType': serializer.toJson<String>(paymentType),
      'isExpense': serializer.toJson<bool>(isExpense),
      'startDate': serializer.toJson<DateTime>(startDate),
      'recurrence': serializer.toJson<String>(recurrence),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlannedPaymentsTableData copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? title,
    double? amount,
    String? categoryId,
    Value<String?> accountId = const Value.absent(),
    String? paymentType,
    bool? isExpense,
    DateTime? startDate,
    String? recurrence,
    bool? isActive,
    DateTime? createdAt,
  }) => PlannedPaymentsTableData(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    accountId: accountId.present ? accountId.value : this.accountId,
    paymentType: paymentType ?? this.paymentType,
    isExpense: isExpense ?? this.isExpense,
    startDate: startDate ?? this.startDate,
    recurrence: recurrence ?? this.recurrence,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  PlannedPaymentsTableData copyWithCompanion(
    PlannedPaymentsTableCompanion data,
  ) {
    return PlannedPaymentsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      isExpense: data.isExpense.present ? data.isExpense.value : this.isExpense,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedPaymentsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('paymentType: $paymentType, ')
          ..write('isExpense: $isExpense, ')
          ..write('startDate: $startDate, ')
          ..write('recurrence: $recurrence, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    amount,
    categoryId,
    accountId,
    paymentType,
    isExpense,
    startDate,
    recurrence,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedPaymentsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.paymentType == this.paymentType &&
          other.isExpense == this.isExpense &&
          other.startDate == this.startDate &&
          other.recurrence == this.recurrence &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class PlannedPaymentsTableCompanion
    extends UpdateCompanion<PlannedPaymentsTableData> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> title;
  final Value<double> amount;
  final Value<String> categoryId;
  final Value<String?> accountId;
  final Value<String> paymentType;
  final Value<bool> isExpense;
  final Value<DateTime> startDate;
  final Value<String> recurrence;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlannedPaymentsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.startDate = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlannedPaymentsTableCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String title,
    required double amount,
    required String categoryId,
    this.accountId = const Value.absent(),
    this.paymentType = const Value.absent(),
    required bool isExpense,
    required DateTime startDate,
    required String recurrence,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       amount = Value(amount),
       categoryId = Value(categoryId),
       isExpense = Value(isExpense),
       startDate = Value(startDate),
       recurrence = Value(recurrence);
  static Insertable<PlannedPaymentsTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? categoryId,
    Expression<String>? accountId,
    Expression<String>? paymentType,
    Expression<bool>? isExpense,
    Expression<DateTime>? startDate,
    Expression<String>? recurrence,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (paymentType != null) 'payment_type': paymentType,
      if (isExpense != null) 'is_expense': isExpense,
      if (startDate != null) 'start_date': startDate,
      if (recurrence != null) 'recurrence': recurrence,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlannedPaymentsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? title,
    Value<double>? amount,
    Value<String>? categoryId,
    Value<String?>? accountId,
    Value<String>? paymentType,
    Value<bool>? isExpense,
    Value<DateTime>? startDate,
    Value<String>? recurrence,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlannedPaymentsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      paymentType: paymentType ?? this.paymentType,
      isExpense: isExpense ?? this.isExpense,
      startDate: startDate ?? this.startDate,
      recurrence: recurrence ?? this.recurrence,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (isExpense.present) {
      map['is_expense'] = Variable<bool>(isExpense.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedPaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('paymentType: $paymentType, ')
          ..write('isExpense: $isExpense, ')
          ..write('startDate: $startDate, ')
          ..write('recurrence: $recurrence, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiLearningTable extends AiLearning
    with TableInfo<$AiLearningTable, AiLearningData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiLearningTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedTextMeta = const VerificationMeta(
    'normalizedText',
  );
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
    'normalized_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    keyword,
    normalizedText,
    categoryId,
    usageCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_learning';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiLearningData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
        _normalizedTextMeta,
        normalizedText.isAcceptableOrUnknown(
          data['normalized_text']!,
          _normalizedTextMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  AiLearningData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiLearningData(
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      )!,
      normalizedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_text'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiLearningTable createAlias(String alias) {
    return $AiLearningTable(attachedDatabase, alias);
  }
}

class AiLearningData extends DataClass implements Insertable<AiLearningData> {
  /// Ключевое слово, например "грин грин" или "пятёрочка".
  final String keyword;
  final String normalizedText;

  /// Категория, выбранная пользователем или AI.
  final String categoryId;

  /// Сколько раз правило применялось.
  final int usageCount;
  final DateTime createdAt;
  const AiLearningData({
    required this.keyword,
    required this.normalizedText,
    required this.categoryId,
    required this.usageCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['keyword'] = Variable<String>(keyword);
    map['normalized_text'] = Variable<String>(normalizedText);
    map['category_id'] = Variable<String>(categoryId);
    map['usage_count'] = Variable<int>(usageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiLearningCompanion toCompanion(bool nullToAbsent) {
    return AiLearningCompanion(
      keyword: Value(keyword),
      normalizedText: Value(normalizedText),
      categoryId: Value(categoryId),
      usageCount: Value(usageCount),
      createdAt: Value(createdAt),
    );
  }

  factory AiLearningData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiLearningData(
      keyword: serializer.fromJson<String>(json['keyword']),
      normalizedText: serializer.fromJson<String>(json['normalizedText']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'keyword': serializer.toJson<String>(keyword),
      'normalizedText': serializer.toJson<String>(normalizedText),
      'categoryId': serializer.toJson<String>(categoryId),
      'usageCount': serializer.toJson<int>(usageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiLearningData copyWith({
    String? keyword,
    String? normalizedText,
    String? categoryId,
    int? usageCount,
    DateTime? createdAt,
  }) => AiLearningData(
    keyword: keyword ?? this.keyword,
    normalizedText: normalizedText ?? this.normalizedText,
    categoryId: categoryId ?? this.categoryId,
    usageCount: usageCount ?? this.usageCount,
    createdAt: createdAt ?? this.createdAt,
  );
  AiLearningData copyWithCompanion(AiLearningCompanion data) {
    return AiLearningData(
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiLearningData(')
          ..write('keyword: $keyword, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('categoryId: $categoryId, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(keyword, normalizedText, categoryId, usageCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiLearningData &&
          other.keyword == this.keyword &&
          other.normalizedText == this.normalizedText &&
          other.categoryId == this.categoryId &&
          other.usageCount == this.usageCount &&
          other.createdAt == this.createdAt);
}

class AiLearningCompanion extends UpdateCompanion<AiLearningData> {
  final Value<String> keyword;
  final Value<String> normalizedText;
  final Value<String> categoryId;
  final Value<int> usageCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiLearningCompanion({
    this.keyword = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiLearningCompanion.insert({
    required String keyword,
    this.normalizedText = const Value.absent(),
    required String categoryId,
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : keyword = Value(keyword),
       categoryId = Value(categoryId);
  static Insertable<AiLearningData> custom({
    Expression<String>? keyword,
    Expression<String>? normalizedText,
    Expression<String>? categoryId,
    Expression<int>? usageCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (keyword != null) 'keyword': keyword,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (categoryId != null) 'category_id': categoryId,
      if (usageCount != null) 'usage_count': usageCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiLearningCompanion copyWith({
    Value<String>? keyword,
    Value<String>? normalizedText,
    Value<String>? categoryId,
    Value<int>? usageCount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AiLearningCompanion(
      keyword: keyword ?? this.keyword,
      normalizedText: normalizedText ?? this.normalizedText,
      categoryId: categoryId ?? this.categoryId,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiLearningCompanion(')
          ..write('keyword: $keyword, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('categoryId: $categoryId, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTableTable categoriesTable = $CategoriesTableTable(
    this,
  );
  late final $AccountsTableTable accountsTable = $AccountsTableTable(this);
  late final $AccountOperationsTableTable accountOperationsTable =
      $AccountOperationsTableTable(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $UserTableTable userTable = $UserTableTable(this);
  late final $PlannedPaymentsTableTable plannedPaymentsTable =
      $PlannedPaymentsTableTable(this);
  late final $AiLearningTable aiLearning = $AiLearningTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categoriesTable,
    accountsTable,
    accountOperationsTable,
    transactionsTable,
    userTable,
    plannedPaymentsTable,
    aiLearning,
  ];
}

typedef $$CategoriesTableTableCreateCompanionBuilder =
    CategoriesTableCompanion Function({
      required String id,
      required String name,
      required int iconCode,
      required bool isExpense,
      Value<String?> parentId,
      required int color,
      Value<bool> isCustom,
      Value<bool> isArchived,
      Value<int> order,
      Value<String?> aiTag,
      Value<int> rowid,
    });
typedef $$CategoriesTableTableUpdateCompanionBuilder =
    CategoriesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> iconCode,
      Value<bool> isExpense,
      Value<String?> parentId,
      Value<int> color,
      Value<bool> isCustom,
      Value<bool> isArchived,
      Value<int> order,
      Value<String?> aiTag,
      Value<int> rowid,
    });

class $$CategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiTag => $composableBuilder(
    column: $table.aiTag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiTag => $composableBuilder(
    column: $table.aiTag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<bool> get isExpense =>
      $composableBuilder(column: $table.isExpense, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get aiTag =>
      $composableBuilder(column: $table.aiTag, builder: (column) => column);
}

class $$CategoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData,
          $$CategoriesTableTableFilterComposer,
          $$CategoriesTableTableOrderingComposer,
          $$CategoriesTableTableAnnotationComposer,
          $$CategoriesTableTableCreateCompanionBuilder,
          $$CategoriesTableTableUpdateCompanionBuilder,
          (
            CategoriesTableData,
            BaseReferences<
              _$AppDatabase,
              $CategoriesTableTable,
              CategoriesTableData
            >,
          ),
          CategoriesTableData,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableTableManager(
    _$AppDatabase db,
    $CategoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<String?> aiTag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesTableCompanion(
                id: id,
                name: name,
                iconCode: iconCode,
                isExpense: isExpense,
                parentId: parentId,
                color: color,
                isCustom: isCustom,
                isArchived: isArchived,
                order: order,
                aiTag: aiTag,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int iconCode,
                required bool isExpense,
                Value<String?> parentId = const Value.absent(),
                required int color,
                Value<bool> isCustom = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<String?> aiTag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesTableCompanion.insert(
                id: id,
                name: name,
                iconCode: iconCode,
                isExpense: isExpense,
                parentId: parentId,
                color: color,
                isCustom: isCustom,
                isArchived: isArchived,
                order: order,
                aiTag: aiTag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTableTable,
      CategoriesTableData,
      $$CategoriesTableTableFilterComposer,
      $$CategoriesTableTableOrderingComposer,
      $$CategoriesTableTableAnnotationComposer,
      $$CategoriesTableTableCreateCompanionBuilder,
      $$CategoriesTableTableUpdateCompanionBuilder,
      (
        CategoriesTableData,
        BaseReferences<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData
        >,
      ),
      CategoriesTableData,
      PrefetchHooks Function()
    >;
typedef $$AccountsTableTableCreateCompanionBuilder =
    AccountsTableCompanion Function({
      required String id,
      required String name,
      required String type,
      Value<double> balance,
      Value<double?> creditLimit,
      Value<double?> interestRateAnnual,
      Value<int?> billingDay,
      Value<int?> paymentDay,
      Value<String> summary,
      Value<bool> isDefault,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AccountsTableTableUpdateCompanionBuilder =
    AccountsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<double> balance,
      Value<double?> creditLimit,
      Value<double?> interestRateAnnual,
      Value<int?> billingDay,
      Value<int?> paymentDay,
      Value<String> summary,
      Value<bool> isDefault,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AccountsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRateAnnual => $composableBuilder(
    column: $table.interestRateAnnual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billingDay => $composableBuilder(
    column: $table.billingDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentDay => $composableBuilder(
    column: $table.paymentDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRateAnnual => $composableBuilder(
    column: $table.interestRateAnnual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billingDay => $composableBuilder(
    column: $table.billingDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentDay => $composableBuilder(
    column: $table.paymentDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestRateAnnual => $composableBuilder(
    column: $table.interestRateAnnual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get billingDay => $composableBuilder(
    column: $table.billingDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentDay => $composableBuilder(
    column: $table.paymentDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AccountsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTableTable,
          AccountsTableData,
          $$AccountsTableTableFilterComposer,
          $$AccountsTableTableOrderingComposer,
          $$AccountsTableTableAnnotationComposer,
          $$AccountsTableTableCreateCompanionBuilder,
          $$AccountsTableTableUpdateCompanionBuilder,
          (
            AccountsTableData,
            BaseReferences<
              _$AppDatabase,
              $AccountsTableTable,
              AccountsTableData
            >,
          ),
          AccountsTableData,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableTableManager(_$AppDatabase db, $AccountsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<double?> interestRateAnnual = const Value.absent(),
                Value<int?> billingDay = const Value.absent(),
                Value<int?> paymentDay = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsTableCompanion(
                id: id,
                name: name,
                type: type,
                balance: balance,
                creditLimit: creditLimit,
                interestRateAnnual: interestRateAnnual,
                billingDay: billingDay,
                paymentDay: paymentDay,
                summary: summary,
                isDefault: isDefault,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                Value<double> balance = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<double?> interestRateAnnual = const Value.absent(),
                Value<int?> billingDay = const Value.absent(),
                Value<int?> paymentDay = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsTableCompanion.insert(
                id: id,
                name: name,
                type: type,
                balance: balance,
                creditLimit: creditLimit,
                interestRateAnnual: interestRateAnnual,
                billingDay: billingDay,
                paymentDay: paymentDay,
                summary: summary,
                isDefault: isDefault,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTableTable,
      AccountsTableData,
      $$AccountsTableTableFilterComposer,
      $$AccountsTableTableOrderingComposer,
      $$AccountsTableTableAnnotationComposer,
      $$AccountsTableTableCreateCompanionBuilder,
      $$AccountsTableTableUpdateCompanionBuilder,
      (
        AccountsTableData,
        BaseReferences<_$AppDatabase, $AccountsTableTable, AccountsTableData>,
      ),
      AccountsTableData,
      PrefetchHooks Function()
    >;
typedef $$AccountOperationsTableTableCreateCompanionBuilder =
    AccountOperationsTableCompanion Function({
      required String id,
      required String accountId,
      required String type,
      required double amount,
      Value<String?> note,
      Value<String?> plannedPaymentId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AccountOperationsTableTableUpdateCompanionBuilder =
    AccountOperationsTableCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String> type,
      Value<double> amount,
      Value<String?> note,
      Value<String?> plannedPaymentId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AccountOperationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountOperationsTableTable> {
  $$AccountOperationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedPaymentId => $composableBuilder(
    column: $table.plannedPaymentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountOperationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountOperationsTableTable> {
  $$AccountOperationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedPaymentId => $composableBuilder(
    column: $table.plannedPaymentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountOperationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountOperationsTableTable> {
  $$AccountOperationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get plannedPaymentId => $composableBuilder(
    column: $table.plannedPaymentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountOperationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountOperationsTableTable,
          AccountOperationsTableData,
          $$AccountOperationsTableTableFilterComposer,
          $$AccountOperationsTableTableOrderingComposer,
          $$AccountOperationsTableTableAnnotationComposer,
          $$AccountOperationsTableTableCreateCompanionBuilder,
          $$AccountOperationsTableTableUpdateCompanionBuilder,
          (
            AccountOperationsTableData,
            BaseReferences<
              _$AppDatabase,
              $AccountOperationsTableTable,
              AccountOperationsTableData
            >,
          ),
          AccountOperationsTableData,
          PrefetchHooks Function()
        > {
  $$AccountOperationsTableTableTableManager(
    _$AppDatabase db,
    $AccountOperationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountOperationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AccountOperationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AccountOperationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> plannedPaymentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountOperationsTableCompanion(
                id: id,
                accountId: accountId,
                type: type,
                amount: amount,
                note: note,
                plannedPaymentId: plannedPaymentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required String type,
                required double amount,
                Value<String?> note = const Value.absent(),
                Value<String?> plannedPaymentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountOperationsTableCompanion.insert(
                id: id,
                accountId: accountId,
                type: type,
                amount: amount,
                note: note,
                plannedPaymentId: plannedPaymentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountOperationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountOperationsTableTable,
      AccountOperationsTableData,
      $$AccountOperationsTableTableFilterComposer,
      $$AccountOperationsTableTableOrderingComposer,
      $$AccountOperationsTableTableAnnotationComposer,
      $$AccountOperationsTableTableCreateCompanionBuilder,
      $$AccountOperationsTableTableUpdateCompanionBuilder,
      (
        AccountOperationsTableData,
        BaseReferences<
          _$AppDatabase,
          $AccountOperationsTableTable,
          AccountOperationsTableData
        >,
      ),
      AccountOperationsTableData,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableTableCreateCompanionBuilder =
    TransactionsTableCompanion Function({
      required String id,
      required double amount,
      required String categoryId,
      Value<String?> accountId,
      Value<String?> description,
      required DateTime createdAt,
      required bool isExpense,
      Value<int> rowid,
    });
typedef $$TransactionsTableTableUpdateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<String> id,
      Value<double> amount,
      Value<String> categoryId,
      Value<String?> accountId,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<bool> isExpense,
      Value<int> rowid,
    });

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isExpense =>
      $composableBuilder(column: $table.isExpense, builder: (column) => column);
}

class $$TransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData,
          $$TransactionsTableTableFilterComposer,
          $$TransactionsTableTableOrderingComposer,
          $$TransactionsTableTableAnnotationComposer,
          $$TransactionsTableTableCreateCompanionBuilder,
          $$TransactionsTableTableUpdateCompanionBuilder,
          (
            TransactionsTableData,
            BaseReferences<
              _$AppDatabase,
              $TransactionsTableTable,
              TransactionsTableData
            >,
          ),
          TransactionsTableData,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableTableManager(
    _$AppDatabase db,
    $TransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion(
                id: id,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                description: description,
                createdAt: createdAt,
                isExpense: isExpense,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double amount,
                required String categoryId,
                Value<String?> accountId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                required bool isExpense,
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion.insert(
                id: id,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                description: description,
                createdAt: createdAt,
                isExpense: isExpense,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTableTable,
      TransactionsTableData,
      $$TransactionsTableTableFilterComposer,
      $$TransactionsTableTableOrderingComposer,
      $$TransactionsTableTableAnnotationComposer,
      $$TransactionsTableTableCreateCompanionBuilder,
      $$TransactionsTableTableUpdateCompanionBuilder,
      (
        TransactionsTableData,
        BaseReferences<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData
        >,
      ),
      TransactionsTableData,
      PrefetchHooks Function()
    >;
typedef $$UserTableTableCreateCompanionBuilder =
    UserTableCompanion Function({
      required String id,
      required String name,
      Value<String?> avatarPath,
      Value<int> rowid,
    });
typedef $$UserTableTableUpdateCompanionBuilder =
    UserTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> avatarPath,
      Value<int> rowid,
    });

class $$UserTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );
}

class $$UserTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserTableTable,
          UserTableData,
          $$UserTableTableFilterComposer,
          $$UserTableTableOrderingComposer,
          $$UserTableTableAnnotationComposer,
          $$UserTableTableCreateCompanionBuilder,
          $$UserTableTableUpdateCompanionBuilder,
          (
            UserTableData,
            BaseReferences<_$AppDatabase, $UserTableTable, UserTableData>,
          ),
          UserTableData,
          PrefetchHooks Function()
        > {
  $$UserTableTableTableManager(_$AppDatabase db, $UserTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserTableCompanion(
                id: id,
                name: name,
                avatarPath: avatarPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> avatarPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserTableCompanion.insert(
                id: id,
                name: name,
                avatarPath: avatarPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserTableTable,
      UserTableData,
      $$UserTableTableFilterComposer,
      $$UserTableTableOrderingComposer,
      $$UserTableTableAnnotationComposer,
      $$UserTableTableCreateCompanionBuilder,
      $$UserTableTableUpdateCompanionBuilder,
      (
        UserTableData,
        BaseReferences<_$AppDatabase, $UserTableTable, UserTableData>,
      ),
      UserTableData,
      PrefetchHooks Function()
    >;
typedef $$PlannedPaymentsTableTableCreateCompanionBuilder =
    PlannedPaymentsTableCompanion Function({
      required String id,
      Value<String?> userId,
      required String title,
      required double amount,
      required String categoryId,
      Value<String?> accountId,
      Value<String> paymentType,
      required bool isExpense,
      required DateTime startDate,
      required String recurrence,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PlannedPaymentsTableTableUpdateCompanionBuilder =
    PlannedPaymentsTableCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> title,
      Value<double> amount,
      Value<String> categoryId,
      Value<String?> accountId,
      Value<String> paymentType,
      Value<bool> isExpense,
      Value<DateTime> startDate,
      Value<String> recurrence,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PlannedPaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedPaymentsTableTable> {
  $$PlannedPaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlannedPaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedPaymentsTableTable> {
  $$PlannedPaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlannedPaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedPaymentsTableTable> {
  $$PlannedPaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isExpense =>
      $composableBuilder(column: $table.isExpense, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlannedPaymentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlannedPaymentsTableTable,
          PlannedPaymentsTableData,
          $$PlannedPaymentsTableTableFilterComposer,
          $$PlannedPaymentsTableTableOrderingComposer,
          $$PlannedPaymentsTableTableAnnotationComposer,
          $$PlannedPaymentsTableTableCreateCompanionBuilder,
          $$PlannedPaymentsTableTableUpdateCompanionBuilder,
          (
            PlannedPaymentsTableData,
            BaseReferences<
              _$AppDatabase,
              $PlannedPaymentsTableTable,
              PlannedPaymentsTableData
            >,
          ),
          PlannedPaymentsTableData,
          PrefetchHooks Function()
        > {
  $$PlannedPaymentsTableTableTableManager(
    _$AppDatabase db,
    $PlannedPaymentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedPaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedPaymentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlannedPaymentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String> paymentType = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedPaymentsTableCompanion(
                id: id,
                userId: userId,
                title: title,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                paymentType: paymentType,
                isExpense: isExpense,
                startDate: startDate,
                recurrence: recurrence,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String title,
                required double amount,
                required String categoryId,
                Value<String?> accountId = const Value.absent(),
                Value<String> paymentType = const Value.absent(),
                required bool isExpense,
                required DateTime startDate,
                required String recurrence,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedPaymentsTableCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                paymentType: paymentType,
                isExpense: isExpense,
                startDate: startDate,
                recurrence: recurrence,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlannedPaymentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlannedPaymentsTableTable,
      PlannedPaymentsTableData,
      $$PlannedPaymentsTableTableFilterComposer,
      $$PlannedPaymentsTableTableOrderingComposer,
      $$PlannedPaymentsTableTableAnnotationComposer,
      $$PlannedPaymentsTableTableCreateCompanionBuilder,
      $$PlannedPaymentsTableTableUpdateCompanionBuilder,
      (
        PlannedPaymentsTableData,
        BaseReferences<
          _$AppDatabase,
          $PlannedPaymentsTableTable,
          PlannedPaymentsTableData
        >,
      ),
      PlannedPaymentsTableData,
      PrefetchHooks Function()
    >;
typedef $$AiLearningTableCreateCompanionBuilder =
    AiLearningCompanion Function({
      required String keyword,
      Value<String> normalizedText,
      required String categoryId,
      Value<int> usageCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AiLearningTableUpdateCompanionBuilder =
    AiLearningCompanion Function({
      Value<String> keyword,
      Value<String> normalizedText,
      Value<String> categoryId,
      Value<int> usageCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AiLearningTableFilterComposer
    extends Composer<_$AppDatabase, $AiLearningTable> {
  $$AiLearningTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiLearningTableOrderingComposer
    extends Composer<_$AppDatabase, $AiLearningTable> {
  $$AiLearningTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiLearningTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiLearningTable> {
  $$AiLearningTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

  GeneratedColumn<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiLearningTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiLearningTable,
          AiLearningData,
          $$AiLearningTableFilterComposer,
          $$AiLearningTableOrderingComposer,
          $$AiLearningTableAnnotationComposer,
          $$AiLearningTableCreateCompanionBuilder,
          $$AiLearningTableUpdateCompanionBuilder,
          (
            AiLearningData,
            BaseReferences<_$AppDatabase, $AiLearningTable, AiLearningData>,
          ),
          AiLearningData,
          PrefetchHooks Function()
        > {
  $$AiLearningTableTableManager(_$AppDatabase db, $AiLearningTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiLearningTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiLearningTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiLearningTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> keyword = const Value.absent(),
                Value<String> normalizedText = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiLearningCompanion(
                keyword: keyword,
                normalizedText: normalizedText,
                categoryId: categoryId,
                usageCount: usageCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String keyword,
                Value<String> normalizedText = const Value.absent(),
                required String categoryId,
                Value<int> usageCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiLearningCompanion.insert(
                keyword: keyword,
                normalizedText: normalizedText,
                categoryId: categoryId,
                usageCount: usageCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiLearningTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiLearningTable,
      AiLearningData,
      $$AiLearningTableFilterComposer,
      $$AiLearningTableOrderingComposer,
      $$AiLearningTableAnnotationComposer,
      $$AiLearningTableCreateCompanionBuilder,
      $$AiLearningTableUpdateCompanionBuilder,
      (
        AiLearningData,
        BaseReferences<_$AppDatabase, $AiLearningTable, AiLearningData>,
      ),
      AiLearningData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(_db, _db.categoriesTable);
  $$AccountsTableTableTableManager get accountsTable =>
      $$AccountsTableTableTableManager(_db, _db.accountsTable);
  $$AccountOperationsTableTableTableManager get accountOperationsTable =>
      $$AccountOperationsTableTableTableManager(
        _db,
        _db.accountOperationsTable,
      );
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$UserTableTableTableManager get userTable =>
      $$UserTableTableTableManager(_db, _db.userTable);
  $$PlannedPaymentsTableTableTableManager get plannedPaymentsTable =>
      $$PlannedPaymentsTableTableTableManager(_db, _db.plannedPaymentsTable);
  $$AiLearningTableTableManager get aiLearning =>
      $$AiLearningTableTableManager(_db, _db.aiLearning);
}
