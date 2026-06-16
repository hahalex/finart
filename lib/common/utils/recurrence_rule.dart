// Файл: lib/common/utils/recurrence_rule.dart.
// Назначение: содержит утилиты и общие функции, используемые в разных модулях.

class RecurrenceRule {
  const RecurrenceRule._({
    required this.kind,
    required this.interval,
    this.weekdays = const [],
    this.monthDay,
    this.yearMonth,
  });

  final RecurrenceKind kind;
  final int interval;
  final List<int> weekdays;
  final int? monthDay;
  final int? yearMonth;

  bool get isOneTime => kind == RecurrenceKind.none;

  factory RecurrenceRule.parse(String raw) {
    final value = raw.trim().toLowerCase();
    switch (value) {
      case '':
      case 'none':
        return const RecurrenceRule._(kind: RecurrenceKind.none, interval: 1);
      case 'daily':
        return const RecurrenceRule._(kind: RecurrenceKind.days, interval: 1);
      case 'weekly':
        return const RecurrenceRule._(kind: RecurrenceKind.weeks, interval: 1);
      case 'monthly':
        return const RecurrenceRule._(kind: RecurrenceKind.months, interval: 1);
      case 'yearly':
        return const RecurrenceRule._(kind: RecurrenceKind.years, interval: 1);
    }

    final parts = value.split(':');
    if (parts.length == 3 && parts[0] == 'every') {
      final interval = int.tryParse(parts[2]) ?? 1;
      return RecurrenceRule._(
        kind: _unitKind(parts[1]),
        interval: interval.clamp(1, 365).toInt(),
      );
    }

    if (parts.length == 2 && parts[0] == 'weekdays') {
      final days =
          parts[1]
              .split(',')
              .map((item) => int.tryParse(item.trim()))
              .whereType<int>()
              .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
              .toSet()
              .toList()
            ..sort();
      if (days.isNotEmpty) {
        return RecurrenceRule._(
          kind: RecurrenceKind.weekdays,
          interval: 1,
          weekdays: days,
        );
      }
    }

    if (parts.length == 2 && parts[0] == 'monthly') {
      final day = int.tryParse(parts[1])?.clamp(1, 31).toInt();
      if (day != null) {
        return RecurrenceRule._(
          kind: RecurrenceKind.monthDay,
          interval: 1,
          monthDay: day,
        );
      }
    }

    if (parts.length == 3 && parts[0] == 'yearly') {
      final month = int.tryParse(parts[1])?.clamp(1, 12).toInt();
      final day = int.tryParse(parts[2])?.clamp(1, 31).toInt();
      if (month != null && day != null) {
        return RecurrenceRule._(
          kind: RecurrenceKind.yearDate,
          interval: 1,
          yearMonth: month,
          monthDay: day,
        );
      }
    }

    return const RecurrenceRule._(kind: RecurrenceKind.none, interval: 1);
  }

  DateTime nextAfter(DateTime current) {
    if (isOneTime) return current;

    return switch (kind) {
      RecurrenceKind.days => current.add(Duration(days: interval)),
      RecurrenceKind.weeks => current.add(Duration(days: 7 * interval)),
      RecurrenceKind.months => _addMonths(current, interval),
      RecurrenceKind.years => _addMonths(current, 12 * interval),
      RecurrenceKind.weekdays => _nextWeekdayAfter(current),
      RecurrenceKind.monthDay => _nextMonthDayAfter(current),
      RecurrenceKind.yearDate => _nextYearDateAfter(current),
      RecurrenceKind.none => current,
    };
  }

  DateTime firstOccurrenceOnOrAfter(DateTime start, DateTime from) {
    if (isOneTime || !start.isBefore(from)) return start;

    var next = start;
    for (var i = 0; i < 1000 && next.isBefore(from); i++) {
      final candidate = nextAfter(next);
      if (!candidate.isAfter(next)) break;
      next = candidate;
    }
    return next;
  }

  static RecurrenceKind _unitKind(String unit) {
    return switch (unit) {
      'day' || 'days' => RecurrenceKind.days,
      'week' || 'weeks' => RecurrenceKind.weeks,
      'month' || 'months' => RecurrenceKind.months,
      'year' || 'years' => RecurrenceKind.years,
      _ => RecurrenceKind.none,
    };
  }

  DateTime _nextWeekdayAfter(DateTime current) {
    for (var offset = 1; offset <= 7; offset++) {
      final candidate = current.add(Duration(days: offset));
      if (weekdays.contains(candidate.weekday)) return candidate;
    }
    return current.add(const Duration(days: 7));
  }

  DateTime _nextMonthDayAfter(DateTime current) {
    var candidate = _safeDate(current.year, current.month, monthDay!);
    if (!candidate.isAfter(current)) {
      candidate = _safeDate(current.year, current.month + 1, monthDay!);
    }
    return candidate;
  }

  DateTime _nextYearDateAfter(DateTime current) {
    var candidate = _safeDate(current.year, yearMonth!, monthDay!);
    if (!candidate.isAfter(current)) {
      candidate = _safeDate(current.year + 1, yearMonth!, monthDay!);
    }
    return candidate;
  }

  static DateTime _addMonths(DateTime current, int months) {
    return _safeDate(current.year, current.month + months, current.day);
  }

  static DateTime _safeDate(int year, int month, int day) {
    final firstOfNextMonth = DateTime(year, month + 1);
    final lastDay = firstOfNextMonth.subtract(const Duration(days: 1)).day;
    return DateTime(year, month, day.clamp(1, lastDay).toInt());
  }
}

enum RecurrenceKind {
  none,
  days,
  weeks,
  months,
  years,
  weekdays,
  monthDay,
  yearDate,
}
