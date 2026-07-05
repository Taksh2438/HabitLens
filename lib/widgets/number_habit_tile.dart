import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/streak_service.dart';

class NumberHabitTile extends StatelessWidget {
  final Habit habit;

  const NumberHabitTile({
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
        : (todayRecords.first.value ?? 0.0);

    String currentText = current % 1 == 0
        ? current.toInt().toString()
        : current.toStringAsFixed(1);

    String targetText = habit.targetValue == null
        ? ''
        : (habit.targetValue! % 1 == 0
            ? habit.targetValue!.toInt().toString()
            : habit.targetValue!.toStringAsFixed(1));

    String display = '$currentText/$targetText';

    if (habit.unit != null && habit.unit!.isNotEmpty) {
      display += ' ${habit.unit}';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () async {
            if (current > 0) {
              await Provider.of<HabitProvider>(
                context,
                listen: false,
              ).setHabitValue(
                habit,
                (current - habit.incrementStep).clamp(
                  0,
                  double.infinity,
                ),
              );
            }
          },
        ),
        Text(
          display,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            await Provider.of<HabitProvider>(
              context,
              listen: false,
            ).setHabitValue(
              habit,
              current + habit.incrementStep,
            );
          },
        ),
      ],
    );
  }
}