import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class StorageService {
  static const String habitsKey = 'habits';
  static const String darkModeKey = 'dark_mode';

  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = habits.map((habit) => habit.toJson()).toList();

    await prefs.setString(habitsKey, jsonEncode(jsonList));
  }

  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(habitsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        return [];
      }

      final habits = <Habit>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        try {
          habits.add(
            Habit.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          // Skip an invalid habit instead of crashing the app.
        }
      }

      return habits;
    } on FormatException {
      // Malformed JSON: keep the app usable.
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, value);
  }

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(darkModeKey) ?? false;
  }
}