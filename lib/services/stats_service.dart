import 'dart:collection';
import '../models/app_stats.dart';
import '../models/habit.dart';
import '../models/habit_type.dart';
import 'streak_service.dart';

class StatsService {
  static AppStats calculate(List<Habit> habits) {
    if (habits.isEmpty) {
      return AppStats(
        totalHabits: 0,
        activeHabits: 0,
        completedToday: 0,
        totalCompletions: 0,
        longestStreak: 0,
        completionRate: 0.0,
      );
    }

    int completions = 0;
    int longest = 0;
    int activeHabits = 0;
    int completedToday = 0;
    int totalPossible = 0;

    final today = DateTime.now();

    for (final habit in habits) {
      if (habit.isArchived) {
        continue;
      }

      if (habit.type != HabitType.counter &&
          habit.type != HabitType.rating) {
        activeHabits++;

        final daysSinceCreated =
            today.difference(habit.createdDate).inDays + 1;

        totalPossible += daysSinceCreated;

        completions += habit.totalCompletions;

        if (StreakService.isCompletedToday(habit)) {
          completedToday++;
        }

        if (habit.longestStreak > longest) {
          longest = habit.longestStreak;
        }
      }
    }

    final double rate = totalPossible == 0
        ? 0.0
        : (completions / totalPossible) * 100.0;

    return AppStats(
      totalHabits: habits.length,
      activeHabits: activeHabits,
      completedToday: completedToday,
      totalCompletions: completions,
      longestStreak: longest,
      completionRate: rate,
    );
  }

  static List<int> last7Days(List<Habit> habits) {
    final counts = List<int>.filled(7, 0);

    final today = DateTime.now();

    final dates = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    final map = HashMap<String, int>();

    for (int i = 0; i < dates.length; i++) {
      final d = dates[i];

      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      map[key] = i;
    }

    for (final habit in habits) {
      if (habit.isArchived ||
          habit.type == HabitType.counter ||
          habit.type == HabitType.rating) {
        continue;
      }

      for (final record in habit.records) {
        if (record.completed && map.containsKey(record.date)) {
          counts[map[record.date]!] += 1;
        }
      }
    }

    return counts;
  }

  static List<Habit> topHabits(List<Habit> habits) {
    final sorted = habits
        .where(
          (habit) =>
              !habit.isArchived &&
              habit.type != HabitType.counter &&
              habit.type != HabitType.rating,
        )
        .toList();

    sorted.sort(
      (a, b) =>
          b.totalCompletions.compareTo(a.totalCompletions),
    );

    return sorted.take(3).toList();
  }

  static Habit? mostConsistentHabit(List<Habit> habits) {
    final eligible = habits
        .where(
          (habit) =>
              !habit.isArchived &&
              habit.type != HabitType.counter &&
              habit.type != HabitType.rating,
        )
        .toList();

    if (eligible.isEmpty) {
      return null;
    }

    eligible.sort(
      (a, b) =>
          b.totalCompletions.compareTo(a.totalCompletions),
    );

    return eligible.first;
  }
}