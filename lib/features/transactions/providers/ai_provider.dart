// Файл: lib/features/transactions/providers/ai_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers/ai_learning_provider.dart';
import '../../../common/services/ai_categorization_service.dart';

final aiServiceProvider = Provider<AiCategorizationService>((ref) {
  return AiCategorizationService(
    aiLearningService: ref.watch(aiLearningServiceProvider),
    gigachatAuthorizationKey: _env('GIGACHAT_AUTHORIZATION_KEY'),
    gigachatModel: 'GigaChat-2',
    geminiApiKey: _env('GEMINI_API_KEY'),
    geminiModel: 'gemini-2.5-flash',
    openRouterApiKey: _env('OPENROUTER_API_KEY'),
    openRouterModel: 'google/gemma-3-4b-it:free',
  );
});

String? _env(String name) {
  const values = {
    'GIGACHAT_AUTHORIZATION_KEY': String.fromEnvironment(
      'GIGACHAT_AUTHORIZATION_KEY',
    ),
    'GEMINI_API_KEY': String.fromEnvironment('GEMINI_API_KEY'),
    'OPENROUTER_API_KEY': String.fromEnvironment('OPENROUTER_API_KEY'),
  };
  final value = values[name]?.trim();
  return value == null || value.isEmpty ? null : value;
}
