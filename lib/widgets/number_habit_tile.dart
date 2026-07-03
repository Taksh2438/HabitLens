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
                current - 1,
              );
            }
          },
        ),

        Text(
          '${current.toInt()}/${habit.targetValue?.toInt() ?? 0}',
        ),

        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            await Provider.of<HabitProvider>(
              context,
              listen: false,
            ).setHabitValue(
              habit,
              current + 1,
            );
          },
        ),
      ],
    );
  }
}