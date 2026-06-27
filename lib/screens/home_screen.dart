import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import '../services/streak_service.dart';
import 'stats_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> habits = [];
  final Set<String> selectedHabits = {};

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  Future<void> loadHabits() async {
    habits = await StorageService.loadHabits();
    setState(() {});
  }

  Future<void> saveHabits() async {
    await StorageService.saveHabits(habits);
  }

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

    if (name == null || name.isEmpty) return;

    habits.add(
      Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdDate: DateTime.now(),
      ),
    );

    await saveHabits();
    setState(() {});
  }

  Future<void> toggleHabitCompletion(Habit habit) async {
    StreakService.toggleToday(habit);

    await saveHabits();

    setState(() {});
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

    if (confirm != true) return;

    habits.removeWhere(
      (habit) => selectedHabits.contains(habit.id),
    );

    selectedHabits.clear();

    await saveHabits();

    setState(() {});
  }

  Future<void> editSelectedHabit() async {
    final selectedId = selectedHabits.first;

    final habit = habits.firstWhere(
      (h) => h.id == selectedId,
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
          autofocus: true,
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

    habit.name = result;

    selectedHabits.clear();

    await saveHabits();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectionMode = selectedHabits.isNotEmpty;
    final themeProvider =
      Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectionMode
              ? '${selectedHabits.length} selected'
              : 'HabitLens',
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatsScreen(
                    habits: habits,
                  ),
                ),
              );
            },
          ),
        
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
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final selected =
                    selectedHabits.contains(habit.id);

                final completedToday =
                    StreakService.isCompletedToday(habit);

                return Card(
                  color: selected
                      ? Colors.blue.shade200
                      : null,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: selectionMode
                        ? Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                          )
                        : null,
                    title: Text(habit.name),
                    subtitle: Text(
                      'Streak: ${habit.currentStreak} • Total: ${habit.totalCompletions}',
                    ),
                    trailing: Checkbox(
                      value: completedToday,
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
                      }
                    },
                  ),
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