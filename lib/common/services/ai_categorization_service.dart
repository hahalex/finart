import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';

class AiCategorizationService {
  final String apiKey;

  AiCategorizationService({required this.apiKey});

  Future<List<Map<String, dynamic>>> categorizeBatch({
    required String text,
    required List<CategoryModel> categories,
  }) async {
    if (text.trim().isEmpty) {
      print('❌ AI: empty input');
      return [];
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );

    final categoryList = categories.map((c) {
      return {
        "id": c.id,
        "name": c.name,
        "aiTag": c.aiTag ?? "",
        "type": c.isExpense ? "expense" : "income",
      };
    }).toList();

    final validCategoryIds = categories.map((c) => c.id).toSet();

    final prompt =
        '''
Разбей текст на список финансовых операций.

ВАЖНО:
- Каждая строка = отдельная операция
- Определи сумму (если нет — amount = null)
- Используй ТОЛЬКО category_id из списка
- Не выдумывай категории
- Если не уверен → category_id = null

Текст:
$text

Категории:
${jsonEncode(categoryList)}

Верни ТОЛЬКО JSON массив:

[
  {
    "text": "кофе",
    "category_id": "food",
    "amount": 3.5,
    "is_expense": true
  }
]
''';

    try {
      print('🚀 AI REQUEST:');
      print(prompt);

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
                "temperature": 0.1,
                "response_mime_type": "application/json",
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('📡 RAW RESPONSE: ${response.body}');

      final data = jsonDecode(response.body);

      final textResponse =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      print('🧠 AI TEXT RESPONSE: $textResponse');

      if (textResponse == null) {
        print('❌ AI: textResponse is null');
        return [];
      }

      /// 🔥 НАДЁЖНЫЙ ПАРСИНГ JSON
      final match = RegExp(r'\[.*\]', dotAll: true).firstMatch(textResponse);

      if (match == null) {
        print('❌ AI: JSON array not found');
        return [];
      }

      final jsonString = match.group(0)!;

      print('✅ EXTRACTED JSON: $jsonString');

      final List<dynamic> decoded = jsonDecode(jsonString);

      final result = decoded
          .whereType<Map<String, dynamic>>()
          .map((e) {
            final rawAmount = e['amount'];

            double? parsedAmount;

            if (rawAmount is num) {
              parsedAmount = rawAmount.toDouble();
            } else if (rawAmount is String) {
              parsedAmount = double.tryParse(rawAmount.replaceAll(',', '.'));
            }

            final categoryId = e['category_id']?.toString();

            return {
              "text": e['text']?.toString(),
              "category_id": validCategoryIds.contains(categoryId)
                  ? categoryId
                  : null,
              "amount": parsedAmount,
              "is_expense": e['is_expense'] == true,
            };
          })
          /// ❗ ФИЛЬТР: ТОЛЬКО С ВАЛИДНОЙ СУММОЙ
          .where((e) {
            final amount = e['amount'] as double?;
            return amount != null && amount > 0;
          })
          .toList();

      print('🎯 FINAL PARSED RESULT: $result');

      return result;
    } catch (e, stack) {
      print('💥 AI ERROR: $e');
      print(stack);
      return [];
    }
  }
}
