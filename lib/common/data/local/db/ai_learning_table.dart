// Файл: lib/common/data/local/db/ai_learning_table.dart.
// Назначение: хранит исходные данные, локальные таблицы или вспомогательный слой данных.

import 'package:drift/drift.dart';

class AiLearning extends Table {
  /// Ключевое слово, например "грин грин" или "пятёрочка".
  TextColumn get keyword => text()();

  TextColumn get normalizedText => text().withDefault(const Constant(''))();

  /// Категория, выбранная пользователем или AI.
  TextColumn get categoryId => text()();

  /// Сколько раз правило применялось.
  IntColumn get usageCount => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  List<Index> get indexes => [
    Index(
      'idx_ai_learning_normalized_text',
      'CREATE INDEX idx_ai_learning_normalized_text ON ai_learning (normalized_text)',
    ),
  ];
}
