import '../models/habit.dart';
import 'habit_details_screen.dart';
import '../models/habit_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/streak_service.dart';
import '../dialogs/add_habit_dialog.dart';
import '../providers/habit_provider.dart';
import '../dialogs/edit_habit_dialog.dart';
import '../widgets/number_habit_tile.dart';
import '../widgets/rating_habit_tile.dart';
import '../widgets/counter_habit_tile.dart';
import '../widgets/checkbox_habit_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> selectedHabits = {};

  Future<void> addHabit() async {
    final result =
        await showDialog<AddHabitResult>(
      context: context,
      builder: (_) => const AddHabitDialog(),
    );

    if (result == null || result.name.isEmpty) {
      return;
    }

    if (!mounted) return;

    await Provider.of<HabitProvider>(
      context,
      listen: false,
    ).addHabit(
      result.name,
      result.type,
      result.targetValue,
      result.hasGoal,
      result.unit,
      result.incrementStep,
    );
  }

  Future<void> toggleHabitCompletion(Habit habit) async {
    final habitProvider =
        Provider.of<HabitProvider>(
          context,
          listen: false,
        );

    await habitProvider.toggleHabit(habit);
  }

  void toggleSelection(String id) {
    setState(() {
      if (selectedHabits.contains(id)) {
        selectedHabits.remove(id);
      } else {
        selectedHabits.add(id);
      }
    });
  }

  Future<void> deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habits'),
        content: Text(
          'Delete ${selectedHabits.length} selected habit(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm != true) return;

    final habitProvider =
        Provider.of<HabitProvider>(
          context,
          listen: false,
        );

    await habitProvider.deleteHabits(
      selectedHabits.toList(),
    );

    selectedHabits.clear();

    setState(() {});
  }

  Future<void> editSelectedHabit() async {
    final habitProvider = Provider.of<HabitProvider>(
      context,
      listen: false,
    );

    final habit = habitProvider.habits.firstWhere(
      (h) => h.id == selectedHabits.first,
    );

    final result = await showDialog<EditHabitResult>(
      context: context,
      builder: (_) => EditHabitDialog(
        habit: habit,
      ),
    );

    if (result == null) return;

    await habitProvider.editHabit(
      id: habit.id,
      name: result.name,
      targetValue: result.targetValue,
      unit: result.unit,
      incrementStep: result.incrementStep,
    );

    selectedHabits.clear();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider =
        Provider.of<HabitProvider>(context);

    final habits = habitProvider.habits;

    final completedToday = habits.where((h) {
      if (h.type == HabitType.counter ||
          h.type == HabitType.rating) {
        return false;
      }

      return StreakService.isCompletedToday(h);
    }).length;

    final goalHabits = habits.where(
      (h) =>
          h.type != HabitType.counter &&
          h.type != HabitType.rating,
    ).toList();

    final progress =
        goalHabits.isEmpty
            ? 0.0
            : completedToday / goalHabits.length;

    final selectionMode = selectedHabits.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectionMode
              ? '${selectedHabits.length} selected'
              : 'HabitLens',
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
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    8,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
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
                                        '✅ $completedToday/${goalHabits.length}',
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
                                  progress == 1
                                      ? 'All habits completed today 🎉'
                                      : '${goalHabits.length - completedToday} habit(s) remaining',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 10),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Builder(
                    builder: (context) {
                      final incompleteHabits = habits.where((h) {
                        if (h.type == HabitType.number ||
                            h.type == HabitType.counter ||
                            h.type == HabitType.rating) {
                          return true;
                        }

                        return !StreakService.isCompletedToday(h);
                      }).toList();

                      final completedHabits = habits.where((h) {
                        if (h.type == HabitType.number ||
                            h.type == HabitType.counter ||
                            h.type == HabitType.rating) {
                          return false;
                        }

                        return StreakService.isCompletedToday(h);
                      }).toList();

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          90,
                        ),
                        children: [
                          for (final habit in incompleteHabits)
                            Card(
                              key: ValueKey(habit.id),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              color: selectedHabits.contains(habit.id)
                                  ? Colors.blue.shade200
                                  : null,
                              child: ListTile(
                                leading: selectionMode
                                    ? Icon(
                                        selectedHabits.contains(habit.id)
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                      )
                                    : null,
                                title: Text(habit.name),
                                subtitle: Text(
                                  'Streak: ${habit.currentStreak} • Total: ${habit.totalCompletions}',
                                ),
                                trailing: switch (habit.type) {
                                  HabitType.checkbox => CheckboxHabitTile(
                                      value: StreakService.isCompletedToday(habit),
                                      selectionMode: selectionMode,
                                      onChanged: () {
                                        toggleHabitCompletion(habit);
                                      },
                                    ),

                                  HabitType.number => NumberHabitTile(
                                      habit: habit,
                                    ),

                                  HabitType.counter => CounterHabitTile(
                                    habit: habit,
                                  ),

                                  HabitType.rating => RatingHabitTile(
                                    habit: habit,
                                  ),
                                },
                                onLongPress: () =>
                                    toggleSelection(habit.id),
                                onTap: () {
                                  if (selectionMode) {
                                    toggleSelection(habit.id);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            HabitDetailsScreen(
                                          habit: habit,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),

                          if (incompleteHabits.isNotEmpty &&
                              completedHabits.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      'Completed Today',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                            ),

                          for (final habit in completedHabits)
                            Card(
                              key: ValueKey(habit.id),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              color: selectedHabits.contains(habit.id)
                                  ? Colors.blue.shade200
                                  : null,
                              child: ListTile(
                                leading: selectionMode
                                    ? Icon(
                                        selectedHabits.contains(habit.id)
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                      )
                                    : null,
                                title: Text(habit.name),
                                subtitle: Text(
                                  'Streak: ${habit.currentStreak} • Total: ${habit.totalCompletions}',
                                ),
                                trailing: Checkbox(
                                  value: StreakService.isCompletedToday(habit),
                                  onChanged: (_) {
                                    if (!selectionMode) {
                                      toggleHabitCompletion(habit);
                                    }
                                  },
                                ),
                                onLongPress: () =>
                                    toggleSelection(habit.id),
                                onTap: () {
                                  if (selectionMode) {
                                    toggleSelection(habit.id);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            HabitDetailsScreen(
                                          habit: habit,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      );
                    },
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