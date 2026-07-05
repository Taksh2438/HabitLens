import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/streak_service.dart';

class CounterHabitTile extends StatelessWidget {
  final Habit habit;

  const CounterHabitTile({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final todayRecords = habit.records.where(
      (r) => r.date == StreakService.todayKey(),
    );

    final current = todayRecords.isEmpty
        ? 0.0
        : (todayRecords.first.value ?? 0);

    String displayValue = current % 1 == 0
        ? current.toInt().toString()
        : current.toStringAsFixed(1);

    if (habit.unit != null && habit.unit!.isNotEmpty) {
      displayValue = '$displayValue ${habit.unit}';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () async {
            await Provider.of<HabitProvider>(
              context,
              listen: false,
            ).decrementCounter(habit);
          },
        ),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () async {
            await Provider.of<HabitProvider>(
              context,
              listen: false,
            ).incrementCounter(habit);
          },
        ),
      ],
    );
  }
}