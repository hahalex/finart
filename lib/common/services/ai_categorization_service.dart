import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/category_model.dart';

/// ============================================================
/// ❗ ТИПЫ ОШИБОК
/// ============================================================
enum AiErrorType { noInternet, timeout, server, unknown }

class AiResult {
  final List<Map<String, dynamic>> data;
  final AiErrorType? error;

  AiResult({required this.data, this.error});

  bool get hasError => error != null;
}

/// ============================================================
/// 🧠 AI SERVICE
/// ============================================================
class AiCategorizationService {
  final String apiKey;

  /// 🔥 локальный словарь (будет заменён на БД позже)
  final Map<String, String> _localMappings = {};

  AiCategorizationService({required this.apiKey});

  /// ============================================================
  /// 🌐 INTERNET CHECK
  /// ============================================================
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// ============================================================
  /// 🔁 RETRY
  /// ============================================================
  Future<http.Response> _postWithRetry(
    Uri uri,
    Map<String, dynamic> body, {
    int retries = 2,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        attempt++;
        print('🔁 AI REQUEST ATTEMPT: $attempt');

        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          return response;
        }

        print('⚠️ HTTP ERROR: ${response.statusCode}');

        if (attempt > retries) return response;
      } on TimeoutException {
        print('⏱️ TIMEOUT attempt $attempt');
        if (attempt > retries) rethrow;
      } on SocketException {
        print('🌐 SOCKET ERROR attempt $attempt');
        if (attempt > retries) rethrow;
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// ============================================================
  /// 🔥 ПУБЛИЧНЫЙ МЕТОД ДЛЯ СОХРАНЕНИЯ ОБУЧЕНИЯ
  /// ============================================================
  void saveMapping(String text, String categoryId) {
    final key = _normalize(text);
    _localMappings[key] = categoryId;

    print('🧠 LEARNED: "$key" → $categoryId');
  }

  /// ============================================================
  /// 🔎 НОРМАЛИЗАЦИЯ ТЕКСТА
  /// ============================================================
  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[\d.,€$₽]+'), '').trim();
  }

  /// ============================================================
  /// 🚀 ОСНОВНОЙ МЕТОД
  /// ============================================================
  Future<AiResult> categorizeBatch({
    required String text,
    required List<CategoryModel> categories,
  }) async {
    if (text.trim().isEmpty) {
      return AiResult(data: []);
    }

    final lines = text.split('\n');

    /// ============================================================
    /// 🔥 1. ПРОВЕРКА LOCAL MAPPING
    /// ============================================================
    final List<Map<String, dynamic>> localResults = [];
    final List<String> remainingLines = [];

    for (final line in lines) {
      final key = _normalize(line);

      if (_localMappings.containsKey(key)) {
        final categoryId = _localMappings[key];

        final amount = _extractAmount(line);

        localResults.add({
          "text": line,
          "category_id": categoryId,
          "amount": amount,
          "is_expense": true,
        });

        print('⚡ LOCAL HIT: $line → $categoryId');
      } else {
        remainingLines.add(line);
      }
    }

    /// если всё покрыто локально — AI не нужен
    if (remainingLines.isEmpty) {
      return AiResult(data: localResults);
    }

    /// ============================================================
    /// 🌐 INTERNET
    /// ============================================================
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      return AiResult(data: localResults, error: AiErrorType.noInternet);
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );

    final filtered = categories.where((c) => !c.isArchived).toList();
    final validIds = filtered.map((c) => c.id).toSet();

    final tree = _buildCategoryTreeSafe(filtered);
    final prettyTree = const JsonEncoder.withIndent('  ').convert(tree);

    /// ============================================================
    /// 🔥 УЛУЧШЕННЫЙ PROMPT
    /// ============================================================
    final prompt =
        '''
Ты — эксперт по анализу финансовых операций.

❗ ВЕРНИ ТОЛЬКО JSON.

ГЛАВНАЯ ЗАДАЧА:
- определить категорию максимально точно по смыслу

ИНТЕЛЛЕКТУАЛЬНЫЕ ПРАВИЛА:
- Понимай магазины и бренды:
  Пятёрочка, Lidl, Rimi → продукты
  McDonalds → еда
  Steam → игры
  Uber → транспорт

- Делай вывод по смыслу:
  "Пятёрочка 1500" → продукты
  даже если нет слова "еда"

❗ ВАЖНО:
- ВСЕГДА выбирай category_id
- НИКОГДА не ставь null
- Если не уверен → выбери САМУЮ БЛИЗКУЮ категорию

ТЕКСТ:
${remainingLines.join('\n')}

КАТЕГОРИИ:
$prettyTree

ФОРМАТ:
[
  {
    "text": "...",
    "category_id": "обязательно",
    "amount": число,
    "is_expense": true или false
  }
]
''';

    print('\n🚀 PROMPT:\n$prompt');

    try {
      final response = await _postWithRetry(uri, {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0,
          "response_mime_type": "application/json",
        },
      });

      final data = jsonDecode(response.body);

      final textResponse =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (textResponse == null) {
        return AiResult(data: localResults, error: AiErrorType.server);
      }

      List<dynamic> decoded;

      try {
        decoded = jsonDecode(textResponse);
      } catch (_) {
        final match = RegExp(r'\[.*\]', dotAll: true).firstMatch(textResponse);
        if (match == null) {
          return AiResult(data: localResults, error: AiErrorType.server);
        }
        decoded = jsonDecode(match.group(0)!);
      }

      final aiResults = decoded
          .whereType<Map<String, dynamic>>()
          .map((e) {
            final amount = _parseAmount(e['amount']);

            final isExpense = e['is_expense'] == true;

            String? categoryId = e['category_id']?.toString();

            if (categoryId == null || !validIds.contains(categoryId)) {
              categoryId = _fallbackCategory(filtered, isExpense);
            }

            return {
              "text": e['text']?.toString(),
              "category_id": categoryId,
              "amount": amount,
              "is_expense": isExpense,
            };
          })
          .where((e) {
            final amount = e['amount'] as double?;
            return amount != null && amount > 0;
          })
          .toList();

      final result = [...localResults, ...aiResults];

      print('\n🎯 FINAL RESULT:\n$result\n');

      return AiResult(data: result);
    } on TimeoutException {
      return AiResult(data: localResults, error: AiErrorType.timeout);
    } on SocketException {
      return AiResult(data: localResults, error: AiErrorType.noInternet);
    } catch (e) {
      print('💥 ERROR: $e');
      return AiResult(data: localResults, error: AiErrorType.unknown);
    }
  }

  /// ============================================================
  /// 🔢 HELPERS
  /// ============================================================
  double? _extractAmount(String text) {
    final match = RegExp(r'(\d+[.,]?\d*)').firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(0)!.replaceAll(',', '.'));
  }

  double? _parseAmount(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      return double.tryParse(raw.replaceAll(',', '.'));
    }
    return null;
  }

  String _fallbackCategory(List<CategoryModel> categories, bool isExpense) {
    final filtered = categories.where((c) => c.isExpense == isExpense);

    if (filtered.isNotEmpty) {
      return filtered.first.id;
    }

    return categories.first.id;
  }

  /// ============================================================
  /// 🌳 TREE
  /// ============================================================
  Map<String, dynamic> _buildCategoryTreeSafe(List<CategoryModel> categories) {
    final Map<String, List<Map<String, dynamic>>> subMap = {};
    final Map<String, CategoryModel> byId = {for (var c in categories) c.id: c};

    for (final c in categories) {
      if (c.parentId == null) {
        subMap[c.id] = [];
      }
    }

    for (final c in categories) {
      if (c.parentId != null && byId.containsKey(c.parentId)) {
        subMap[c.parentId!] ??= [];
        subMap[c.parentId!]!.add({
          "id": c.id,
          "name": c.name,
          "type": c.isExpense ? "expense" : "income",
          "keywords": [
            c.name.toLowerCase(),
            if (c.aiTag != null) c.aiTag!.toLowerCase(),
          ],
        });
      }
    }

    return {
      "categories": categories
          .where((c) => c.parentId == null)
          .map(
            (root) => {
              "id": root.id,
              "name": root.name,
              "type": root.isExpense ? "expense" : "income",
              "keywords": [
                root.name.toLowerCase(),
                if (root.aiTag != null) root.aiTag!.toLowerCase(),
              ],
              "subcategories": subMap[root.id] ?? [],
            },
          )
          .toList(),
    };
  }
}
