// Файл: lib/features/profile/widgets/profile_action_tile.dart.
// Назначение: содержит переиспользуемый UI-виджет приложения.

import 'package:flutter/material.dart';

/// Кнопка действия в профиле (изменить пароль, настройки и т.д.)
class ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Универсальная строка профиля: иконка слева, название/подпись по центру,
      // стрелка справа показывает, что по нажатию откроется действие или экран.
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
