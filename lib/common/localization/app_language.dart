// Файл: lib/common/localization/app_language.dart.
// Назначение: хранит языковые настройки и строки интерфейса для русского и английского языков.

import 'package:flutter/material.dart';

enum AppLanguage {
  russian('ru', Locale('ru')),
  english('en', Locale('en'));

  const AppLanguage(this.code, this.locale);

  final String code;
  final Locale locale;

  static AppLanguage fromCode(String? code) {
    return switch (code) {
      'en' => AppLanguage.english,
      _ => AppLanguage.russian,
    };
  }
}
