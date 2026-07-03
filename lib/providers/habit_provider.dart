import '../models/habit.dart';
import '../models/habit_type.dart';
import 'package:flutter/material.dart';
import '../services/streak_service.dart';
import '../services/storage_service.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  Future<void> loadHabits() async {
    _habits = await StorageService.loadHabits();
    notifyListeners();
  }

  Future<void> saveHabits() async {
    await StorageService.saveHabits(_habits);
  }

  Future<void> addHabit(
    String name,
    HabitType type,
    double? targetValue,
    bool hasGoal,
  ) async {
    _habits.add(
      Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: type,
        targetValue: targetValue,
        createdDate: DateTime.now(),
        hasGoal: hasGoal,
      ),
    );

    await saveHabits();
    notifyListeners();
  }

  Future<void> editHabit(String id, String newName) async {
    final habit = _habits.firstWhere((h) => h.id == id);

    habit.name = newName;

    await saveHabits();
    notifyListeners();
  }

  Future<void> deleteHabits(List<String> ids) async {
    _habits.removeWhere(
      (habit) => ids.contains(habit.id),
    );

    await saveHabits();
    notifyListeners();
  }

  Future<void> toggleHabit(Habit habit) async {
    StreakService.toggleToday(habit);

    await saveHabits();
    notifyListeners();
  }

  Future<void> setHabitValue(
    Habit habit,
    double value,
  ) async {
    StreakService.setTodayValue(
      habit,
      value,
    );

    await saveHabits();
    notifyListeners();
  }

  Future<void> incrementCounter(Habit habit) async {
    final today = StreakService.todayKey();

    final record = habit.records.where(
      (r) => r.date == today,
    );

    final current = record.isEmpty
        ? 0.0
        : (record.first.value ?? 0);

    await setHabitValue(
      habit,
      current + 1,
    );
  }

  Future<void> decrementCounter(Habit habit) async {
    final today = StreakService.todayKey();

    final record = habit.records.where(
      (r) => r.date == today,
    );

    final current = record.isEmpty
        ? 0.0
        : (record.first.value ?? 0);

    if (current > 0) {
      await setHabitValue(
        habit,
        current - 1,
      );
    }
  }
}