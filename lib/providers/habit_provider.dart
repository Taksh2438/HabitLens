import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/habit_type.dart';
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
    String icon,
    HabitType type,
    double? targetValue,
    bool hasGoal,
    String? unit,
    double incrementStep,
  ) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    var idValue = DateTime.now().microsecondsSinceEpoch;

    while (_habits.any((habit) => habit.id == idValue.toString())) {
      idValue++;
    }

    final now = DateTime.now();

    _habits.add(
      Habit(
        id: idValue.toString(),
        name: cleanName,
        icon: icon,
        type: type,
        targetValue: targetValue,
        createdDate: now,
        hasGoal: hasGoal,
        unit: unit,
        incrementStep: incrementStep,
      ),
    );

    await saveHabits();
    notifyListeners();
  }

  Future<void> editHabit({
    required String id,
    required String name,
    required String icon,
    double? targetValue,
    String? unit,
    double? incrementStep,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;

    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index == -1) return;

    final habit = _habits[index];

    habit.name = cleanName;
    habit.icon = icon;
    habit.targetValue = targetValue;
    habit.unit = unit;

    if (incrementStep != null && incrementStep > 0) {
      habit.incrementStep = incrementStep;
    }

    await saveHabits();
    notifyListeners();
  }

  Future<void> deleteHabits(List<String> ids) async {
    _habits.removeWhere((habit) => ids.contains(habit.id));

    await saveHabits();
    notifyListeners();
  }

  Future<void> toggleHabit(Habit habit) async {
    StreakService.toggleToday(habit);

    await saveHabits();
    notifyListeners();
  }

  Future<void> setHabitValue(Habit habit, double value) async {
    StreakService.setTodayValue(habit, value);

    await saveHabits();
    notifyListeners();
  }

  Future<void> incrementCounter(Habit habit) async {
    final today = StreakService.todayKey();

    final records = habit.records.where(
      (record) => record.date == today,
    );

    final current = records.isEmpty
        ? 0.0
        : (records.first.value ?? 0.0);

    await setHabitValue(
      habit,
      current + habit.incrementStep,
    );
  }

  Future<void> decrementCounter(Habit habit) async {
    final today = StreakService.todayKey();

    final records = habit.records.where(
      (record) => record.date == today,
    );

    final current = records.isEmpty
        ? 0.0
        : (records.first.value ?? 0.0);

    final newValue = (current - habit.incrementStep)
        .clamp(0.0, double.infinity)
        .toDouble();

    await setHabitValue(habit, newValue);
  }
}