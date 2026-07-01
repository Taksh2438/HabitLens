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

    final completedToday = habits
        .where(
          (h) => StreakService.isCompletedToday(h),
        )
        .length;

    final progress =
        habits.isEmpty
            ? 0.0
            : completedToday / habits.length;

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

                          SizedBox(
                            width: 90,
                            height: 90,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      progress == 1
                                          ? Colors.green
                                          : progress >= 0.75
                                              ? Colors.lightGreen
                                              : progress >= 0.50
                                                  ? Colors.orange
                                                  : progress >= 0.25
                                                      ? Colors.deepOrange
                                                      : Colors.red,
                                    ),
                                  ),
                                ),

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Done',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

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

                                const SizedBox(height: 10),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [

                                    Chip(
                                      avatar: Icon(Icons.check, size: 18),
                                      label: Text('$completedToday Completed'),
                                    ),

                                    Chip(
                                      avatar: Icon(Icons.pending, size: 18),
                                      label: Text(
                                        '${habits.length - completedToday} Remaining',
                                      ),
                                    ),

                                    Chip(
                                      avatar: Icon(Icons.list, size: 18),
                                      label: Text('${habits.length} Total'),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  progress == 0
                                      ? "🚀 Your journey starts today."
                                      : progress < 0.25
                                          ? "💪 Keep the momentum going."
                                          : progress < 0.50
                                              ? "🔥 Great progress so far."
                                              : progress < 0.75
                                                  ? "⚡ You're over halfway there!"
                                                  : progress < 1
                                                      ? "🏁 Just a few habits left!"
                                                      : "🏆 Perfect day! Every habit completed.",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
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