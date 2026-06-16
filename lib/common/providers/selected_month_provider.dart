// Файл: lib/common/providers/selected_month_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

String getMonthName(
  DateTime date, {
  bool short = false,
  String languageCode = 'ru',
}) {
  final isRu = languageCode.toLowerCase().startsWith('ru');

  const ruMonths = [
    '',
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];
  const ruMonthsShort = [
    '',
    'Янв',
    'Фев',
    'Мар',
    'Апр',
    'Май',
    'Июн',
    'Июл',
    'Авг',
    'Сен',
    'Окт',
    'Ноя',
    'Дек',
  ];
  const enMonths = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  const enMonthsShort = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final months = isRu
      ? (short ? ruMonthsShort : ruMonths)
      : (short ? enMonthsShort : enMonths);
  return months[date.month];
}

(DateTime start, DateTime end) getMonthRange(DateTime monthDate) {
  final start = DateTime(monthDate.year, monthDate.month, 1);
  final end = monthDate.month == 12
      ? DateTime(monthDate.year + 1, 1, 1)
      : DateTime(monthDate.year, monthDate.month + 1, 1);
  return (start, end);
}
