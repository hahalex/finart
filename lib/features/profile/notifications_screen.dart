// Файл: lib/features/profile/notifications_screen.dart.
// Назначение: строит пользовательский экран или диалог соответствующего раздела приложения.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/localization/app_strings.dart';
import '../../common/providers/notification_settings_provider.dart';
import '../../common/utils/app_theme.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late final TextEditingController _reminderTextController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(notificationSettingsProvider);
    _reminderTextController = TextEditingController(
      text: settings.reminderText,
    );
  }

  @override
  void dispose() {
    _reminderTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final colors = AppTheme.colorsOf(context);
    final strings = AppStrings.of(context);

    if (_reminderTextController.text != settings.reminderText) {
      _reminderTextController.text = settings.reminderText;
      _reminderTextController.selection = TextSelection.collapsed(
        offset: _reminderTextController.text.length,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.notifications)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            // Первая карточка отвечает за уведомления, связанные с платежами:
            // предстоящие платежи, день платежа по кредиту и закрытие долга.
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  // Главный переключатель уведомлений по предстоящим платежам.
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.upcomingPayments),
                  subtitle: Text(strings.upcomingPaymentsDescription),
                  value: settings.plannedPaymentsEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .setPlannedPaymentsEnabled(value);
                  },
                ),
                Text(
                  strings.plannedPaymentsNotificationsInfo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 28),
                SwitchListTile(
                  // Напоминание в день платежа кредитного счета.
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    strings.isRu
                        ? 'День платежа по кредиту'
                        : 'Credit payment day',
                  ),
                  subtitle: Text(
                    strings.isRu
                        ? 'Напоминать в день платежа, указанный в кредитном счете'
                        : 'Remind on the payment day configured for credit accounts',
                  ),
                  value: settings.creditPaymentDayEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .setCreditPaymentDayEnabled(value);
                  },
                ),
                SwitchListTile(
                  // Уведомление о закрытии долга, когда баланс кредитного
                  // счета достигает лимита.
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.isRu ? 'Закрытие долга' : 'Debt payoff'),
                  subtitle: Text(
                    strings.isRu
                        ? 'Уведомлять, когда баланс кредитного счета достигает лимита'
                        : 'Notify when a credit account balance reaches its limit',
                  ),
                  value: settings.creditDebtClosedEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .setCreditDebtClosedEnabled(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            // Вторая карточка — ежедневное пользовательское напоминание:
            // включение, текст и время.
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.reminder),
                  subtitle: Text(strings.reminderDescription),
                  value: settings.reminderEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .setReminderEnabled(value);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  // Текст напоминания сохраняется сразу при вводе.
                  controller: _reminderTextController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: strings.reminderText,
                    hintText: strings.reminderHint,
                  ),
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .setReminderText(
                          value.trim().isEmpty
                              ? strings.reminderDefaultText
                              : value,
                        );
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  // Строка времени открывает системный time picker.
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.access_time, color: colors.primary),
                  title: Text(strings.reminderTime),
                  subtitle: Text(settings.reminderTime.format(context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: settings.reminderTime,
                    );
                    if (picked != null) {
                      await ref
                          .read(notificationSettingsProvider.notifier)
                          .setReminderTime(picked);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
