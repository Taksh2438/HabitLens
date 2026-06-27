import '../models/app_stats.dart';
import '../models/habit.dart';

class StatsService {
  static AppStats calculate(List<Habit> habits) {
    if (habits.isEmpty) {
      return AppStats(
        totalHabits: 0,
        totalCompletions: 0,
        longestStreak: 0,
        completionRate: 0.0,
      );
    }

    int completions = 0;
    int longest = 0;
    int totalRecords = 0;

    for (final habit in habits) {
      completions += habit.totalCompletions;

      if (habit.longestStreak > longest) {
        longest = habit.longestStreak;
      }

      totalRecords += habit.records.length;
    }

    final double rate = totalRecords == 0
        ? 0.0
        : (completions / totalRecords) * 100.0;

    return AppStats(
      totalHabits: habits.length,
      totalCompletions: completions,
      longestStreak: longest,
      completionRate: rate,
    );
  }
}