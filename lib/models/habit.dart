import 'habit_record.dart';

class Habit {
  String id;
  String name;
  DateTime createdDate;
  int currentStreak;
  int longestStreak;
  int totalCompletions;
  bool isArchived;
  List<HabitRecord> records;

  Habit({
    required this.id,
    required this.name,
    required this.createdDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.isArchived = false,
    List<HabitRecord>? records,
  }) : records = records ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdDate': createdDate.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalCompletions': totalCompletions,
      'isArchived': isArchived,
      'records': records.map((r) => r.toJson()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      createdDate: DateTime.parse(json['createdDate']),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalCompletions: json['totalCompletions'] ?? 0,
      isArchived: json['isArchived'] ?? false,
      records: (json['records'] as List<dynamic>? ?? [])
          .map((e) => HabitRecord.fromJson(e))
          .toList(),
    );
  }
}