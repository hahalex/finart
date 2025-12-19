import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Точка входа в приложение.
/// ProviderScope — включает систему Riverpod.
/// Все комментарии — на русском, как и просил.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Здесь позже мы инициализируем Hive (локальную БД), SharedPreferences и т.п.

  runApp(const ProviderScope(child: FinArtApp()));
}

/// Основной виджет приложения.
/// Здесь мы задаём тему и маршрутизацию.
class FinArtApp extends StatelessWidget {
  const FinArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinArt',
      debugShowCheckedModeBanner: false,

      /// Светлая и тёмная темы — пригодятся в будущем
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),

      /// Стартовый экран — временная заглушка, пока нет навигации
      home: const Scaffold(
        body: Center(
          child: Text(
            'FinArt MVP — стартовый экран',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
