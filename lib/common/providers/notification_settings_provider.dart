// Файл: lib/common/providers/notification_settings_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_settings.dart';
import 'accounts_repository_provider.dart';
import 'notification_service_provider.dart';
import 'planned_repository_provider.dart';

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((
      ref,
    ) {
      return NotificationSettingsNotifier(ref)..load();
    });

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier(this.ref) : super(const NotificationSettings());

  final Ref ref;

  Future<void> load() async {
    final settings = await ref.read(notificationServiceProvider).loadSettings();
    state = settings;
  }

  void setLoaded(NotificationSettings settings) {
    state = settings;
  }

  Future<void> setPlannedPaymentsEnabled(bool value) async {
    await _saveAndSync(state.copyWith(plannedPaymentsEnabled: value));
  }

  Future<void> setCreditPaymentDayEnabled(bool value) async {
    await _saveAndSync(state.copyWith(creditPaymentDayEnabled: value));
  }

  Future<void> setCreditDebtClosedEnabled(bool value) async {
    await _saveAndSync(state.copyWith(creditDebtClosedEnabled: value));
  }

  Future<void> setReminderEnabled(bool value) async {
    await _saveAndSync(state.copyWith(reminderEnabled: value));
  }

  Future<void> setReminderText(String value) async {
    await _saveAndSync(state.copyWith(reminderText: value));
  }

  Future<void> setReminderTime(TimeOfDay value) async {
    await _saveAndSync(state.copyWith(reminderTime: value));
  }

  Future<void> _saveAndSync(NotificationSettings settings) async {
    state = settings;
    final service = ref.read(notificationServiceProvider);
    final repository = ref.read(plannedRepositoryProvider);
    final accountsRepository = ref.read(accountsRepositoryProvider);
    final allPlannedPayments = await repository.getAllPlannedPayments();
    final accounts = await accountsRepository.getAllAccounts();
    await service.saveSettings(settings);
    await service.syncAll(
      settings: settings,
      plannedPayments: allPlannedPayments.where((p) => p.isActive).toList(),
      accounts: accounts,
    );
  }
}
