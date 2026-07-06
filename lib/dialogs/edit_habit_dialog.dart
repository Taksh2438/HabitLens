import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_type.dart';
import '../dialogs/icon_picker_dialog.dart';

class EditHabitResult {
  final String name;
  final String iconName;
  final double? targetValue;
  final String? unit;
  final double? incrementStep;

  EditHabitResult({
    required this.name,
    required this.iconName,
    this.targetValue,
    this.unit,
    this.incrementStep,
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
  late final TextEditingController unitController;
  late final TextEditingController incrementController;
  late String selectedIcon;

  @override
  void initState() {
    super.initState();
    selectedIcon = widget.habit.icon;

    nameController = TextEditingController(
      text: widget.habit.name,
    );

    goalController = TextEditingController(
      text: widget.habit.targetValue?.toString() ?? '',
    );

    unitController = TextEditingController(
      text: widget.habit.unit ?? '',
    );

    incrementController = TextEditingController(
      text: widget.habit.incrementStep.toString(),
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

            const SizedBox(height: 16),

            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (_) => const IconPickerDialog(),
                );

                if (result != null) {
                  setState(() {
                    selectedIcon = result;
                  });
                }
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      selectedIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Change Icon",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (widget.habit.type == HabitType.number ||
                widget.habit.type == HabitType.counter) ...[
              if (widget.habit.type == HabitType.number) ...[
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

                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),

              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'pages, steps, glasses...',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: incrementController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Increment Step',
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
                iconName: selectedIcon,
                targetValue: widget.habit.type == HabitType.number
                    ? double.tryParse(goalController.text)
                    : null,
                unit: (widget.habit.type == HabitType.number ||
                        widget.habit.type == HabitType.counter)
                    ? unitController.text.trim()
                    : null,
                incrementStep: (widget.habit.type == HabitType.number ||
                        widget.habit.type == HabitType.counter)
                    ? double.tryParse(incrementController.text)
                    : null,
              )
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}