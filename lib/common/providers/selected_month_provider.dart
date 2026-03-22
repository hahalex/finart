import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Провайдер текущего выбранного месяца для фильтрации транзакций
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  // Возвращаем 1-е число текущего месяца для удобства сравнения
  return DateTime(now.year, now.month, 1);
});

/// Вспомогательный метод: получить название месяца на русском
String getMonthName(DateTime date, {bool short = false}) {
  const months = [
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
  const monthsShort = [
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
  return short ? monthsShort[date.month] : months[date.month];
}

/// Вспомогательный метод: получить диапазон дат для месяца
(DateTime start, DateTime end) getMonthRange(DateTime monthDate) {
  final start = DateTime(monthDate.year, monthDate.month, 1);
  final end = monthDate.month == 12
      ? DateTime(monthDate.year + 1, 1, 1)
      : DateTime(monthDate.year, monthDate.month + 1, 1);
  return (start, end);
}
