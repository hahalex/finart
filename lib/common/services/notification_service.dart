// Файл: lib/common/services/notification_service.dart.
// Назначение: содержит прикладной сервис с бизнес-логикой, фоновой обработкой или интеграциями.

import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_settings.dart';
import '../models/planned_payment_model.dart';
import '../models/account_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _settingsKey = 'notification_settings';
  static const _plannedBaseId = 10000;
  static const _reminderBaseId = 20000;
  static const _creditPaymentBaseId = 30000;
  static const _creditClosedBaseId = 31000;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<NotificationSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return const NotificationSettings();
    }

    return NotificationSettings.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<void> syncAll({
    required NotificationSettings settings,
    required List<PlannedPaymentModel> plannedPayments,
    List<AccountModel> accounts = const [],
  }) async {
    await initialize();
    await _cancelPlannedPaymentNotifications();
    await _cancelReminderNotifications();
    await _cancelCreditPaymentDayNotifications();
    await _cancelCreditDebtClosedNotifications();

    if (settings.plannedPaymentsEnabled) {
      await _schedulePlannedPaymentNotifications(plannedPayments);
    }

    if (settings.reminderEnabled) {
      await _scheduleReminderNotifications(settings);
    }

    if (settings.creditPaymentDayEnabled) {
      await _scheduleCreditPaymentDayNotifications(accounts);
    }

    if (settings.creditDebtClosedEnabled) {
      await _scheduleCreditDebtClosedNotifications(accounts);
    }
  }

  Future<void> _schedulePlannedPaymentNotifications(
    List<PlannedPaymentModel> plannedPayments,
  ) async {
    final now = DateTime.now();
    final sorted = plannedPayments.where((payment) => payment.isActive).toList()
      ..sort(
        (a, b) => a
            .getNextOccurrenceOnOrAfter(now)
            .compareTo(b.getNextOccurrenceOnOrAfter(now)),
      );

    for (var i = 0; i < sorted.length; i++) {
      final payment = sorted[i];
      final nextDate = payment.getNextOccurrenceOnOrAfter(now);
      final scheduledLocal = DateTime(
        nextDate.year,
        nextDate.month,
        nextDate.day,
        9,
      );

      if (scheduledLocal.isBefore(now)) continue;

      await _plugin.zonedSchedule(
        _plannedBaseId + i,
        'Предстоящий платёж',
        '${payment.title}: ${payment.amount.toStringAsFixed(0)}',
        tz.TZDateTime.from(scheduledLocal.toUtc(), tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'planned_payments_channel',
            'Предстоящие платежи',
            channelDescription: 'Уведомления о запланированных платежах',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _scheduleReminderNotifications(
    NotificationSettings settings,
  ) async {
    final now = DateTime.now();

    for (var i = 0; i < 30; i++) {
      final scheduledLocal = DateTime(
        now.year,
        now.month,
        now.day + i,
        settings.reminderTime.hour,
        settings.reminderTime.minute,
      );

      if (!scheduledLocal.isAfter(now)) continue;

      await _plugin.zonedSchedule(
        _reminderBaseId + i,
        'Напоминание FinArt',
        settings.reminderText,
        tz.TZDateTime.from(scheduledLocal.toUtc(), tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Напоминания',
            channelDescription: 'Пользовательские напоминания',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _cancelPlannedPaymentNotifications() async {
    for (var i = 0; i < 200; i++) {
      await _plugin.cancel(_plannedBaseId + i);
    }
  }

  Future<void> _cancelReminderNotifications() async {
    for (var i = 0; i < 60; i++) {
      await _plugin.cancel(_reminderBaseId + i);
    }
  }

  Future<void> _scheduleCreditPaymentDayNotifications(
    List<AccountModel> accounts,
  ) async {
    final now = DateTime.now();
    final creditAccounts = accounts
        .where((account) => account.isCredit && account.paymentDay != null)
        .toList();

    for (var i = 0; i < creditAccounts.length && i < 100; i++) {
      final account = creditAccounts[i];
      final day = account.paymentDay!.clamp(1, 28).toInt();
      var scheduledLocal = DateTime(now.year, now.month, day, 9);
      if (!scheduledLocal.isAfter(now)) {
        scheduledLocal = DateTime(now.year, now.month + 1, day, 9);
      }

      await _plugin.zonedSchedule(
        _creditPaymentBaseId + i,
        'День платежа по кредиту',
        '${account.name}: сегодня день платежа',
        tz.TZDateTime.from(scheduledLocal.toUtc(), tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'credit_payment_days_channel',
            'Кредитные платежи',
            channelDescription:
                'Уведомления о днях платежа по кредитным счетам',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _scheduleCreditDebtClosedNotifications(
    List<AccountModel> accounts,
  ) async {
    final now = DateTime.now();
    final closedAccounts = accounts.where((account) {
      final limit = account.creditLimit;
      return account.isCredit && limit != null && account.balance >= limit;
    }).toList();

    for (var i = 0; i < closedAccounts.length && i < 100; i++) {
      final account = closedAccounts[i];
      final scheduledLocal = now.add(const Duration(minutes: 1));
      await _plugin.zonedSchedule(
        _creditClosedBaseId + i,
        'Кредит закрыт',
        '${account.name}: долг по счету закрыт',
        tz.TZDateTime.from(scheduledLocal.toUtc(), tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'credit_debt_closed_channel',
            'Закрытие кредитного долга',
            channelDescription:
                'Уведомления о полном закрытии кредитного счета',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> _cancelCreditPaymentDayNotifications() async {
    for (var i = 0; i < 100; i++) {
      await _plugin.cancel(_creditPaymentBaseId + i);
    }
  }

  Future<void> _cancelCreditDebtClosedNotifications() async {
    for (var i = 0; i < 100; i++) {
      await _plugin.cancel(_creditClosedBaseId + i);
    }
  }
}
