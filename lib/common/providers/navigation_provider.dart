import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Провайдер текущей вкладки нижнего меню
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
