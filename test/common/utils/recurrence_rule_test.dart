import 'package:finart_app/common/utils/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecurrenceRule', () {
    test('calculates fixed daily and weekly intervals', () {
      final start = DateTime(2026, 1, 1);

      expect(
        RecurrenceRule.parse('daily').nextAfter(start),
        DateTime(2026, 1, 2),
      );
      expect(
        RecurrenceRule.parse('every:weeks:2').nextAfter(start),
        DateTime(2026, 1, 15),
      );
    });

    test('clamps monthly recurrence to the last valid day', () {
      final start = DateTime(2026, 1, 31);

      expect(
        RecurrenceRule.parse('monthly').nextAfter(start),
        DateTime(2026, 2, 28),
      );
    });

    test('finds the next configured weekday', () {
      final monday = DateTime(2026, 5, 25);

      expect(
        RecurrenceRule.parse('weekdays:3,5').nextAfter(monday),
        DateTime(2026, 5, 27),
      );
    });

    test('returns the first occurrence on or after a date', () {
      final rule = RecurrenceRule.parse('every:weeks:2');

      expect(
        rule.firstOccurrenceOnOrAfter(
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 20),
        ),
        DateTime(2026, 1, 29),
      );
    });

    test('supports yearly dates', () {
      final rule = RecurrenceRule.parse('yearly:12:31');

      expect(rule.nextAfter(DateTime(2026, 12, 31)), DateTime(2027, 12, 31));
    });
  });
}
