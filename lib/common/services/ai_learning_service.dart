// Файл: lib/common/services/ai_learning_service.dart.
// Назначение: содержит прикладной сервис с бизнес-логикой, фоновой обработкой или интеграциями.

import '../data/local/dao/ai_learning_dao.dart';
import '../database/app_database.dart';

class AiLearningService {
  AiLearningService(this.dao);

  final AiLearningDao dao;
  final Map<String, String> _exactCache = {};
  List<AiLearningData>? _entriesCache;

  Future<List<AiLearningData>> getEntries() async {
    final entries = await _loadEntries();
    return List<AiLearningData>.unmodifiable(entries);
  }

  Future<String?> findCategory(String text) async {
    final normalized = _normalize(text);
    if (normalized.isEmpty) return null;

    final exactHit = _exactCache[normalized];
    if (exactHit != null) {
      return exactHit;
    }

    final exactEntry = await dao.getByNormalizedText(normalized);
    if (exactEntry != null) {
      _exactCache[normalized] = exactEntry.categoryId;
      return exactEntry.categoryId;
    }

    final all = await _loadEntries();
    if (all.isEmpty) return null;

    String? bestCategoryId;
    double bestScore = 0;
    int bestUsageCount = -1;

    for (final item in all) {
      final keyword = _normalize(item.keyword);
      if (keyword.isEmpty) continue;

      final score = _scoreMatch(normalized, keyword);
      if (score > bestScore ||
          (score == bestScore &&
              score > 0 &&
              item.usageCount > bestUsageCount)) {
        bestScore = score;
        bestUsageCount = item.usageCount;
        bestCategoryId = item.categoryId;
      }
    }

    if (bestScore >= 0.72) {
      return bestCategoryId;
    }

    return null;
  }

  Future<void> learn({required String text, required String categoryId}) async {
    final keyword = _extractKeyword(text);
    if (keyword.length < 2) return;

    await dao.insertOrUpdate(keyword, categoryId);
    _exactCache[keyword] = categoryId;
    _entriesCache = null;
  }

  Future<void> warmUp() async {
    await _loadEntries();
  }

  Future<List<AiLearningData>> _loadEntries() async {
    final cached = _entriesCache;
    if (cached != null) {
      return cached;
    }

    final entries = await dao.getAll();
    _entriesCache = entries;
    for (final item in entries) {
      final normalized = item.normalizedText.trim().isEmpty
          ? _normalize(item.keyword)
          : item.normalizedText;
      if (normalized.isNotEmpty) {
        _exactCache[normalized] = item.categoryId;
      }
    }
    return entries;
  }

  String _extractKeyword(String text) => _normalize(text);

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[\d.,€$₽]+'), ' ')
        .replaceAll(RegExp(r'[^a-zа-яё\s-]', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  double _scoreMatch(String source, String keyword) {
    if (source == keyword) return 1;
    if (source.contains(keyword) || keyword.contains(source)) return 0.92;

    final sourceWords = source.split(' ').where((e) => e.isNotEmpty).toSet();
    final keywordWords = keyword.split(' ').where((e) => e.isNotEmpty).toSet();

    if (sourceWords.isNotEmpty && keywordWords.isNotEmpty) {
      final overlap = sourceWords.intersection(keywordWords).length;
      if (overlap > 0) {
        final union = sourceWords.union(keywordWords).length;
        final tokenScore = overlap / union;
        if (tokenScore >= 0.66) {
          return 0.8 + tokenScore * 0.15;
        }
      }
    }

    final distance = _levenshtein(source, keyword);
    final maxLength = source.length > keyword.length
        ? source.length
        : keyword.length;
    if (maxLength == 0) return 0;
    return 1 - (distance / maxLength);
  }

  int _levenshtein(String a, String b) {
    final costs = List<int>.generate(b.length + 1, (index) => index);

    for (var i = 1; i <= a.length; i++) {
      var previous = costs[0];
      costs[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final current = costs[j];
        final substitution = a[i - 1] == b[j - 1] ? previous : previous + 1;
        costs[j] = [
          costs[j] + 1,
          costs[j - 1] + 1,
          substitution,
        ].reduce((x, y) => x < y ? x : y);
        previous = current;
      }
    }

    return costs[b.length];
  }
}
