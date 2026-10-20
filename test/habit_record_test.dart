import 'package:flutter_test/flutter_test.dart';
import 'package:habit_lens/models/habit_record.dart';

void main() {
  group('HabitRecord', () {
    test('round-trips a valid record', () {
      final original = HabitRecord(
        date: '2026-10-20',
        completed: true,
        value: 8,
      );

      final restored = HabitRecord.fromJson(original.toJson());

      expect(restored.date, '2026-10-20');
      expect(restored.completed, isTrue);
      expect(restored.value, 8);
    });

    test('handles missing or invalid fields safely', () {
      final record = HabitRecord.fromJson({
        'date': null,
        'completed': 'true',
        'value': 'not-a-number',
      });

      expect(record.date, '');
      expect(record.completed, isFalse);
      expect(record.value, isNull);
    });

    test('rejects non-finite numeric values', () {
      final record = HabitRecord.fromJson({
        'date': '2026-10-20',
        'completed': true,
        'value': double.infinity,
      });

      expect(record.value, isNull);
    });
  });
}