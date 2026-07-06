class AppStats {
  final int totalHabits;
  final int activeHabits;
  final int completedToday;
  final int totalCompletions;
  final int longestStreak;
  final double completionRate;

  AppStats({
    required this.totalHabits,
    required this.activeHabits,
    required this.completedToday,
    required this.totalCompletions,
    required this.longestStreak,
    required this.completionRate,
  });
}