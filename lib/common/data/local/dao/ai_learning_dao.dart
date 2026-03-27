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
    )..where((t) => t.keyword.equals(normalized))).getSingleOrNull();

    if (existing != null) {
      await (db.update(
        db.aiLearning,
      )..where((t) => t.keyword.equals(normalized))).write(
        AiLearningCompanion(
          categoryId: Value(categoryId),
          usageCount: Value(existing.usageCount + 1),
        ),
      );
    } else {
      await db
          .into(db.aiLearning)
          .insert(
            AiLearningCompanion.insert(
              keyword: normalized,
              categoryId: categoryId,
            ),
          );
    }
  }

  /// 🔍 получить всё
  Future<List<AiLearningData>> getAll() {
    return db.select(db.aiLearning).get();
  }
}
