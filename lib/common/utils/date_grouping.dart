/// Группирует элементы по дате с красивыми русскими заголовками
///
/// Формат:
/// - "Сегодня (22.03.25)"
/// - "Вчера (21.03.25)"
/// - "20.03.25", "19.03.25" для остальных
Map<String, List<T>> groupItemsByDate<T>({
  required List<T> items,
  required DateTime Function(T item) dateExtractor,
}) {
  if (items.isEmpty) return {};

  final groups = <String, List<T>>{};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  for (final item in items) {
    final itemDate = dateExtractor(item);
    final itemDay = DateTime(itemDate.year, itemDate.month, itemDate.day);

    // Формируем заголовок
    final String dateLabel;
    if (itemDay == today) {
      // Сегодня (22.03.25)
      dateLabel = 'Сегодня (${_formatDateShort(itemDate)})';
    } else if (itemDay == yesterday) {
      // Вчера (21.03.25)
      dateLabel = 'Вчера (${_formatDateShort(itemDate)})';
    } else {
      // 20.03.25
      dateLabel = _formatDateShort(itemDate);
    }

    groups.putIfAbsent(dateLabel, () => []).add(item);
  }

  // Сортируем: Сегодня → Вчера → по убыванию даты
  final sortedEntries = groups.entries.toList()
    ..sort((a, b) {
      if (a.key.startsWith('Сегодня')) return -1;
      if (b.key.startsWith('Сегодня')) return 1;
      if (a.key.startsWith('Вчера')) return -1;
      if (b.key.startsWith('Вчера')) return 1;

      // Для остальных: парсим дату из строки "20.03.25"
      final dateA = _parseShortDate(a.key);
      final dateB = _parseShortDate(b.key);

      if (dateA == null || dateB == null) return b.key.compareTo(a.key);
      return dateB.compareTo(dateA);
    });

  return Map.fromEntries(sortedEntries);
}

/// Форматирует дату как "22.03.25"
String _formatDateShort(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString().substring(2); // "2025" → "25"
  return '$day.$month.$year';
}

/// Парсит дату из строки "22.03.25" обратно в DateTime
DateTime? _parseShortDate(String label) {
  // Убираем "Сегодня (" и "Вчера (" если есть
  final clean = label
      .replaceAll(RegExp(r'^(Сегодня|Вчера)\s*\('), '')
      .replaceAll(')', '');

  try {
    final parts = clean.split('.');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final yearShort = int.tryParse(parts[2]) ?? 0;
    // Восстанавливаем полный год: "25" → 2025
    final year = yearShort < 50 ? 2000 + yearShort : 1900 + yearShort;

    return DateTime(year, month, day);
  } catch (_) {
    return null;
  }
}
