import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/category_model.dart';

/// Тип ошибки AI
enum AiErrorType { noInternet, timeout, server, unknown }

class AiResult {
  final List<Map<String, dynamic>> data;
  final AiErrorType? error;

  AiResult({required this.data, this.error});

  bool get hasError => error != null;
}

class AiCategorizationService {
  final String apiKey;

  AiCategorizationService({required this.apiKey});

  // ============================================================
  // 🌐 ПРОВЕРКА ИНТЕРНЕТА
  // ============================================================
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

  // ============================================================
  // 🔁 RETRY
  // ============================================================
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

  // ============================================================
  // 🚀 ОСНОВНОЙ МЕТОД
  // ============================================================
  Future<AiResult> categorizeBatch({
    required String text,
    required List<CategoryModel> categories,
  }) async {
    if (text.trim().isEmpty) {
      print('❌ EMPTY INPUT');
      return AiResult(data: []);
    }

    /// 🌐 Интернет
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      print('🚫 NO INTERNET');
      return AiResult(data: [], error: AiErrorType.noInternet);
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );

    final filtered = categories.where((c) => !c.isArchived).toList();
    final validIds = filtered.map((c) => c.id).toSet();

    final tree = _buildCategoryTreeSafe(filtered);
    final prettyTree = const JsonEncoder.withIndent('  ').convert(tree);

    // ============================================================
    // 🔥 УМНЫЙ PROMPT (КЛЮЧЕВОЕ)
    // ============================================================
    final prompt =
        '''
Ты — система категоризации финансовых операций.

❗ ВЕРНИ ТОЛЬКО JSON (без текста).

ЗАДАЧА:
Для КАЖДОЙ строки:
- извлеки text
- извлеки amount
- определи is_expense
- ОБЯЗАТЕЛЬНО выбери category_id

❗ ГЛАВНОЕ ПРАВИЛО:
category_id НИКОГДА НЕ ДОЛЖЕН БЫТЬ null

❗ ИНТЕЛЛЕКТУАЛЬНАЯ ЛОГИКА:
Если в тексте:
- указаны магазины (Пятёрочка, Lidl, Maxima, Rimi и т.д.)
→ определи ЧТО обычно там покупают
→ отнеси к подходящей категории (например: продукты)

Если:
"Пятёрочка 1500"
→ это продукты

Если:
"Steam 2000"
→ это игры / развлечения

Если:
"McDonalds 500"
→ это еда

❗ ВАЖНО:
- Даже если не уверен — выбери САМУЮ БЛИЗКУЮ категорию
- Никогда не оставляй category_id пустым
- Используй ТОЛЬКО id из списка

ТЕКСТ:
$text

КАТЕГОРИИ:
$prettyTree

ФОРМАТ:
[
  {
    "text": "строка",
    "category_id": "обязательно id",
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

      print('\n📡 RESPONSE:\n${response.body}');

      final data = jsonDecode(response.body);

      final textResponse =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (textResponse == null) {
        return AiResult(data: [], error: AiErrorType.server);
      }

      // ============================================================
      // 🔧 ПАРСИНГ
      // ============================================================
      List<dynamic> decoded;

      try {
        decoded = jsonDecode(textResponse);
      } catch (_) {
        final match = RegExp(r'\[.*\]', dotAll: true).firstMatch(textResponse);
        if (match == null) {
          return AiResult(data: [], error: AiErrorType.server);
        }
        decoded = jsonDecode(match.group(0)!);
      }

      // ============================================================
      // 🧹 НОРМАЛИЗАЦИЯ + ЖЁСТКИЙ FALLBACK
      // ============================================================
      final result = decoded
          .whereType<Map<String, dynamic>>()
          .map((e) {
            final rawAmount = e['amount'];

            double? amount;
            if (rawAmount is num) {
              amount = rawAmount.toDouble();
            } else if (rawAmount is String) {
              amount = double.tryParse(rawAmount.replaceAll(',', '.'));
            }

            final isExpense = e['is_expense'] == true;

            String? categoryId = e['category_id']?.toString();

            /// 🔥 ЖЁСТКИЙ FALLBACK (НИКОГДА НЕ NULL)
            if (categoryId == null || !validIds.contains(categoryId)) {
              categoryId = _fallbackCategory(filtered, isExpense);
            }

            print('🔍 FINAL: ${e['text']} → $categoryId | $amount');

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

      print('\n🎯 RESULT:\n$result\n');

      return AiResult(data: result);
    } on TimeoutException {
      return AiResult(data: [], error: AiErrorType.timeout);
    } on SocketException {
      return AiResult(data: [], error: AiErrorType.noInternet);
    } catch (e) {
      print('💥 ERROR: $e');
      return AiResult(data: [], error: AiErrorType.unknown);
    }
  }

  // ============================================================
  // 🔥 FALLBACK КАТЕГОРИЯ
  // ============================================================
  String _fallbackCategory(List<CategoryModel> categories, bool isExpense) {
    final filtered = categories.where((c) => c.isExpense == isExpense);

    if (filtered.isNotEmpty) {
      return filtered.first.id;
    }

    return categories.first.id;
  }

  // ============================================================
  // 🌳 ДЕРЕВО + KEYWORDS
  // ============================================================
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
