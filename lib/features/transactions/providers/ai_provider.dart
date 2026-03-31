import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/services/ai_categorization_service.dart';

final aiServiceProvider = Provider<AiCategorizationService>((ref) {
  return AiCategorizationService(
    apiKey: 'AIzaSyBTs8MlQgzp4kFEwTKOAoMKn3UgDc38WGc',
    openRouterApiKey:
        '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',
  );
});
