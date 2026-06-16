// Файл: lib/common/services/ai_categorization_service.dart.
// Назначение: содержит прикладной сервис с бизнес-логикой, фоновой обработкой или интеграциями.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/category_model.dart';
import 'ai_learning_service.dart';

enum AiErrorType {
  noInternet,
  timeout,
  unauthorized,
  rateLimited,
  server,
  cancelled,
  unknown,
}

class AiResult {
  AiResult({
    required this.data,
    this.error,
    this.unresolvedLines = const [],
    this.canFallbackToManual = false,
  });

  final List<Map<String, dynamic>> data;
  final AiErrorType? error;
  final List<String> unresolvedLines;
  final bool canFallbackToManual;

  bool get hasError => error != null;
}

class AiCategorizationService {
  AiCategorizationService({
    required this.aiLearningService,
    this.gigachatAuthorizationKey,
    this.gigachatModel = 'GigaChat-2',
    this.geminiApiKey,
    this.geminiModel = 'gemini-2.5-flash',
    this.openRouterApiKey,
    this.openRouterModel = 'google/gemma-3-4b-it:free',
    List<Uri>? gigachatOAuthEndpoints,
    List<Uri>? gigachatCompletionEndpoints,
    List<Uri>? geminiEndpoints,
    List<Uri>? openRouterEndpoints,
    this.requestTimeout = const Duration(seconds: 45),
    this.maxRetries = 2,
  }) : gigachatOAuthEndpoints =
           gigachatOAuthEndpoints ??
           [Uri.parse('https://ngw.devices.sberbank.ru:9443/api/v2/oauth')],
       gigachatCompletionEndpoints =
           gigachatCompletionEndpoints ??
           [
             Uri.parse(
               'https://gigachat.devices.sberbank.ru/api/v1/chat/completions',
             ),
           ],
       geminiEndpoints =
           geminiEndpoints ??
           [Uri.parse('https://generativelanguage.googleapis.com/v1beta')],
       openRouterEndpoints =
           openRouterEndpoints ??
           [Uri.parse('https://openrouter.ai/api/v1/chat/completions')];

  final AiLearningService aiLearningService;
  final String? gigachatAuthorizationKey;
  final String gigachatModel;
  final String? geminiApiKey;
  final String geminiModel;
  final String? openRouterApiKey;
  final String openRouterModel;
  final List<Uri> gigachatOAuthEndpoints;
  final List<Uri> gigachatCompletionEndpoints;
  final List<Uri> geminiEndpoints;
  final List<Uri> openRouterEndpoints;
  final Duration requestTimeout;
  final int maxRetries;

  final Map<String, String> _localMappings = {};
  final Uuid _uuid = const Uuid();

  http.Client? _activeClient;
  int _requestCounter = 0;
  int _activeRequestId = 0;
  bool _cancelRequested = false;

  bool get isRequestInFlight => _activeRequestId != 0;

  void _log(String message) {
    print('[AI] $message');
  }

  Future<void> warmUp() async {
    await aiLearningService.warmUp();
  }

  void cancelActiveRequest() {
    if (_activeRequestId == 0) {
      return;
    }
    _cancelRequested = true;
    _activeClient?.close();
    _activeClient = null;
    _log('cancel requested');
  }

  Future<void> saveMapping(String text, String categoryId) async {
    final key = _normalize(text);
    if (key.isEmpty) return;

    _localMappings[key] = categoryId;
    _log('learned mapping "$key" -> $categoryId');
    await aiLearningService.learn(text: text, categoryId: categoryId);
  }

  Future<AiResult> categorizeBatch({
    required String text,
    required List<CategoryModel> categories,
  }) async {
    if (isRequestInFlight) {
      cancelActiveRequest();
    }

    final requestId = ++_requestCounter;
    _activeRequestId = requestId;
    _cancelRequested = false;

    _log('categorizeBatch start');
    try {
      await aiLearningService.warmUp();
      _ensureActive(requestId);

      if (text.trim().isEmpty) {
        _log('empty input');
        return AiResult(data: []);
      }

      final lines = text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      final filtered = categories.where((c) => !c.isArchived).toList();
      final validIds = filtered.map((c) => c.id).toSet();

      final localResults = <Map<String, dynamic>>[];
      final remainingLines = <String>[];

      for (final line in lines) {
        _ensureActive(requestId);
        final categoryId = await _findLocalCategoryId(line);
        if (categoryId != null && validIds.contains(categoryId)) {
          _log('local match "$line" -> $categoryId');
          localResults.add({
            'text': line,
            'category_id': categoryId,
            'amount': _extractAmount(line),
            'is_expense': _resolveIsExpense(filtered, categoryId),
          });
        } else {
          remainingLines.add(line);
        }
      }

      if (remainingLines.isEmpty) {
        _log('all lines resolved locally');
        return AiResult(data: localResults);
      }

      final tree = _buildCategoryTreeSafe(filtered);
      final prettyTree = const JsonEncoder.withIndent('  ').convert(tree);

      final prompt =
          '''
You categorize personal finance transactions.
Return JSON only, as an array of objects.
For each line, always return:
- text
- category_id
- amount
- is_expense

If uncertain, choose the closest category by meaning.

Transactions:
${remainingLines.join('\n')}

Available categories:
$prettyTree

Response format:
[
  {
    "text": "Coffee 300",
    "category_id": "food_cafe",
    "amount": 300,
    "is_expense": true
  }
]
''';

      _log('remaining lines: ${remainingLines.length}');
      _log('categories available: ${filtered.length}');
      _log('provider order: GigaChat -> Gemini -> OpenRouter');

      final attempts = <ProviderAttemptResult?>[
        await _tryGigaChat(prompt, requestId),
        await _tryGemini(prompt, requestId),
        await _tryOpenRouter(prompt, requestId),
      ];

      AiErrorType? finalError;
      for (final attempt in attempts) {
        if (attempt == null) continue;

        if (attempt.content != null) {
          _log('${attempt.provider} returned content, decoding JSON');
          try {
            final decoded = _decodeResponse(attempt.content!);
            final aiResults = decoded
                .whereType<Map<String, dynamic>>()
                .map((e) {
                  final amount = _parseAmount(e['amount']);
                  var categoryId = e['category_id']?.toString();
                  final isExpense = e['is_expense'] == true;

                  if (categoryId == null || !validIds.contains(categoryId)) {
                    categoryId = _fallbackCategory(filtered, isExpense);
                  }

                  return {
                    'text': e['text']?.toString() ?? '',
                    'category_id': categoryId,
                    'amount': amount,
                    'is_expense': isExpense,
                  };
                })
                .where(
                  (e) =>
                      (e['amount'] as double?) != null &&
                      (e['amount'] as double) > 0,
                )
                .toList();

            _log('AI success: ${aiResults.length} parsed results');
            return AiResult(data: [...localResults, ...aiResults]);
          } catch (error) {
            _log('${attempt.provider} content decode failed: $error');
            finalError = _preferError(finalError, AiErrorType.server);
          }
        } else if (attempt.error != null) {
          _log('${attempt.provider} failed with error: ${attempt.error}');
          finalError = _preferError(finalError, attempt.error);
        }
      }

      final resolvedError = finalError ?? AiErrorType.unknown;
      _log('all providers failed, final error: $resolvedError');
      return AiResult(
        data: localResults,
        error: resolvedError,
        unresolvedLines: remainingLines,
        canFallbackToManual: true,
      );
    } on _AiCancelledException {
      _log('categorizeBatch cancelled');
      return AiResult(
        data: const [],
        error: AiErrorType.cancelled,
        canFallbackToManual: true,
      );
    } catch (error) {
      _log('categorizeBatch exception: $error');
      return AiResult(
        data: const [],
        error: _classifyException(error),
        canFallbackToManual: true,
      );
    } finally {
      if (_activeRequestId == requestId) {
        _activeClient?.close();
        _activeClient = null;
        _activeRequestId = 0;
        _cancelRequested = false;
      }
    }
  }

  Future<String?> _findLocalCategoryId(String line) async {
    final normalized = _normalize(line);
    if (normalized.isEmpty) return null;

    final memoryHit = _localMappings[normalized];
    if (memoryHit != null) {
      return memoryHit;
    }

    final learnedHit = await aiLearningService.findCategory(line);
    if (learnedHit != null) {
      _localMappings[normalized] = learnedHit;
    }
    return learnedHit;
  }

  bool _resolveIsExpense(List<CategoryModel> categories, String categoryId) {
    return categories.firstWhere((c) => c.id == categoryId).isExpense;
  }

  Future<ProviderAttemptResult?> _tryGigaChat(
    String prompt,
    int requestId,
  ) async {
    final authKey = gigachatAuthorizationKey?.trim();
    if (authKey == null || authKey.isEmpty) {
      _log('GigaChat skipped: empty authorization key');
      return null;
    }

    try {
      _log('trying GigaChat OAuth');
      final tokenResponse = await _postAcrossEndpoints(
        endpoints: gigachatOAuthEndpoints,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'RqUID': _uuid.v4(),
          'Authorization': 'Basic $authKey',
        },
        body: 'scope=GIGACHAT_API_PERS',
        encodeJson: false,
        requestId: requestId,
      );

      if (!tokenResponse.isSuccess) {
        return ProviderAttemptResult(
          provider: 'GigaChat OAuth',
          error: tokenResponse.error,
          statusCode: tokenResponse.statusCode,
        );
      }

      final tokenJson = jsonDecode(tokenResponse.body!) as Map<String, dynamic>;
      final accessToken = tokenJson['access_token']?.toString();
      if (accessToken == null || accessToken.isEmpty) {
        return const ProviderAttemptResult(
          provider: 'GigaChat OAuth',
          error: AiErrorType.server,
        );
      }

      _log('trying GigaChat completion model=$gigachatModel');
      final completionResponse = await _postAcrossEndpoints(
        endpoints: gigachatCompletionEndpoints,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: {
          'model': gigachatModel,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'max_tokens': 900,
          'temperature': 0,
        },
        requestId: requestId,
      );

      if (!completionResponse.isSuccess) {
        return ProviderAttemptResult(
          provider: 'GigaChat',
          error: completionResponse.error,
          statusCode: completionResponse.statusCode,
        );
      }

      final data = jsonDecode(completionResponse.body!) as Map<String, dynamic>;
      final content = data['choices']?[0]?['message']?['content']?.toString();
      if (content == null || content.isEmpty) {
        return const ProviderAttemptResult(
          provider: 'GigaChat',
          error: AiErrorType.server,
        );
      }

      _log('GigaChat success');
      return ProviderAttemptResult(provider: 'GigaChat', content: content);
    } catch (error) {
      _log('GigaChat exception: $error');
      return ProviderAttemptResult(
        provider: 'GigaChat',
        error: _classifyException(error),
      );
    }
  }

  Future<ProviderAttemptResult?> _tryGemini(
    String prompt,
    int requestId,
  ) async {
    final apiKey = geminiApiKey?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      _log('Gemini skipped: empty API key');
      return null;
    }

    try {
      _log('trying Gemini model=$geminiModel');
      final response = await _postAcrossEndpoints(
        endpoints: geminiEndpoints
            .map(
              (base) => base.replace(
                path: '${base.path}/models/$geminiModel:generateContent',
                queryParameters: {'key': apiKey},
              ),
            )
            .toList(),
        headers: const {'Content-Type': 'application/json'},
        body: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0,
            'response_mime_type': 'application/json',
          },
        },
        requestId: requestId,
      );

      if (!response.isSuccess) {
        return ProviderAttemptResult(
          provider: 'Gemini',
          error: response.error,
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body!) as Map<String, dynamic>;
      final content = data['candidates']?[0]?['content']?['parts']?[0]?['text']
          ?.toString();
      if (content == null || content.isEmpty) {
        return const ProviderAttemptResult(
          provider: 'Gemini',
          error: AiErrorType.server,
        );
      }

      _log('Gemini success');
      return ProviderAttemptResult(provider: 'Gemini', content: content);
    } catch (error) {
      _log('Gemini exception: $error');
      return ProviderAttemptResult(
        provider: 'Gemini',
        error: _classifyException(error),
      );
    }
  }

  Future<ProviderAttemptResult?> _tryOpenRouter(
    String prompt,
    int requestId,
  ) async {
    final apiKey = openRouterApiKey?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      _log('OpenRouter skipped: empty API key');
      return null;
    }

    try {
      _log('trying OpenRouter model=$openRouterModel');
      final response = await _postAcrossEndpoints(
        endpoints: openRouterEndpoints,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: {
          'model': openRouterModel,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0,
        },
        requestId: requestId,
      );

      if (!response.isSuccess) {
        return ProviderAttemptResult(
          provider: 'OpenRouter',
          error: response.error,
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body!) as Map<String, dynamic>;
      final content = data['choices']?[0]?['message']?['content']?.toString();
      if (content == null || content.isEmpty) {
        return const ProviderAttemptResult(
          provider: 'OpenRouter',
          error: AiErrorType.server,
        );
      }

      _log('OpenRouter success');
      return ProviderAttemptResult(provider: 'OpenRouter', content: content);
    } catch (error) {
      _log('OpenRouter exception: $error');
      return ProviderAttemptResult(
        provider: 'OpenRouter',
        error: _classifyException(error),
      );
    }
  }

  Future<_HttpResult> _postAcrossEndpoints({
    required List<Uri> endpoints,
    required Map<String, String> headers,
    required Object body,
    required int requestId,
    bool encodeJson = true,
  }) async {
    AiErrorType? finalError;
    int? finalStatusCode;

    for (final endpoint in endpoints) {
      _ensureActive(requestId);
      final result = await _postWithRetry(
        uri: endpoint,
        headers: headers,
        body: body,
        requestId: requestId,
        encodeJson: encodeJson,
      );

      if (result.isSuccess) {
        return result;
      }

      finalError = _preferError(finalError, result.error);
      finalStatusCode = result.statusCode ?? finalStatusCode;

      if (!_shouldTryNextEndpoint(result.error)) {
        break;
      }

      _log('switching endpoint after ${result.error}');
    }

    return _HttpResult(
      error: finalError ?? AiErrorType.unknown,
      statusCode: finalStatusCode,
    );
  }

  Future<_HttpResult> _postWithRetry({
    required Uri uri,
    required Map<String, String> headers,
    required Object body,
    required int requestId,
    bool encodeJson = true,
  }) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      _ensureActive(requestId);
      try {
        _log('HTTP POST ${uri.toString()} attempt=${attempt + 1}');

        final client = http.Client();
        _activeClient = client;
        final response = await client
            .post(
              uri,
              headers: headers,
              body: encodeJson ? jsonEncode(body) : body.toString(),
            )
            .timeout(requestTimeout);

        if (_activeRequestId == requestId) {
          _activeClient?.close();
          _activeClient = null;
        }

        final error = _classifyStatus(response.statusCode);
        if (error == null) {
          _log('HTTP success status=${response.statusCode}');
          return _HttpResult(
            body: response.body,
            statusCode: response.statusCode,
          );
        }

        _log(
          'HTTP error status=${response.statusCode} body=${_shorten(response.body)}',
        );

        if (!_shouldRetry(error) || attempt == maxRetries) {
          return _HttpResult(error: error, statusCode: response.statusCode);
        }

        final delay = _retryDelay(attempt);
        _log('retrying after ${delay.inMilliseconds}ms because of $error');
        await _delayCancellable(delay, requestId);
      } catch (error) {
        if (_activeRequestId == requestId) {
          _activeClient?.close();
          _activeClient = null;
        }

        final classified = _classifyException(error);
        _log('HTTP exception for ${uri.toString()}: $error => $classified');

        if (!_shouldRetry(classified) || attempt == maxRetries) {
          return _HttpResult(error: classified);
        }

        final delay = _retryDelay(attempt);
        _log('retrying after ${delay.inMilliseconds}ms because of $classified');
        await _delayCancellable(delay, requestId);
      }
    }

    return const _HttpResult(error: AiErrorType.unknown);
  }

  void _ensureActive(int requestId) {
    if (_cancelRequested || _activeRequestId != requestId) {
      throw const _AiCancelledException();
    }
  }

  Future<void> _delayCancellable(Duration duration, int requestId) async {
    await Future<void>.delayed(duration);
    _ensureActive(requestId);
  }

  Duration _retryDelay(int attempt) {
    final milliseconds = 800 * (1 << attempt);
    return Duration(milliseconds: milliseconds);
  }

  bool _shouldRetry(AiErrorType? error) {
    switch (error) {
      case AiErrorType.timeout:
      case AiErrorType.rateLimited:
      case AiErrorType.server:
      case AiErrorType.noInternet:
        return true;
      case AiErrorType.unauthorized:
      case AiErrorType.cancelled:
      case AiErrorType.unknown:
      case null:
        return false;
    }
  }

  bool _shouldTryNextEndpoint(AiErrorType? error) {
    switch (error) {
      case AiErrorType.timeout:
      case AiErrorType.noInternet:
      case AiErrorType.server:
        return true;
      case AiErrorType.rateLimited:
      case AiErrorType.unauthorized:
      case AiErrorType.cancelled:
      case AiErrorType.unknown:
      case null:
        return false;
    }
  }

  AiErrorType _classifyException(Object error) {
    if (error is _AiCancelledException) return AiErrorType.cancelled;
    if (error is TimeoutException) return AiErrorType.timeout;
    if (error is SocketException || error is HandshakeException) {
      return AiErrorType.noInternet;
    }
    if (error is http.ClientException && _cancelRequested) {
      return AiErrorType.cancelled;
    }
    return AiErrorType.unknown;
  }

  AiErrorType? _classifyStatus(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return null;
    if (statusCode == 401 || statusCode == 403) return AiErrorType.unauthorized;
    if (statusCode == 408) return AiErrorType.timeout;
    if (statusCode == 429) return AiErrorType.rateLimited;
    if (statusCode >= 500) return AiErrorType.server;
    return AiErrorType.server;
  }

  AiErrorType _preferError(AiErrorType? current, AiErrorType? candidate) {
    if (candidate == null) return current ?? AiErrorType.unknown;
    if (current == null) return candidate;

    int rank(AiErrorType value) {
      switch (value) {
        case AiErrorType.cancelled:
          return 100;
        case AiErrorType.unauthorized:
          return 90;
        case AiErrorType.rateLimited:
          return 80;
        case AiErrorType.timeout:
          return 70;
        case AiErrorType.server:
          return 60;
        case AiErrorType.noInternet:
          return 50;
        case AiErrorType.unknown:
          return 10;
      }
    }

    return rank(candidate) >= rank(current) ? candidate : current;
  }

  List<dynamic> _decodeResponse(String response) {
    try {
      return jsonDecode(response) as List<dynamic>;
    } catch (_) {
      final match = RegExp(r'\[.*\]', dotAll: true).firstMatch(response);
      if (match == null) {
        throw const FormatException('No JSON array found');
      }
      return jsonDecode(match.group(0)!) as List<dynamic>;
    }
  }

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

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[\d.,€$₽]+'), ' ')
        .replaceAll(RegExp(r'[^a-zа-яё\s-]', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Map<String, dynamic> _buildCategoryTreeSafe(List<CategoryModel> categories) {
    final subMap = <String, List<Map<String, dynamic>>>{};
    final byId = {for (final c in categories) c.id: c};

    for (final c in categories) {
      if (c.parentId == null) {
        subMap[c.id] = [];
      }
    }

    for (final c in categories) {
      if (c.parentId != null && byId.containsKey(c.parentId)) {
        subMap[c.parentId!] ??= [];
        subMap[c.parentId!]!.add({
          'id': c.id,
          'name': c.name,
          'type': c.isExpense ? 'expense' : 'income',
          'keywords': [
            c.name.toLowerCase(),
            if (c.aiTag != null) c.aiTag!.toLowerCase(),
          ],
        });
      }
    }

    return {
      'categories': categories
          .where((c) => c.parentId == null)
          .map(
            (root) => {
              'id': root.id,
              'name': root.name,
              'type': root.isExpense ? 'expense' : 'income',
              'keywords': [
                root.name.toLowerCase(),
                if (root.aiTag != null) root.aiTag!.toLowerCase(),
              ],
              'subcategories': subMap[root.id] ?? [],
            },
          )
          .toList(),
    };
  }

  String _shorten(String value, [int limit = 500]) {
    if (value.length <= limit) return value;
    return '${value.substring(0, limit)}...';
  }
}

class ProviderAttemptResult {
  const ProviderAttemptResult({
    required this.provider,
    this.content,
    this.error,
    this.statusCode,
  });

  final String provider;
  final String? content;
  final AiErrorType? error;
  final int? statusCode;
}

class _HttpResult {
  const _HttpResult({this.body, this.error, this.statusCode});

  final String? body;
  final AiErrorType? error;
  final int? statusCode;

  bool get isSuccess => body != null && error == null;
}

class _AiCancelledException implements Exception {
  const _AiCancelledException();
}
