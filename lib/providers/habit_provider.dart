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
    final cleanedName = name.trim();
    if (cleanedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Habit name cannot be empty.');
    }
    if (targetValue != null &&
        (!targetValue.isFinite || targetValue <= 0)) {
      throw ArgumentError.value(
        targetValue,
        'targetValue',
        'Goal must be greater than zero.',
      );
    }
    if (!incrementStep.isFinite || incrementStep <= 0) {
      throw ArgumentError.value(
        incrementStep,
        'incrementStep',
        'Increment step must be greater than zero.',
      );
    }

    final now = DateTime.now();
    var id = now.microsecondsSinceEpoch.toString();
    while (_habits.any((habit) => habit.id == id)) {
      id = '${now.microsecondsSinceEpoch}-${_habits.length}-${id.hashCode}';
    }

    _habits.add(
      Habit(
        id: id,
        name: cleanedName,
        icon: icon,
        type: type,
        targetValue: targetValue,
        createdDate: now,
        hasGoal: hasGoal && targetValue != null,
        unit: unit?.trim().isEmpty == true ? null : unit?.trim(),
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
    final matches = _habits.where((habit) => habit.id == id);
    if (matches.isEmpty) return;

    final cleanedName = name.trim();
    if (cleanedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Habit name cannot be empty.');
    }
    if (targetValue != null &&
        (!targetValue.isFinite || targetValue <= 0)) {
      throw ArgumentError.value(
        targetValue,
        'targetValue',
        'Goal must be greater than zero.',
      );
    }
    if (incrementStep != null &&
        (!incrementStep.isFinite || incrementStep <= 0)) {
      throw ArgumentError.value(
        incrementStep,
        'incrementStep',
        'Increment step must be greater than zero.',
      );
    }

    final habit = matches.first;
    habit.name = cleanedName;
    habit.icon = icon;
    habit.targetValue = targetValue;
    habit.hasGoal = targetValue != null;
    habit.unit = unit?.trim().isEmpty == true ? null : unit?.trim();

    if (incrementStep != null) {
      habit.incrementStep = incrementStep;
    }

    StreakService.recalculate(habit);
    await saveHabits();
    notifyListeners();
  }

  Future<void> deleteHabits(List<String> ids) async {
    _habits.removeWhere((habit) => ids.contains(habit.id));
    await saveHabits();
    notifyListeners();
  }

  Future<void> toggleHabit(Habit habit) async {
    if (!_habits.any((item) => item.id == habit.id)) return;

    StreakService.toggleToday(habit);
    await saveHabits();
    notifyListeners();
  }

  Future<void> setHabitValue(Habit habit, double value) async {
    if (!value.isFinite) {
      throw ArgumentError.value(value, 'value', 'Value must be finite.');
    }
    if (!_habits.any((item) => item.id == habit.id)) return;

    StreakService.setTodayValue(habit, value);
    await saveHabits();
    notifyListeners();
  }

  Future<void> incrementCounter(Habit habit) async {
    final today = StreakService.todayKey();
    final records = habit.records.where((record) => record.date == today);
    final current = records.isEmpty ? 0.0 : (records.last.value ?? 0.0);

    await setHabitValue(habit, current + habit.incrementStep);
  }

  Future<void> decrementCounter(Habit habit) async {
    final today = StreakService.todayKey();
    final records = habit.records.where((record) => record.date == today);
    final current = records.isEmpty ? 0.0 : (records.last.value ?? 0.0);
    final next = (current - habit.incrementStep).clamp(0.0, double.infinity);

    await setHabitValue(habit, next);
  }
}