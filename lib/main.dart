// Файл: lib/main.dart.
// Назначение: точка входа приложения, подключает провайдеры, тему, локализацию и стартовый экран.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/providers/locale_provider.dart';
import 'common/providers/theme_mode_provider.dart';
import 'common/utils/app_theme.dart';
import 'common/widgets/app_initializer.dart';

// Debug helpers kept here for local manual checks.
// import 'common/debug/test_planned_payments.dart';
// import 'common/repositories/test_planned_repository.dart';
// import 'common/debug/test_due_payment.dart';

// Create a database instance only while running local debug checks.
// final _testDb = AppDatabase();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local database migration and repository tests can be enabled above.
  // await _runDatabaseTest();

  runApp(ProviderScope(observers: [], child: const FinArtApp()));
}

// Temporary helper for database checks outside widget tests.
// Future<void> _runDatabaseTest() async {
//   try {
//     await testPlannedPayments(_testDb);
//     await testPlannedRepository(_testDb);
//     await testDuePayment(_testDb);
//   } catch (e) {
//     print('Debug database test failed: $e');
//   }
//   await _testDb.close();
// }

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class FinArtApp extends ConsumerWidget {
  const FinArtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appLanguage = ref.watch(localeProvider);

    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      title: 'FinArt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 180),
      themeAnimationCurve: Curves.easeOutCubic,
      locale: appLanguage.locale,
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppInitializer(),
    );
  }
}
