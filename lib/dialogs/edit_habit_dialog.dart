import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/habit_type.dart';

class EditHabitResult {
  final String name;
  final double? targetValue;

  EditHabitResult({
    required this.name,
    this.targetValue,
  });
}

class EditHabitDialog extends StatefulWidget {
  final Habit habit;

  const EditHabitDialog({
    super.key,
    required this.habit,
  });

  @override
  State<EditHabitDialog> createState() =>
      _EditHabitDialogState();
}

class _EditHabitDialogState
    extends State<EditHabitDialog> {
  late final TextEditingController nameController;
  late final TextEditingController goalController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.habit.name,
    );

    goalController = TextEditingController(
      text: widget.habit.targetValue?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Habit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
              ),
            ),

            if (widget.habit.type ==
                HabitType.number) ...[
              const SizedBox(height: 16),

              TextField(
                controller: goalController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Daily Goal',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [

        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              EditHabitResult(
                name: nameController.text.trim(),
                targetValue:
                    widget.habit.type ==
                            HabitType.number
                        ? double.tryParse(
                            goalController.text,
                          )
                        : null,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}