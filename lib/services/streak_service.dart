import '../models/habit.dart';
import '../models/habit_record.dart';
import '../models/habit_type.dart';

class StreakService {
  static String todayKey() => _dateKey(DateTime.now());

  static String _dateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static bool _isRecordCompleted(Habit habit, HabitRecord record) {
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

    for (final record in habit.records) {
      if (record.date == today) {
        return _isRecordCompleted(habit, record);
      }
    }

    return false;
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

    final completed = switch (habit.type) {
      HabitType.checkbox => false,
      HabitType.number || HabitType.counter =>
        habit.targetValue != null &&
            habit.targetValue! > 0 &&
            value >= habit.targetValue!,
      HabitType.rating => value > 0,
    };

    if (index >= 0) {
      // Preserve the actual value, even when it exceeds the target.
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
    habit.records.sort((a, b) => a.date.compareTo(b.date));

    final completedDates = <String>{};

    for (final record in habit.records) {
      if (_isRecordCompleted(habit, record)) {
        completedDates.add(record.date);
      }
    }

    habit.totalCompletions = completedDates.length;

    final dates = completedDates.toList()..sort();

    int longest = 0;
    int run = 0;
    DateTime? previousDate;

    for (final date in dates) {
      final parsed = DateTime.tryParse(date);
      if (parsed == null) continue;

      final day = DateTime(parsed.year, parsed.month, parsed.day);

      if (previousDate != null &&
          day.difference(previousDate).inDays == 1) {
        run++;
      } else {
        run = 1;
      }

      if (run > longest) longest = run;
      previousDate = day;
    }

    habit.longestStreak = longest;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int current = 0;
    DateTime expected = completedDates.contains(_dateKey(today))
        ? today
        : yesterday;

    while (completedDates.contains(_dateKey(expected))) {
      current++;
      expected = expected.subtract(const Duration(days: 1));
    }

    habit.currentStreak = current;
  }
}