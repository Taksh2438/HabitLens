import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

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

    final weeklyData =
        StatsService.last7Days(habitProvider.habits);

    final topHabits =
        StatsService.topHabits(habitProvider.habits);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Completion Rate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      '${stats.completionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  LinearProgressIndicator(
                    value: stats.completionRate / 100,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [

              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    child: Column(
                      children: [

                        const Icon(
                          Icons.today,
                          size: 32,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Today',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '${stats.completedToday}/${stats.activeHabits}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    child: Column(
                      children: [

                        const Icon(
                          Icons.local_fire_department,
                          size: 32,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Best Streak',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '${stats.longestStreak}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    child: Column(
                      children: [

                        const Icon(
                          Icons.list_alt,
                          size: 32,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Habits',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          stats.activeHabits.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    child: Column(
                      children: [

                        const Icon(
                          Icons.check_circle,
                          size: 32,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Completed',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          stats.totalCompletions.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Last 7 Days',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const labels = [
                              '6d',
                              '5d',
                              '4d',
                              '3d',
                              '2d',
                              'Y',
                              'T',
                            ];

                            return Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(
                      weeklyData.length,
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: weeklyData[i].toDouble(),
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '🏆 Top Habits',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: List.generate(
                topHabits.length,
                (index) {
                  final habit = topHabits[index];

                  final medal = switch (index) {
                    0 => '🥇',
                    1 => '🥈',
                    _ => '🥉',
                  };

                  return ListTile(
                    leading: Text(
                      '$medal ${habit.icon}',
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(
                      habit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '${habit.totalCompletions}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}