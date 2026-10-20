import '../models/habit.dart';
import '../models/habit_record.dart';
import '../models/habit_type.dart';

class StreakService {
  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String todayKey() => _dateKey(DateTime.now());

  static bool isRecordCompleted(Habit habit, HabitRecord record) {
    switch (habit.type) {
      case HabitType.checkbox:
        return record.completed;

      case HabitType.number:
      case HabitType.counter:
        final target = habit.targetValue;
        return target != null &&
            target > 0 &&
            (record.value ?? 0) >= target;

      case HabitType.rating:
        return (record.value ?? 0) > 0;
    }
  }

  static bool isCompletedToday(Habit habit) {
    final today = todayKey();
    final index = habit.records.lastIndexWhere(
      (record) => record.date == today,
    );

    return index >= 0 &&
        isRecordCompleted(habit, habit.records[index]);
  }

  static void toggleToday(Habit habit) {
    if (habit.type != HabitType.checkbox) return;

    final today = todayKey();
    final index = habit.records.indexWhere(
      (record) => record.date == today,
    );

    if (index >= 0) {
      habit.records[index].completed =
          !habit.records[index].completed;
    } else {
      habit.records.add(
        HabitRecord(date: today, completed: true),
      );
    }

    recalculate(habit);
  }

  static void setTodayValue(Habit habit, double value) {
    final today = todayKey();
    final index = habit.records.indexWhere(
      (record) => record.date == today,
    );

    if (index >= 0) {
      habit.records[index].value = value;
      habit.records[index].completed = false;
    } else {
      habit.records.add(
        HabitRecord(
          date: today,
          completed: false,
          value: value,
        ),
      );
    }

    recalculate(habit);
  }

  static void recalculate(Habit habit) {
    final completedDates = <String>{};

    for (final record in habit.records) {
      if (isRecordCompleted(habit, record) &&
          DateTime.tryParse(record.date) != null) {
        completedDates.add(record.date);
      }
    }

    habit.totalCompletions = completedDates.length;

    final dates = completedDates.toList()..sort();
    var longest = 0;
    var run = 0;
    DateTime? previous;

    for (final key in dates) {
      final date = DateTime.tryParse(key);
      if (date == null) continue;

      if (previous != null &&
          date.difference(previous).inDays == 1) {
        run++;
      } else {
        run = 1;
      }

      if (run > longest) longest = run;
      previous = date;
    }

    habit.longestStreak = longest;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday =
        _dateKey(todayDate.subtract(const Duration(days: 1)));

    var cursor = completedDates.contains(todayKey())
        ? todayDate
        : DateTime.tryParse(yesterday);

    var current = 0;

    while (cursor != null &&
        completedDates.contains(_dateKey(cursor))) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    habit.currentStreak = current;
  }
}