import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/utils/app_theme.dart';
import 'common/widgets/app_initializer.dart';
import 'common/database/app_database.dart';
import 'common/providers/planned_repository_provider.dart';
import 'common/providers/planned_payments_provider.dart';

// ОТЛАДКА
// import 'common/debug/test_planned_payments.dart';
// import 'common/repositories/test_planned_repository.dart';
// import 'common/debug/test_due_payment.dart'; // ✅ Новый импорт

// 3. Создаём экземпляр базы для тестов (только для отладки!)
// final _testDb = AppDatabase();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 ОТЛАДКА: тест миграции и репозитория
  // await _runDatabaseTest();

  runApp(ProviderScope(observers: [], child: const FinArtApp()));
}

// /// Временная функция для тестирования БД вне виджетов
// Future<void> _runDatabaseTest() async {
//   try {
//     await testPlannedPayments(_testDb);
//     await testPlannedRepository(_testDb);
//     await testDuePayment(_testDb); // ✅ Новый вызов
//   } catch (e) {
//     print('❌ Тест провален: $e');
//   }
//   await _testDb.close();
// }

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class FinArtApp extends StatelessWidget {
  const FinArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      title: 'FinArt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const AppInitializer(),
    );
  }
}
