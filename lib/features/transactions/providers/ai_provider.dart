import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/services/ai_categorization_service.dart';

final aiServiceProvider = Provider<AiCategorizationService>((ref) {
  return AiCategorizationService(
    apiKey: 'AIzaSyBTs8MlQgzp4kFEwTKOAoMKn3UgDc38WGc',
  );
});
