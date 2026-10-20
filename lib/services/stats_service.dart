import '../models/app_stats.dart';
import '../models/habit.dart';
import '../services/streak_service.dart';

class StatsService {
  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static Set<String> _completedDates(Habit habit) {
    final dates = <String>{};

    for (final record in habit.records) {
      final parsed = DateTime.tryParse(record.date);
      if (parsed == null) continue;

      if (StatsService._dateKey(parsed) != record.date) continue;

      if (StreakService.isRecordCompleted(habit, record)) {
        dates.add(record.date);
      }
    }

    return dates;
  }

  static int _longestStreak(Set<String> dates) {
    final sorted = dates.toList()..sort();
    var longest = 0;
    var current = 0;
    DateTime? previous;

    for (final key in sorted) {
      final date = DateTime.tryParse(key);
      if (date == null) continue;

      if (previous != null &&
          date.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }

      if (current > longest) longest = current;
      previous = date;
    }

    return longest;
  }

  static AppStats calculate(List<Habit> habits) {
    final activeHabits =
        habits.where((habit) => !habit.isArchived).toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = _dateKey(today);

    var completedToday = 0;
    var totalCompletions = 0;
    var totalPossible = 0;
    var longest = 0;

    for (final habit in activeHabits) {
      final completedDates = _completedDates(habit);

      if (completedDates.contains(todayKey)) {
        completedToday++;
      }

      final created = habit.createdDate;
      final createdDay = DateTime(created.year, created.month, created.day);
      final daysSinceCreated = today.difference(createdDay).inDays + 1;
      final possibleDays = daysSinceCreated > 0 ? daysSinceCreated : 0;

      totalPossible += possibleDays;

      for (final key in completedDates) {
        final date = DateTime.tryParse(key);
        if (date == null) continue;

        final day = DateTime(date.year, date.month, date.day);

        if (!day.isBefore(createdDay) && !day.isAfter(today)) {
          totalCompletions++;
        }
      }

      final streak = _longestStreak(completedDates);
      if (streak > longest) longest = streak;
    }

    final rate = totalPossible == 0
        ? 0.0
        : (totalCompletions / totalPossible * 100).clamp(0.0, 100.0);

    return AppStats(
      totalHabits: habits.length,
      activeHabits: activeHabits.length,
      completedToday: completedToday,
      totalCompletions: totalCompletions,
      longestStreak: longest,
      completionRate: rate.toDouble(),
    );
  }

  static List<int> last7Days(List<Habit> habits) {
    final counts = List<int>.filled(7, 0);
    final today = DateTime.now();
    final dates = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - i)),
    );

    final dateIndexes = <String, int>{
      for (var i = 0; i < dates.length; i++) _dateKey(dates[i]): i,
    };

    for (final habit in habits) {
      if (habit.isArchived) continue;

      for (final date in _completedDates(habit)) {
        final index = dateIndexes[date];
        if (index != null) counts[index]++;
      }
    }

    return counts;
  }

  static List<Habit> topHabits(List<Habit> habits) {
    final sorted = habits
        .where((habit) => !habit.isArchived)
        .toList();

    sorted.sort(
      (a, b) => _completedDates(b).length.compareTo(
        _completedDates(a).length,
      ),
    );

    return sorted.take(3).toList();
  }

  static Habit? mostConsistentHabit(List<Habit> habits) {
    final eligible = habits
        .where((habit) => !habit.isArchived)
        .toList();

    if (eligible.isEmpty) return null;

    eligible.sort(
      (a, b) => _completedDates(b).length.compareTo(
        _completedDates(a).length,
      ),
    );

    return eligible.first;
  }
}