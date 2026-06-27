import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class StorageService {
  static const String habitsKey = 'habits';
  static const String darkModeKey = 'dark_mode';

  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = habits
        .map((habit) => habit.toJson())
        .toList();

    await prefs.setString(
      habitsKey,
      jsonEncode(jsonList),
    );
  }

  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(habitsKey);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> data =
        jsonDecode(jsonString);

    return data
        .map((e) => Habit.fromJson(e))
        .toList();
  }

  static Future<void> saveDarkMode(
      bool value) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      darkModeKey,
      value,
    );
  }

  static Future<bool> loadDarkMode() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(darkModeKey) ?? false;
  }
}