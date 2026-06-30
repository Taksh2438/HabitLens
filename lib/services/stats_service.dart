import 'dart:collection';
import '../models/habit.dart';
import '../models/app_stats.dart';

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
      for (final record in habit.records) {
        if (record.completed && map.containsKey(record.date)) {
          counts[map[record.date]!] += 1;
        }
      }
    }

    return counts;
  }
}