import 'package:flutter/material.dart';
import '../models/habit_type.dart';

class AddHabitResult {
  final String name;
  final String? unit;
  final bool hasGoal;
  final HabitType type;
  final double? targetValue;
  final double incrementStep;

  AddHabitResult({
    this.unit,
    this.targetValue,
    required this.name,
    required this.type,
    this.hasGoal = false,
    this.incrementStep = 1,
  });
}

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() =>
      _AddHabitDialogState();
}

class _AddHabitDialogState
    extends State<AddHabitDialog> {
  final nameController = TextEditingController();
  final goalController = TextEditingController();
  final unitController = TextEditingController();
  final incrementController =
      TextEditingController(text: '1');

  HabitType selectedType = HabitType.checkbox;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Habit"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Habit name",
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<HabitType>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: "Habit Type",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: HabitType.checkbox,
                  child: Text("Checkbox"),
                ),
                DropdownMenuItem(
                  value: HabitType.number,
                  child: Text("Number Goal"),
                ),
                DropdownMenuItem(
                  value: HabitType.counter,
                  child: Text("Counter"),
                ),
                DropdownMenuItem(
                  value: HabitType.rating,
                  child: Text("Rating"),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
            ),

            if (selectedType == HabitType.number) ...[
              const SizedBox(height: 16),

              TextField(
                controller: goalController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText: "Daily Goal",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit (optional)',
                  hintText: 'pages, glasses, km...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: incrementController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Increment step',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            if (selectedType == HabitType.counter) ...[
              const SizedBox(height: 16),

              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit (optional)',
                  hintText: 'steps, pages, glasses...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: incrementController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Increment step',
                  hintText: 'Example: 1, 5, 0.5, 500',
                  border: OutlineInputBorder(),
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
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              AddHabitResult(
                name: nameController.text.trim(),
                type: selectedType,
                targetValue: selectedType == HabitType.number
                    ? double.tryParse(goalController.text)
                    : null,
                hasGoal: selectedType == HabitType.number,
                unit: unitController.text.trim().isEmpty
                    ? null
                    : unitController.text.trim(),

                incrementStep:
                    double.tryParse(incrementController.text) ?? 1,
              )
            );
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}