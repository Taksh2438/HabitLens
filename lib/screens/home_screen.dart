
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dialogs/add_habit_dialog.dart';
import '../dialogs/edit_habit_dialog.dart';
import '../models/habit.dart';
import '../models/habit_type.dart';
import '../providers/habit_provider.dart';
import '../services/streak_service.dart';
import '../widgets/checkbox_habit_tile.dart';
import '../widgets/counter_habit_tile.dart';
import '../widgets/number_habit_tile.dart';
import '../widgets/rating_habit_tile.dart';
import 'habit_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> selectedHabits = {};

  Future<void> addHabit() async {
    final result = await showDialog<AddHabitResult>(
      context: context,
      builder: (_) => const AddHabitDialog(),
    );

    if (result == null || result.name.trim().isEmpty || !mounted) {
      return;
    }

    await context.read<HabitProvider>().addHabit(
      result.name.trim(),
      result.iconName,
      result.type,
      result.targetValue,
      result.hasGoal,
      result.unit,
      result.incrementStep,
    );
  }

  Future<void> toggleHabitCompletion(Habit habit) async {
    await context.read<HabitProvider>().toggleHabit(habit);
  }

  void toggleSelection(String id) {
    setState(() {
      if (!selectedHabits.add(id)) {
        selectedHabits.remove(id);
      }
    });
  }

  Future<void> deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Habits'),
        content: Text(
          'Delete ${selectedHabits.length} selected habit(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await context.read<HabitProvider>().deleteHabits(
      selectedHabits.toList(),
    );

    if (mounted) {
      setState(selectedHabits.clear);
    }
  }

  Future<void> editSelectedHabit() async {
    if (selectedHabits.length != 1) return;

    final provider = context.read<HabitProvider>();
    final id = selectedHabits.first;
    final matches = provider.habits.where((habit) => habit.id == id);
    if (matches.isEmpty) {
      setState(selectedHabits.clear);
      return;
    }

    final habit = matches.first;
    final result = await showDialog<EditHabitResult>(
      context: context,
      builder: (_) => EditHabitDialog(habit: habit),
    );

    if (result == null || !mounted) return;

    await provider.editHabit(
      id: habit.id,
      name: result.name,
      icon: result.iconName,
      targetValue: result.targetValue,
      unit: result.unit,
      incrementStep: result.incrementStep,
    );

    if (mounted) setState(selectedHabits.clear);
  }

  bool _countsTowardProgress(Habit habit) {
    switch (habit.type) {
      case HabitType.checkbox:
      case HabitType.number:
        return true;
      case HabitType.counter:
        return habit.targetValue != null && habit.targetValue! > 0;
      case HabitType.rating:
        return false;
    }
  }

  Widget _habitCard(Habit habit, bool selectionMode) {
    final selected = selectedHabits.contains(habit.id);

    final Widget trailing = switch (habit.type) {
      HabitType.checkbox => CheckboxHabitTile(
          value: StreakService.isCompletedToday(habit),
          selectionMode: selectionMode,
          onChanged: () => toggleHabitCompletion(habit),
        ),
      HabitType.number => NumberHabitTile(habit: habit),
      HabitType.counter => CounterHabitTile(habit: habit),
      HabitType.rating => RatingHabitTile(habit: habit),
    };

    return Card(
      key: ValueKey(habit.id),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: selected ? Colors.blue.shade200 : null,
      child: ListTile(
        leading: selectionMode
            ? Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
              )
            : CircleAvatar(
                radius: 20,
                child: Text(
                  habit.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
        title: Text(
          habit.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        dense: true,
        subtitle: switch (habit.type) {
          HabitType.counter => Text(
              '${habit.records.isEmpty ? 0 : habit.records.last.value ?? 0} ${habit.unit ?? ''}'
                  .trim(),
            ),
          HabitType.rating => const Text('Rating habit'),
          _ => Text(
              'Streak: ${habit.currentStreak} • Total: ${habit.totalCompletions}',
            ),
        },
        trailing: trailing,
        onLongPress: () => toggleSelection(habit.id),
        onTap: () {
          if (selectionMode) {
            toggleSelection(habit.id);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HabitDetailsScreen(habit: habit),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;
    final selectionMode = selectedHabits.isNotEmpty;

    final progressHabits =
        habits.where(_countsTowardProgress).toList();
    final completedCount = progressHabits
        .where(StreakService.isCompletedToday)
        .length;
    final progress = progressHabits.isEmpty
        ? 0.0
        : completedCount / progressHabits.length;

    final completedHabits =
        habits.where(StreakService.isCompletedToday).toList();
    final incompleteHabits = habits
        .where((habit) => !StreakService.isCompletedToday(habit))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectionMode ? '${selectedHabits.length} selected' : 'HabitLens',
        ),
        actions: [
          if (selectedHabits.length == 1)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: editSelectedHabit,
            ),
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteSelected,
            ),
        ],
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'No habits yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Progress",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '✅ $completedCount/${progressHabits.length}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            progressHabits.isNotEmpty && progress == 1
                                ? 'All tracked habits completed today 🎉'
                                : '${progressHabits.length - completedCount} habit(s) remaining',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 90),
                    children: [
                      for (final habit in incompleteHabits)
                        _habitCard(habit, selectionMode),
                      if (completedHabits.isNotEmpty &&
                          incompleteHabits.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  'Completed Today',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ),
                      for (final habit in completedHabits)
                        _habitCard(habit, selectionMode),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }
}
