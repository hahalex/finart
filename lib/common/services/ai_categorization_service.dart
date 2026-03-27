import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/category_model.dart';

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
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> categorizeBatch({
    required String text,
    required List<CategoryModel> categories,
  }) async {
    if (text.trim().isEmpty) {
      print('❌ AI: empty input');
      return [];
    }

    /// ============================================================
    /// 🌐 1. ПРОВЕРКА ИНТЕРНЕТА
    /// ============================================================
    final hasInternet = await _hasInternet();

    if (!hasInternet) {
      print('🚫 НЕТ ИНТЕРНЕТА — AI ЗАПРОС НЕ ОТПРАВЛЕН');
      return [];
    }

    print('🌐 Интернет есть, отправляем запрос...');

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );

    /// ============================================================
    /// 📦 2. КАТЕГОРИИ
    /// ============================================================
    final filtered = categories.where((c) => !c.isArchived).toList();

    print('\n📦 RAW CATEGORIES (${filtered.length}):');
    for (final c in filtered) {
      print(
        ' - id=${c.id} | name=${c.name} | parent=${c.parentId} | expense=${c.isExpense}',
      );
    }

    final tree = _buildCategoryTreeSafe(filtered);
    final prettyTree = const JsonEncoder.withIndent('  ').convert(tree);

    print('\n🌳 CATEGORY TREE:\n$prettyTree');

    final validIds = filtered.map((c) => c.id).toSet();

    /// ============================================================
    /// 🧠 3. PROMPT
    /// ============================================================
    final prompt =
        '''
Ты — строгая система анализа финансовых операций.

ВЕРНИ ТОЛЬКО JSON. БЕЗ ТЕКСТА.

ЗАДАЧА:
Для каждой строки:
- извлеки text
- извлеки amount
- определи is_expense
- выбери category_id

ПРАВИЛА:
- Каждая строка = отдельная операция
- Используй ТОЛЬКО id из списка
- Доход → is_expense=false
- Расход → is_expense=true
- Если не уверен → category_id=null

ТЕКСТ:
$text

КАТЕГОРИИ:
$prettyTree

ФОРМАТ:
[
  {
    "text": "строка",
    "category_id": "id или null",
    "amount": число или null,
    "is_expense": true или false
  }
]
''';

    print('\n🚀 AI REQUEST:\n$prompt');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
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
            }),
          )
          .timeout(const Duration(seconds: 20)); // ✅ 20 СЕКУНД

      print('\n📡 RAW RESPONSE:\n${response.body}');

      final data = jsonDecode(response.body);

      final textResponse =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      print('\n🧠 AI TEXT RESPONSE:\n$textResponse');

      if (textResponse == null) {
        print('❌ AI: пустой ответ');
        return [];
      }

      /// ============================================================
      /// 🔧 ПАРСИНГ JSON
      /// ============================================================
      List<dynamic> decoded;

      try {
        decoded = jsonDecode(textResponse);
      } catch (_) {
        final match = RegExp(r'\[.*\]', dotAll: true).firstMatch(textResponse);
        if (match == null) {
          print('❌ AI: JSON не найден');
          return [];
        }
        decoded = jsonDecode(match.group(0)!);
      }

      /// ============================================================
      /// 🧹 НОРМАЛИЗАЦИЯ
      /// ============================================================
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

            String? categoryId = e['category_id']?.toString();
            final isExpense = e['is_expense'] == true;

            /// fallback для доходов
            if (categoryId == null || !validIds.contains(categoryId)) {
              if (!isExpense) {
                categoryId = filtered
                    .where((c) => !c.isExpense)
                    .map((c) => c.id)
                    .cast<String?>()
                    .firstWhere((id) => id != null, orElse: () => null);
              } else {
                categoryId = null;
              }
            }

            print(
              '🔍 PARSED: text=${e['text']} | cat=$categoryId | amount=$amount | expense=$isExpense',
            );

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

      print('\n🎯 FINAL RESULT:\n$result\n');

      return result;
    } on TimeoutException {
      print('⏱️ TIMEOUT: AI не ответил за 20 секунд');
      return [];
    } on SocketException {
      print('🌐 ОШИБКА СЕТИ');
      return [];
    } catch (e, stack) {
      print('💥 AI ERROR: $e');
      print(stack);
      return [];
    }
  }

  // ============================================================
  // 🌳 ДЕРЕВО КАТЕГОРИЙ
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
