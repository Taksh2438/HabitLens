import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../services/storage_service.dart';
import '../services/streak_service.dart';

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

  Future<void> addHabit(String name) async {
    _habits.add(
      Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdDate: DateTime.now(),
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
}