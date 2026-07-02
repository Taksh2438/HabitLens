import 'package:flutter/material.dart';
import '../models/habit_type.dart';

class AddHabitResult {
  final String name;
  final HabitType type;
  final double? targetValue;

  AddHabitResult({
    required this.name,
    required this.type,
    this.targetValue,
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

  HabitType selectedType =
      HabitType.checkbox;

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
                  child: Text("Number"),
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

            if (selectedType ==
                HabitType.number) ...[
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
                targetValue:
                    selectedType ==
                            HabitType.number
                        ? double.tryParse(
                            goalController.text,
                          )
                        : null,
              ),
            );
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}