
import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../models/habit_type.dart';
import 'icon_picker_dialog.dart';

class EditHabitResult {
  final String name;
  final String iconName;
  final double? targetValue;
  final String? unit;
  final double? incrementStep;

  const EditHabitResult({
    required this.name,
    required this.iconName,
    this.targetValue,
    this.unit,
    this.incrementStep,
  });
}

class EditHabitDialog extends StatefulWidget {
  final Habit habit;

  const EditHabitDialog({super.key, required this.habit});

  @override
  State<EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<EditHabitDialog> {
  late final TextEditingController nameController;
  late final TextEditingController goalController;
  late final TextEditingController unitController;
  late final TextEditingController incrementController;
  late String selectedIcon;

  bool get usesGoal =>
      widget.habit.type == HabitType.number ||
      widget.habit.type == HabitType.counter;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    selectedIcon = habit.icon;
    nameController = TextEditingController(text: habit.name);
    goalController = TextEditingController(
      text: habit.targetValue?.toString() ?? '',
    );
    unitController = TextEditingController(text: habit.unit ?? '');
    incrementController = TextEditingController(
      text: habit.incrementStep.toString(),
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

  Future<void> chooseIcon() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const IconPickerDialog(),
    );

    if (result != null && mounted) {
      setState(() => selectedIcon = result);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void saveChanges() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showError('Enter a habit name.');
      return;
    }

    double? target;
    final rawGoal = goalController.text.trim();

    if (usesGoal && rawGoal.isNotEmpty) {
      target = double.tryParse(rawGoal);
      if (target == null || !target.isFinite || target <= 0) {
        showError('Goal must be a number greater than zero.');
        return;
      }
    }

    if (widget.habit.type == HabitType.number && target == null) {
      showError('A number habit must have a daily goal.');
      return;
    }

    double? increment;
    if (usesGoal) {
      increment = double.tryParse(incrementController.text.trim());
      if (increment == null ||
          !increment.isFinite ||
          increment <= 0) {
        showError('Increment step must be greater than zero.');
        return;
      }
    }

    final unit = unitController.text.trim();

    Navigator.pop(
      context,
      EditHabitResult(
        name: name,
        iconName: selectedIcon,
        targetValue: usesGoal ? target : null,
        unit: usesGoal && unit.isNotEmpty ? unit : null,
        incrementStep: increment,
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
                labelText: 'Habit name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: chooseIcon,
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
                  const Expanded(child: Text('Change icon')),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            if (usesGoal) ...[
              const SizedBox(height: 16),
              TextField(
                controller: goalController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: widget.habit.type == HabitType.counter
                      ? 'Daily goal (optional)'
                      : 'Daily goal',
                  hintText: widget.habit.type == HabitType.counter
                      ? 'Leave blank to remove the goal'
                      : 'e.g. 5',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit (optional)',
                  hintText: 'pages, steps, glasses...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: incrementController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Increment step',
                  border: OutlineInputBorder(),
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
