// Файл: lib/common/data/local/dao/ai_learning_dao.dart.
// Назначение: изолирует доступ к данным и операции чтения/записи в локальное хранилище.

import 'package:drift/drift.dart';
import '../../../database/app_database.dart';

class AiLearningDao {
  final AppDatabase db;

  AiLearningDao(this.db);

  /// 💾 сохранить или обновить
  Future<void> insertOrUpdate(String keyword, String categoryId) async {
    final normalized = keyword.toLowerCase().trim();

    final existing = await (db.select(
      db.aiLearning,
    )..where((t) => t.normalizedText.equals(normalized))).getSingleOrNull();

    if (existing != null) {
      await (db.update(
        db.aiLearning,
      )..where((t) => t.normalizedText.equals(normalized))).write(
        AiLearningCompanion(
          keyword: Value(keyword),
          normalizedText: Value(normalized),
          categoryId: Value(categoryId),
          usageCount: Value(existing.usageCount + 1),
        ),
      );
    } else {
      await db
          .into(db.aiLearning)
          .insert(
            AiLearningCompanion.insert(
              keyword: keyword,
              normalizedText: Value(normalized),
              categoryId: categoryId,
            ),
          );
    }
  }

  Future<AiLearningData?> getByNormalizedText(String normalizedText) {
    return (db.select(
      db.aiLearning,
    )..where((t) => t.normalizedText.equals(normalizedText))).getSingleOrNull();
  }

  /// 🔍 получить всё
  Future<List<AiLearningData>> getAll() {
    return (db.select(db.aiLearning)..orderBy([
          (t) => OrderingTerm.desc(t.usageCount),
          (t) => OrderingTerm.asc(t.keyword),
        ]))
        .get();
  }
}
