import 'package:flutter/material.dart';

import '../models/habit_type.dart';
import 'icon_picker_dialog.dart';

class AddHabitResult {
  final String name;
  final String iconName;
  final String? unit;
  final bool hasGoal;
  final HabitType type;
  final double? targetValue;
  final double incrementStep;

  const AddHabitResult({
    required this.name,
    required this.iconName,
    required this.type,
    this.unit,
    this.hasGoal = false,
    this.targetValue,
    this.incrementStep = 1,
  });
}

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final nameController = TextEditingController();
  final goalController = TextEditingController();
  final unitController = TextEditingController();
  final incrementController = TextEditingController(text: '1');

  HabitType selectedType = HabitType.checkbox;
  String selectedIcon = '✅';

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

  void saveHabit() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      showError('Enter a habit name.');
      return;
    }

    final usesGoal = selectedType == HabitType.number ||
        selectedType == HabitType.counter;
    final rawGoal = goalController.text.trim();
    double? target;

    if (selectedType == HabitType.number && rawGoal.isEmpty) {
      showError('Enter a daily goal for a number habit.');
      return;
    }

    if (usesGoal && rawGoal.isNotEmpty) {
      target = double.tryParse(rawGoal);
      if (target == null || !target.isFinite || target <= 0) {
        showError('Goal must be a number greater than zero.');
        return;
      }
    }

    final increment = double.tryParse(incrementController.text.trim());
    if (usesGoal &&
        (increment == null || !increment.isFinite || increment <= 0)) {
      showError('Increment step must be greater than zero.');
      return;
    }

    final unit = unitController.text.trim();

    Navigator.pop(
      context,
      AddHabitResult(
        name: name,
        iconName: selectedIcon,
        type: selectedType,
        targetValue: target,
        hasGoal: target != null,
        unit: usesGoal && unit.isNotEmpty ? unit : null,
        incrementStep: usesGoal ? increment! : 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usesGoal = selectedType == HabitType.number ||
        selectedType == HabitType.counter;

    return AlertDialog(
      title: const Text('Add Habit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
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
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Choose Icon'),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HabitType>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: 'Habit type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: HabitType.checkbox,
                  child: Text('Checkbox'),
                ),
                DropdownMenuItem(
                  value: HabitType.number,
                  child: Text('Number Goal'),
                ),
                DropdownMenuItem(
                  value: HabitType.counter,
                  child: Text('Counter'),
                ),
                DropdownMenuItem(
                  value: HabitType.rating,
                  child: Text('Rating'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedType = value);
                }
              },
            ),
            if (usesGoal) ...[
              const SizedBox(height: 16),
              TextField(
                controller: goalController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: selectedType == HabitType.counter
                      ? 'Daily goal (optional)'
                      : 'Daily goal',
                  hintText: selectedType == HabitType.counter
                      ? 'Leave blank for no goal'
                      : 'e.g. 5',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Unit (optional)',
                  hintText: 'pages, glasses, km...',
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
                  hintText: 'e.g. 1, 5, 0.5',
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
          onPressed: saveHabit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}