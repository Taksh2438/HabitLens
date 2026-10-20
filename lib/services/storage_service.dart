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

    if (jsonString == null || jsonString.trim().isEmpty) {
      return [];
    }

    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! List) return [];

      final habits = <Habit>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        try {
          habits.add(
            Habit.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (_) {
          // Skip this habit if its saved data is invalid.
        }
      }

      return habits;
    } catch (_) {
      // Keep the app usable if the saved JSON is corrupted.
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