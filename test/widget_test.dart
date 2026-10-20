import 'package:flutter_test/flutter_test.dart';
import 'package:habit_lens/models/habit.dart';
import 'package:habit_lens/models/habit_record.dart';
import 'package:habit_lens/models/habit_type.dart';
import 'package:habit_lens/services/streak_service.dart';

String dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

Habit makeHabit({
  HabitType type = HabitType.checkbox,
  double? targetValue,
  List<HabitRecord>? records,
}) {
  return Habit(
    id: 'test-habit',
    name: 'Test habit',
    type: type,
    targetValue: targetValue,
    createdDate: DateTime.now(),
    records: records,
  );
}

void main() {
  test('counter records the actual value above its goal', () {
    final habit = makeHabit(
      type: HabitType.counter,
      targetValue: 5,
    );

    StreakService.setTodayValue(habit, 8);

    expect(habit.records.single.value, 8);
    expect(StreakService.isCompletedToday(habit), isTrue);
    expect(habit.totalCompletions, 1);
  });

  test('counter without a goal is not counted as completed', () {
    final habit = makeHabit(type: HabitType.counter);

    StreakService.setTodayValue(habit, 8);

    expect(habit.records.single.value, 8);
    expect(StreakService.isCompletedToday(habit), isFalse);
    expect(habit.totalCompletions, 0);
  });

  test('current streak counts consecutive calendar days', () {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final habit = makeHabit(
      records: [
        HabitRecord(date: dateKey(yesterday), completed: true),
        HabitRecord(date: dateKey(today), completed: true),
      ],
    );

    StreakService.recalculate(habit);

    expect(habit.currentStreak, 2);
    expect(habit.longestStreak, 2);
    expect(habit.totalCompletions, 2);
  });

  test('a missing day breaks the streak', () {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final threeDaysAgo = today.subtract(const Duration(days: 3));

    final habit = makeHabit(
      records: [
        HabitRecord(date: dateKey(threeDaysAgo), completed: true),
        HabitRecord(date: dateKey(yesterday), completed: true),
        HabitRecord(date: dateKey(today), completed: true),
      ],
    );

    StreakService.recalculate(habit);

    expect(habit.currentStreak, 2);
    expect(habit.longestStreak, 2);
    expect(habit.totalCompletions, 3);
  });
}