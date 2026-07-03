import 'package:flutter/material.dart';

class CheckboxHabitTile extends StatelessWidget {
  final bool value;
  final bool selectionMode;
  final VoidCallback onChanged;

  const CheckboxHabitTile({
    super.key,
    required this.value,
    required this.selectionMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: (_) {
        if (!selectionMode) {
          onChanged();
        }
      },
    );
  }
}