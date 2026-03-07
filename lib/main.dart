import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/utils/app_theme.dart';
import 'common/widgets/app_initializer.dart';
import 'common/database/app_database.dart';
import 'common/database/test_planned_payments.dart';

// 3. Создаём экземпляр базы для тестов (только для отладки!)
final _testDb = AppDatabase();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 ОТЛАДКА: тест миграции
  // await _runDatabaseTest();

  runApp(ProviderScope(observers: [], child: const FinArtApp()));
}

/// Временная функция для тестирования БД вне виджетов
Future<void> _runDatabaseTest() async {
  try {
    await testPlannedPayments(_testDb);
  } catch (e) {
    print('❌ Тест провален: $e');
  }
  // После теста можно закрыть базу, если нужно:
  await _testDb.close();
}

class FinArtApp extends StatelessWidget {
  const FinArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinArt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const AppInitializer(),
    );
  }
}
