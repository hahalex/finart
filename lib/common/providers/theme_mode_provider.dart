// Файл: lib/common/providers/theme_mode_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier()..loadTheme();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  static const _prefsKey = 'selected_theme_mode';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_prefsKey);

    state = switch (savedMode) {
      'system' => ThemeMode.system,
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      null => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final storedMode = switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
    };
    await prefs.setString(_prefsKey, storedMode);
  }
}
