// Файл: lib/features/profile/profile_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/localization/app_language.dart';
import '../../common/localization/app_strings.dart';
import '../../common/providers/avatar_service_provider.dart';
import '../../common/providers/categories_provider.dart';
import '../../common/providers/data_transfer_service_provider.dart';
import '../../common/providers/locale_provider.dart';
import '../../common/providers/notification_service_provider.dart';
import '../../common/providers/notification_settings_provider.dart';
import '../../common/providers/planned_payments_provider.dart';
import '../../common/providers/planned_repository_provider.dart';
import '../../common/providers/theme_mode_provider.dart';
import '../../common/utils/app_theme.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/transactions/providers/transactions_notifier.dart';
import 'dev_menu_screen.dart';
import 'domain/user_model.dart';
import 'notifications_screen.dart';
import 'providers/user_provider.dart';
import 'widgets/profile_action_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final colors = AppTheme.colorsOf(context);
    final themeMode = ref.watch(themeModeProvider);
    final strings = AppStrings.of(context);
    final user = userAsync.valueOrNull;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            children: [
              CircleAvatar(
                // Аватар профиля: показывает выбранное изображение,
                // индикатор загрузки или стандартную иконку пользователя.
                radius: 44,
                backgroundColor: colors.primary.withOpacity(0.16),
                backgroundImage:
                    user != null &&
                        user.avatarPath != null &&
                        user.avatarPath!.isNotEmpty &&
                        File(user.avatarPath!).existsSync()
                    ? FileImage(File(user.avatarPath!))
                    : null,
                child: userAsync.isLoading
                    ? SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: colors.primary,
                        ),
                      )
                    : (user == null ||
                          user.avatarPath == null ||
                          user.avatarPath!.isEmpty)
                    ? Icon(Icons.person, size: 42, color: colors.primary)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                userAsync.isLoading
                    ? ' '
                    : (user == null || user.name.isEmpty
                          ? strings.profileFallbackName
                          : user.name),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFFFC940)
                      : const Color(0xFF1E776D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ProfileActionTile(
            // Редактирование имени и аватара пользователя.
            icon: Icons.edit,
            title: strings.editProfile,
            onTap: user == null
                ? () {}
                : () => _showEditProfileDialog(context, ref, user),
          ),
          ProfileActionTile(
            // Управление категориями открывается из профиля как настройка.
            icon: Icons.category,
            title: strings.categories,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoriesScreen(),
                  settings: const RouteSettings(arguments: true),
                ),
              );
            },
          ),
          ProfileActionTile(
            // Переключение светлой/темной темы.
            icon: switch (themeMode) {
              ThemeMode.system => Icons.brightness_auto_outlined,
              ThemeMode.dark => Icons.dark_mode_outlined,
              ThemeMode.light => Icons.light_mode_outlined,
            },
            title: strings.themes,
            subtitle: switch (themeMode) {
              ThemeMode.system => strings.systemTheme,
              ThemeMode.dark => strings.darkTheme,
              ThemeMode.light => strings.lightTheme,
            },
            onTap: () => _showThemeDialog(context, ref),
          ),
          ProfileActionTile(
            // Выбор языка интерфейса.
            icon: Icons.language,
            title: strings.language,
            subtitle: ref.watch(localeProvider) == AppLanguage.russian
                ? strings.russian
                : strings.english,
            onTap: () => _showLanguageDialog(context, ref),
          ),
          ProfileActionTile(
            // Настройки локальных уведомлений.
            icon: Icons.notifications,
            title: strings.notifications,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          ProfileActionTile(
            // Импорт JSON v2 из файла.
            icon: Icons.upload_file,
            title: strings.uploadData,
            onTap: () => _importData(context, ref),
          ),
          ProfileActionTile(
            // Экспорт резервной копии JSON v2.
            icon: Icons.save,
            title: strings.backup,
            onTap: () => _exportData(context, ref),
          ),
          ProfileActionTile(
            // Dev Menu содержит демонстрационные данные и опасные операции.
            icon: Icons.science_outlined,
            title: strings.devMenu,
            subtitle: strings.devMenuSubtitle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DevMenuScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final selected = ref.read(localeProvider);

    await showDialog(
      // Диалог языка сразу сохраняет выбор и закрывается.
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.chooseLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<AppLanguage>(
                value: AppLanguage.russian,
                groupValue: selected,
                title: Text(strings.russian),
                onChanged: (value) async {
                  if (value == null) return;
                  await _applyLanguage(ref, value);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
              RadioListTile<AppLanguage>(
                value: AppLanguage.english,
                groupValue: selected,
                title: Text(strings.english),
                onChanged: (value) async {
                  if (value == null) return;
                  await _applyLanguage(ref, value);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyLanguage(WidgetRef ref, AppLanguage language) async {
    await ref.read(localeProvider.notifier).setLanguage(language);
    await ref
        .read(categoriesRepositoryProvider)
        .syncDefaultCategoryLocalizations(language);
    ref.invalidate(allCategoriesProvider);
    ref.invalidate(expenseCategoriesProvider);
    ref.invalidate(incomeCategoriesProvider);
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);

    try {
      await ref.read(dataTransferServiceProvider).exportAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.exportSuccess)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.exportFailed)));
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);

    try {
      final imported = await ref
          .read(dataTransferServiceProvider)
          .importAllData();
      if (!imported) return;

      await ref
          .read(categoriesRepositoryProvider)
          .syncDefaultCategoryLocalizations(ref.read(localeProvider));

      ref.invalidate(allCategoriesProvider);
      ref.invalidate(expenseCategoriesProvider);
      ref.invalidate(incomeCategoriesProvider);
      ref.invalidate(plannedPaymentsProvider);
      await ref.read(transactionsProvider.notifier).reload();
      await ref.read(userProvider.notifier).loadUser();

      final settings = ref.read(notificationSettingsProvider);
      final plannedPayments = await ref
          .read(plannedRepositoryProvider)
          .getAllPlannedPayments();
      await ref
          .read(notificationServiceProvider)
          .syncAll(
            settings: settings,
            plannedPayments: plannedPayments.where((p) => p.isActive).toList(),
          );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.importSuccess)));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${strings.importFailed}: $error')),
        );
      }
    }
  }

  Future<void> _showThemeDialog(BuildContext context, WidgetRef ref) async {
    final selectedMode = ref.read(themeModeProvider);
    final colors = AppTheme.colorsOf(context);
    final strings = AppStrings.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.chooseTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: selectedMode,
                activeColor: colors.primary,
                title: Text(strings.systemTheme),
                subtitle: Text(
                  strings.isRu
                      ? 'Брать светлую или тёмную тему из настроек устройства'
                      : 'Use the light or dark theme from device settings',
                ),
                onChanged: (mode) async {
                  if (mode == null) return;
                  await ref.read(themeModeProvider.notifier).setTheme(mode);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: selectedMode,
                activeColor: colors.primary,
                title: Text(strings.lightTheme),
                onChanged: (mode) async {
                  if (mode == null) return;
                  await ref.read(themeModeProvider.notifier).setTheme(mode);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: selectedMode,
                activeColor: colors.primary,
                title: Text(strings.darkTheme),
                onChanged: (mode) async {
                  if (mode == null) return;
                  await ref.read(themeModeProvider.notifier).setTheme(mode);
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.close),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) async {
    final strings = AppStrings.of(context);
    final nameController = TextEditingController(text: user.name);
    String? avatarPath = user.avatarPath;
    var isAvatarLoading = false;
    var isSaving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(strings.editProfile),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    // В диалоге показываем выбранный аватар сразу после загрузки,
                    // а во время обработки файла заменяем картинку индикатором.
                    radius: 42,
                    backgroundImage:
                        !isAvatarLoading &&
                            avatarPath != null &&
                            avatarPath!.isNotEmpty &&
                            File(avatarPath!).existsSync()
                        ? FileImage(File(avatarPath!))
                        : null,
                    child: isAvatarLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : avatarPath == null || avatarPath!.isEmpty
                        ? const Icon(Icons.person, size: 36)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        // Кнопка выбора аватара открывает галерею, сохраняет
                        // сжатую копию и блокирует повторные нажатия до завершения.
                        onPressed: isAvatarLoading || isSaving
                            ? null
                            : () async {
                                setState(() => isAvatarLoading = true);
                                try {
                                  final path = await ref
                                      .read(avatarServiceProvider)
                                      .pickAndSaveAvatar(
                                        previousPath: avatarPath,
                                      );
                                  if (!dialogContext.mounted) return;
                                  setState(() {
                                    if (path != null) avatarPath = path;
                                    isAvatarLoading = false;
                                  });
                                } catch (_) {
                                  if (dialogContext.mounted) {
                                    setState(() => isAvatarLoading = false);
                                  }
                                }
                              },
                        icon: isAvatarLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.image_outlined),
                        label: Text(
                          isAvatarLoading
                              ? (strings.isRu ? 'Загрузка...' : 'Loading...')
                              : strings.chooseAvatar,
                        ),
                      ),
                      if (avatarPath != null && avatarPath!.isNotEmpty)
                        OutlinedButton.icon(
                          // Удаление аватара очищает файл и сразу возвращает
                          // стандартную иконку пользователя в предпросмотре.
                          onPressed: isAvatarLoading || isSaving
                              ? null
                              : () async {
                                  setState(() => isAvatarLoading = true);
                                  try {
                                    await ref
                                        .read(avatarServiceProvider)
                                        .removeAvatar(avatarPath);
                                    if (!dialogContext.mounted) return;
                                    setState(() {
                                      avatarPath = null;
                                      isAvatarLoading = false;
                                    });
                                  } catch (_) {
                                    if (dialogContext.mounted) {
                                      setState(() => isAvatarLoading = false);
                                    }
                                  }
                                },
                          icon: const Icon(Icons.delete_outline),
                          label: Text(strings.removeAvatar),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: strings.name),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving || isAvatarLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  // Сохранение записывает имя и путь к аватару в профиль,
                  // затем перечитывает пользователя для обновления экрана.
                  onPressed: isSaving || isAvatarLoading
                      ? null
                      : () async {
                          setState(() => isSaving = true);
                          await ref
                              .read(userProvider.notifier)
                              .updateProfile(
                                name: nameController.text.trim(),
                                avatarPath: avatarPath,
                              );
                          await ref.read(userProvider.notifier).loadUser();
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(strings.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
