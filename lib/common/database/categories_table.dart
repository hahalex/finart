import 'package:drift/drift.dart';

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconCode => integer()();
  BoolColumn get isExpense => boolean()();

  TextColumn get parentId => text().nullable()();
  IntColumn get color => integer()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get order => integer().withDefault(const Constant(0))();
  TextColumn get aiTag => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  // ✅ ИНДЕКСЫ: только raw SQL для Drift 2.x
  @override
  List<Index> get indexes => [
    Index('idx_parent', 'CREATE INDEX idx_parent ON categories (parentId)'),
    Index(
      'idx_expense_archived',
      'CREATE INDEX idx_expense_archived ON categories (isExpense, isArchived)',
    ),
  ];
}
