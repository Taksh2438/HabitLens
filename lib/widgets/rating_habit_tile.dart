import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/streak_service.dart';

class RatingHabitTile extends StatelessWidget {
  final Habit habit;

  const RatingHabitTile({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final todayRecords = habit.records.where(
      (r) => r.date == StreakService.todayKey(),
    );

    final current = todayRecords.isEmpty
        ? 0
        : (todayRecords.first.value ?? 0).toInt();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => IconButton(
          constraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 2,
          ),
          splashRadius: 18,
          icon: Icon(
            index < current
                ? Icons.star
                : Icons.star_border,
            size: 22,
          ),
          onPressed: () async {
            await Provider.of<HabitProvider>(
              context,
              listen: false,
            ).setHabitValue(
              habit,
              (index + 1).toDouble(),
            );
          },
        ),
      ),
    );
  }
}