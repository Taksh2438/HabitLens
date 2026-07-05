import '../models/habit.dart';
import 'package:flutter/material.dart';

class TimerHabitTile extends StatelessWidget {
  final Habit habit;

  const TimerHabitTile({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow),
        ),

        const Text(
          "00:00",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.stop),
        ),
      ],
    );
  }
}