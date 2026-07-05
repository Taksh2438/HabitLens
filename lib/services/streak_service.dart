import '../models/habit.dart';
import '../models/habit_type.dart';
import '../models/habit_record.dart';

class StreakService {
  static String todayKey() {
    final now = DateTime.now();

    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static bool isCompletedToday(Habit habit) {
    final today = todayKey();

    final todayRecord = habit.records.where(
      (record) => record.date == today,
    );

    if (todayRecord.isEmpty) {
      return false;
    }

    final record = todayRecord.first;

    if (habit.type == HabitType.checkbox) {
      return record.completed;
    }

    switch (habit.type) {
      case HabitType.checkbox:
        return record.completed;

      case HabitType.number:
        return (record.value ?? 0) >=
            (habit.targetValue ?? 0);

      case HabitType.counter:
        return false;

      case HabitType.rating:
        return (record.value ?? 0) > 0;
    }
  }

  static void toggleToday(Habit habit) {
    final today = todayKey();

    final index = habit.records.indexWhere(
      (record) => record.date == today,
    );

    if (index >= 0) {
      habit.records[index].completed =
          !habit.records[index].completed;
    } else {
      habit.records.add(
        HabitRecord(
          date: today,
          completed: true,
        ),
      );
    }

    recalculate(habit);
  }

  static void setTodayValue(
    Habit habit,
    double value,
  ) {
    final today = todayKey();

    final bool completed;

    switch (habit.type) {
      case HabitType.checkbox:
        completed = false;
        break;

      case HabitType.number:
        completed =
            value >= (habit.targetValue ?? 0);
        break;

      case HabitType.counter:
      case HabitType.rating:
        completed = false;
        break;
    }

    final index = habit.records.indexWhere(
      (record) => record.date == today,
    );

    if (index >= 0) {
      habit.records[index].value = value;
      habit.records[index].completed = completed;
    } else {
      habit.records.add(
        HabitRecord(
          date: today,
          completed: completed,
          value: value,
        ),
      );
    }

    recalculate(habit);
  }

  static void recalculate(Habit habit) {
    habit.records.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    int current = 0;
    int longest = 0;
    int total = 0;

    for (final record in habit.records) {
      if (record.completed) {
        current++;
        total++;

        if (current > longest) {
          longest = current;
        }
      } else {
        current = 0;
      }
    }

    habit.currentStreak = current;
    habit.longestStreak = longest;
    habit.totalCompletions = total;
  }
}