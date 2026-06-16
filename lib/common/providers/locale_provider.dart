// Файл: lib/common/providers/locale_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>((
  ref,
) {
  return LocaleNotifier()..loadLanguage();
});

class LocaleNotifier extends StateNotifier<AppLanguage> {
  LocaleNotifier() : super(AppLanguage.russian);

  static const _prefsKey = 'selected_app_language';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppLanguage.fromCode(prefs.getString(_prefsKey));
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }
}
