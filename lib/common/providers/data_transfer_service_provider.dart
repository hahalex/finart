// Файл: lib/common/providers/data_transfer_service_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/data_transfer_service.dart';
import 'database_provider.dart';

final dataTransferServiceProvider = Provider<DataTransferService>((ref) {
  return DataTransferService(ref.watch(databaseProvider));
});
