// Файл: lib/common/models/notification_settings.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

import 'package:flutter/material.dart';

class NotificationSettings {
  final bool plannedPaymentsEnabled;
  final bool creditPaymentDayEnabled;
  final bool creditDebtClosedEnabled;
  final bool reminderEnabled;
  final String reminderText;
  final TimeOfDay reminderTime;

  const NotificationSettings({
    this.plannedPaymentsEnabled = false,
    this.creditPaymentDayEnabled = false,
    this.creditDebtClosedEnabled = false,
    this.reminderEnabled = false,
    this.reminderText = 'Проверьте финансы и внесите важные операции',
    this.reminderTime = const TimeOfDay(hour: 20, minute: 0),
  });

  NotificationSettings copyWith({
    bool? plannedPaymentsEnabled,
    bool? creditPaymentDayEnabled,
    bool? creditDebtClosedEnabled,
    bool? reminderEnabled,
    String? reminderText,
    TimeOfDay? reminderTime,
  }) {
    return NotificationSettings(
      plannedPaymentsEnabled:
          plannedPaymentsEnabled ?? this.plannedPaymentsEnabled,
      creditPaymentDayEnabled:
          creditPaymentDayEnabled ?? this.creditPaymentDayEnabled,
      creditDebtClosedEnabled:
          creditDebtClosedEnabled ?? this.creditDebtClosedEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderText: reminderText ?? this.reminderText,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plannedPaymentsEnabled': plannedPaymentsEnabled,
      'creditPaymentDayEnabled': creditPaymentDayEnabled,
      'creditDebtClosedEnabled': creditDebtClosedEnabled,
      'reminderEnabled': reminderEnabled,
      'reminderText': reminderText,
      'reminderHour': reminderTime.hour,
      'reminderMinute': reminderTime.minute,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      plannedPaymentsEnabled: json['plannedPaymentsEnabled'] == true,
      creditPaymentDayEnabled: json['creditPaymentDayEnabled'] == true,
      creditDebtClosedEnabled: json['creditDebtClosedEnabled'] == true,
      reminderEnabled: json['reminderEnabled'] == true,
      reminderText: (json['reminderText'] as String?)?.trim().isNotEmpty == true
          ? json['reminderText'] as String
          : 'Проверьте финансы и внесите важные операции',
      reminderTime: TimeOfDay(
        hour: (json['reminderHour'] as num?)?.toInt() ?? 20,
        minute: (json['reminderMinute'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
