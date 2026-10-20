import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_lens/models/habit.dart';
import 'package:habit_lens/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns an empty list when no habits are saved', () async {
    expect(await StorageService.loadHabits(), isEmpty);
  });

  test('loads valid saved habits', () async {
    final habit = Habit(
      id: 'test-1',
      name: 'Read',
      createdDate: DateTime(2026, 10, 20),
    );

    await StorageService.saveHabits([habit]);
    final loaded = await StorageService.loadHabits();

    expect(loaded, hasLength(1));
    expect(loaded.first.id, 'test-1');
    expect(loaded.first.name, 'Read');
  });

  test('handles corrupted saved JSON safely', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageService.habitsKey, '{invalid json');

    expect(await StorageService.loadHabits(), isEmpty);
  });

  
  test('loads entries with recoverable invalid fields safely', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageService.habitsKey,
      jsonEncode([
        {'id': 'bad', 'records': 'invalid'},
        {
          'id': 'good',
          'name': 'Exercise',
          'createdDate': '2026-10-20T00:00:00.000',
          'records': [],
        },
      ]),
    );

    final loaded = await StorageService.loadHabits();

    expect(loaded, hasLength(2));
    expect(loaded[0].name, 'Untitled habit');
    expect(loaded[1].name, 'Exercise');
  });
}