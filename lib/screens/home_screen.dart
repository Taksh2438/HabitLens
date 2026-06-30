import '../models/habit.dart';
import 'habit_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/streak_service.dart';
import '../providers/habit_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> selectedHabits = {};

  Future<void> addHabit() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Habit'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Habit name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                controller.text.trim(),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (name == null || name.isEmpty) return;

    final habitProvider =
        Provider.of<HabitProvider>(
          context,
          listen: false,
        );

    await habitProvider.addHabit(name);

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
    final habitProvider =
        Provider.of<HabitProvider>(
          context,
          listen: false,
        );

    final habit = habitProvider.habits.firstWhere(
      (h) => h.id == selectedHabits.first,
    );

    final controller = TextEditingController(
      text: habit.name,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Habit'),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                controller.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    await habitProvider.editHabit(
      habit.id,
      result,
    );

    selectedHabits.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider =
        Provider.of<HabitProvider>(context);

    final habits = habitProvider.habits;

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
            : Builder(
                builder: (context) {
                  final incompleteHabits = habits
                      .where(
                        (h) => !StreakService.isCompletedToday(h),
                      )
                      .toList();

                  final completedHabits = habits
                      .where(
                        (h) => StreakService.isCompletedToday(h),
                      )
                      .toList();

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
                                    builder: (_) => HabitDetailsScreen(
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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
                                    builder: (_) => HabitDetailsScreen(
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
              
      floatingActionButton: FloatingActionButton(
        onPressed: addHabit,
        child: const Icon(Icons.add),
      ),
    );
  }
}