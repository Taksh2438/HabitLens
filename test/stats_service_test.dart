import 'package:flutter_test/flutter_test.dart';
import 'package:habit_lens/models/habit.dart';
import 'package:habit_lens/models/habit_record.dart';
import 'package:habit_lens/models/habit_type.dart';
import 'package:habit_lens/services/stats_service.dart';

void main() {
  final today = DateTime.now();
  final todayKey =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  test('statistics include all four habit types', () {
    final habits = [
      Habit(
        id: 'checkbox',
        name: 'Exercise',
        type: HabitType.checkbox,
        createdDate: today,
        records: [
          HabitRecord(date: todayKey, completed: true),
        ],
      ),
      Habit(
        id: 'number',
        name: 'Read',
        type: HabitType.number,
        targetValue: 5,
        createdDate: today,
        records: [
          HabitRecord(date: todayKey, completed: false, value: 8),
        ],
      ),
      Habit(
        id: 'counter',
        name: 'Push-ups',
        type: HabitType.counter,
        targetValue: 5,
        createdDate: today,
        records: [
          HabitRecord(date: todayKey, completed: false, value: 8),
        ],
      ),
      Habit(
        id: 'rating',
        name: 'Daily mood',
        type: HabitType.rating,
        createdDate: today,
        records: [
          HabitRecord(date: todayKey, completed: false, value: 4),
        ],
      ),
    ];

    final stats = StatsService.calculate(habits);

    expect(stats.activeHabits, 4);
    expect(stats.completedToday, 4);
    expect(stats.totalCompletions, 4);
    expect(stats.completionRate, 100);
    expect(stats.longestStreak, 1);
    expect(StatsService.last7Days(habits).last, 4);

    // Test counter and rating separately because topHabits returns only 3.
    final topHabits = StatsService.topHabits([
      habits[2],
      habits[3],
    ]);

    expect(
      topHabits.map((habit) => habit.id),
      containsAll(['counter', 'rating']),
    );
  });

  test('number and counter goals below target are not completed', () {
    final habits = [
      Habit(
        id: 'number',
        name: 'Read',
        type: HabitType.number,
        targetValue: 10,
        createdDate: today,
        records: [
          HabitRecord(date: todayKey, completed: false, value: 5),
        ],
      ),
      Habit(
        id: 'counter',
        name: 'Push-ups',
        type: HabitType.counter,
        targetValue: 10,
        createdDate: today,
        records: [
          HabitRecord(date: todayKey, completed: false, value: 7),
        ],
      ),
    ];

    final stats = StatsService.calculate(habits);

    expect(stats.activeHabits, 2);
    expect(stats.completedToday, 0);
    expect(stats.totalCompletions, 0);
    expect(StatsService.last7Days(habits).last, 0);
  });

  test('archived habits are excluded from statistics', () {
    final habits = [
      Habit(
        id: 'archived',
        name: 'Old habit',
        isArchived: true,
        createdDate: today,
        records: [
          HabitRecord(date: todayKey, completed: true),
        ],
      ),
    ];

    final stats = StatsService.calculate(habits);

    expect(stats.activeHabits, 0);
    expect(stats.completedToday, 0);
    expect(stats.totalCompletions, 0);
    expect(StatsService.last7Days(habits).last, 0);
  });
}