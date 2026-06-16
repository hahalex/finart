// Файл: lib/common/utils/date_grouping.dart.
// Назначение: содержит утилиты и общие функции, используемые в разных модулях.

Map<String, List<T>> groupItemsByDate<T>({
  required List<T> items,
  required DateTime Function(T item) dateExtractor,
  String languageCode = 'ru',
}) {
  if (items.isEmpty) return {};

  final isRu = languageCode.toLowerCase().startsWith('ru');
  final todayLabel = isRu ? 'Сегодня' : 'Today';
  final yesterdayLabel = isRu ? 'Вчера' : 'Yesterday';

  final groups = <String, List<T>>{};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  for (final item in items) {
    final itemDate = dateExtractor(item);
    final itemDay = DateTime(itemDate.year, itemDate.month, itemDate.day);

    final String dateLabel;
    if (itemDay == today) {
      dateLabel = '$todayLabel (${_formatDateShort(itemDate)})';
    } else if (itemDay == yesterday) {
      dateLabel = '$yesterdayLabel (${_formatDateShort(itemDate)})';
    } else {
      dateLabel = _formatDateShort(itemDate);
    }

    groups.putIfAbsent(dateLabel, () => []).add(item);
  }

  final sortedEntries = groups.entries.toList()
    ..sort((a, b) {
      if (a.key.startsWith(todayLabel)) return -1;
      if (b.key.startsWith(todayLabel)) return 1;
      if (a.key.startsWith(yesterdayLabel)) return -1;
      if (b.key.startsWith(yesterdayLabel)) return 1;

      final dateA = _parseShortDate(a.key, todayLabel, yesterdayLabel);
      final dateB = _parseShortDate(b.key, todayLabel, yesterdayLabel);

      if (dateA == null || dateB == null) return b.key.compareTo(a.key);
      return dateB.compareTo(dateA);
    });

  return Map.fromEntries(sortedEntries);
}

String _formatDateShort(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString().substring(2);
  return '$day.$month.$year';
}

DateTime? _parseShortDate(
  String label,
  String todayLabel,
  String yesterdayLabel,
) {
  final clean = label
      .replaceAll(RegExp('^($todayLabel|$yesterdayLabel)\\s*\\('), '')
      .replaceAll(')', '');

  try {
    final parts = clean.split('.');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final yearShort = int.tryParse(parts[2]) ?? 0;
    final year = yearShort < 50 ? 2000 + yearShort : 1900 + yearShort;

    return DateTime(year, month, day);
  } catch (_) {
    return null;
  }
}
