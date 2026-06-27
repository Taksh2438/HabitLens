import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_stats.dart';
import '../providers/habit_provider.dart';
import '../services/stats_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);

    final AppStats stats =
        StatsService.calculate(habitProvider.habits);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Total Habits'),
              trailing: Text(
                stats.totalHabits.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Total Completions'),
              trailing: Text(
                stats.totalCompletions.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department),
              title: const Text('Longest Streak'),
              trailing: Text(
                stats.longestStreak.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.percent),
              title: const Text('Completion Rate'),
              trailing: Text(
                '${stats.completionRate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}