import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/habit.dart';
import '../models/habit_record.dart';

class HabitDetailsScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailsScreen({
    super.key,
    required this.habit,
  });

  bool isCompleted(DateTime day) {
    final key =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

    return habit.records.any(
      (HabitRecord record) =>
          record.date == key && record.completed,
    );
  }

  String dateKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department),
              title: const Text('Current Streak'),
              trailing: Text(
                habit.currentStreak.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Longest Streak'),
              trailing: Text(
                habit.longestStreak.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Total Completions'),
              trailing: Text(
                habit.totalCompletions.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Created'),
              subtitle: Text(
                '${habit.createdDate.day}/${habit.createdDate.month}/${habit.createdDate.year}',
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Habit Calendar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          TableCalendar(
            firstDay: habit.createdDate,
            lastDay: DateTime.now().add(
              const Duration(days: 365),
            ),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final completed = isCompleted(day);

                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: completed
                        ? Colors.green
                        : Colors.transparent,
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: completed
                          ? Colors.white
                          : null,
                      fontWeight: completed
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },

              todayBuilder: (context, day, focusedDay) {
                final completed = isCompleted(day);

                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: completed
                        ? Colors.green
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),

            onDaySelected: (selectedDay, focusedDay) {
              final completed = isCompleted(selectedDay);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    completed
                        ? 'Completed on ${dateKey(selectedDay)}'
                        : 'Not completed on ${dateKey(selectedDay)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}