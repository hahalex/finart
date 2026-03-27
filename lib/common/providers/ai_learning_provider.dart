import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/dao/ai_learning_dao.dart';
import '../providers/database_provider.dart';
import '../services/ai_learning_service.dart';

final aiLearningServiceProvider = Provider<AiLearningService>((ref) {
  final db = ref.watch(databaseProvider); // 👈 у тебя уже есть
  return AiLearningService(AiLearningDao(db));
});
