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
  State<EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<EditHabitDialog> {
  late final TextEditingController nameController;
  late final TextEditingController goalController;
  late final TextEditingController unitController;
  late final TextEditingController incrementController;

  late String selectedIcon;

  bool get usesGoalAndCounterFields =>
      widget.habit.type == HabitType.number ||
      widget.habit.type == HabitType.counter;

  @override
  void initState() {
    super.initState();

    selectedIcon = widget.habit.icon;
    nameController = TextEditingController(text: widget.habit.name);
    goalController = TextEditingController(
      text: widget.habit.targetValue?.toString() ?? '',
    );
    unitController = TextEditingController(text: widget.habit.unit ?? '');
    incrementController = TextEditingController(
      text: widget.habit.incrementStep.toString(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    goalController.dispose();
    unitController.dispose();
    incrementController.dispose();
    super.dispose();
  }

  void saveChanges() {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final targetText = goalController.text.trim();
    final target = targetText.isEmpty
        ? null
        : double.tryParse(targetText);

    if (usesGoalAndCounterFields &&
        targetText.isNotEmpty &&
        (target == null || target <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid positive daily goal.')),
      );
      return;
    }

    final increment = double.tryParse(incrementController.text.trim());

    if (usesGoalAndCounterFields &&
        (increment == null || increment <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Increment step must be greater than zero.')),
      );
      return;
    }

    Navigator.pop(
      context,
      EditHabitResult(
        name: name,
        iconName: selectedIcon,
        targetValue: usesGoalAndCounterFields ? target : null,
        unit: usesGoalAndCounterFields
            ? (unitController.text.trim().isEmpty
                ? null
                : unitController.text.trim())
            : null,
        incrementStep: usesGoalAndCounterFields ? increment : null,
      ),
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
              textCapitalization: TextCapitalization.sentences,
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

                if (result != null && mounted) {
                  setState(() => selectedIcon = result);
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
                  const Expanded(child: Text('Change Icon')),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            if (usesGoalAndCounterFields) ...[
              const SizedBox(height: 16),
              TextField(
                controller: goalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: widget.habit.type == HabitType.counter
                      ? 'Daily Goal (optional)'
                      : 'Daily Goal',
                  hintText: 'Leave empty for no goal',
                ),
              ),
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
                keyboardType: const TextInputType.numberWithOptions(
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: saveChanges,
          child: const Text('Save'),
        ),
      ],
    );
  }
}