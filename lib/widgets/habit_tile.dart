import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final bool selected;
  final bool selectionMode;
  final bool completedToday;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool?> onChanged;

  const HabitTile({
    super.key,
    required this.habit,
    required this.selected,
    required this.selectionMode,
    required this.completedToday,
    required this.onTap,
    required this.onLongPress,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Colors.blue.shade200 : null,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        leading: selectionMode
            ? Icon(
                selected
                    ? Icons.check_circle
                    : Icons.circle_outlined,
              )
            : null,
        title: Text(habit.name),
        subtitle: Text(
          'Streak: ${habit.currentStreak} • Total: ${habit.totalCompletions}',
        ),
        trailing: Checkbox(
          value: completedToday,
          onChanged: onChanged,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}