// Файл: lib/common/providers/avatar_service_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/avatar_service.dart';

final avatarServiceProvider = Provider<AvatarService>((ref) {
  return AvatarService();
});
