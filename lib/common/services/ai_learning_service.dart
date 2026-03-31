import '../data/local/dao/ai_learning_dao.dart';

class AiLearningService {
  final AiLearningDao dao;

  AiLearningService(this.dao);

  /// 🔍 ищем категорию ДО AI
  Future<String?> findCategory(String text) async {
    final all = await dao.getAll();

    final normalized = _normalize(text);

    for (final item in all) {
      if (normalized.contains(item.keyword)) {
        print('🧠 LOCAL MATCH: ${item.keyword} → ${item.categoryId}');
        return item.categoryId;
      }
    }

    return null;
  }

  /// 💾 обучаемся после действий пользователя
  Future<void> learn({required String text, required String categoryId}) async {
    final keyword = _extractKeyword(text);

    if (keyword.length < 3) return;

    print('📚 LEARN: $keyword → $categoryId');

    await dao.insertOrUpdate(keyword, categoryId);
  }

  // ------------------------------------------------------------

  // ------------------------------------------------------------
  // нормализация для поиска и обучения
  String _normalize(String text) {
    return text
        .toLowerCase() // к нижнему регистру
        .replaceAll(RegExp(r'\s+'), ' ') // множественные пробелы → один
        .trim(); // обрезаем пробелы по краям
  }

  String _extractKeyword(String text) {
    final cleaned = text.replaceAll(
      RegExp(r'[\d.,€$₽]+'),
      '',
    ); // убираем цифры и валюту
    return cleaned
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ') // нормализуем пробелы
        .trim();
  }
}
