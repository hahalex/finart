import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/user_provider.dart';
import 'domain/user_model.dart';
import 'widgets/profile_action_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Аватар + имя
          Column(
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 12),
              Text(user.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              if (user.email?.isNotEmpty == true)
                Text(
                  user.email!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),

          const SizedBox(height: 32),

          /// Действия
          ProfileActionTile(
            icon: Icons.edit,
            title: 'Изменить профиль',
            onTap: () => _showEditDialog(context, ref, user),
          ),
          ProfileActionTile(
            icon: Icons.lock,
            title: 'Сменить пароль',
            onTap: () {},
          ),
          ProfileActionTile(
            icon: Icons.settings,
            title: 'Настройки',
            onTap: () {},
          ),

          const SizedBox(height: 16),

          /// Выход
          ProfileActionTile(icon: Icons.logout, title: 'Выйти', onTap: () {}),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Изменить профиль'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(userProvider.notifier)
                    .updateProfile(
                      name: nameController.text,
                      email: emailController.text,
                    );
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
