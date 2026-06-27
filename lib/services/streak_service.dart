import '../models/habit.dart';
import '../models/habit_record.dart';

class StreakService {
  static String todayKey() {
    final now = DateTime.now();

    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static bool isCompletedToday(Habit habit) {
    final today = todayKey();

    return habit.records.any(
      (record) =>
          record.date == today &&
          record.completed,
    );
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