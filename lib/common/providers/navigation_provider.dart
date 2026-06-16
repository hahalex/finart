// Файл: lib/common/providers/navigation_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Провайдер текущей вкладки нижнего меню
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
