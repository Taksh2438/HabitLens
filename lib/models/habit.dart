import 'habit_record.dart';
import 'habit_type.dart';

class Habit {
  String id;
  String name;
  bool hasGoal;
  HabitType type;
  bool isArchived;
  int currentStreak;
  int longestStreak;
  double? targetValue;
  DateTime createdDate;
  int totalCompletions;
  List<HabitRecord> records;

  Habit({
    required this.id,
    this.targetValue,
    required this.name,
    this.hasGoal = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isArchived = false,
    required this.createdDate,
    this.totalCompletions = 0,
    List<HabitRecord>? records,
    this.type = HabitType.checkbox,
  }) : records = records ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'hasGoal': hasGoal,
      'isArchived': isArchived,
      'targetValue': targetValue,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalCompletions': totalCompletions,
      'createdDate': createdDate.toIso8601String(),
      'records': records.map((r) => r.toJson()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      hasGoal: json['hasGoal'] ?? false,
      type: HabitType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HabitType.checkbox,
      ),
      isArchived: json['isArchived'] ?? false,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalCompletions: json['totalCompletions'] ?? 0,
      createdDate: DateTime.parse(json['createdDate']),
      records: (json['records'] as List<dynamic>? ?? [])
          .map((e) => HabitRecord.fromJson(e))
          .toList(),
      targetValue: (json['targetValue'] as num?)?.toDouble(),
    );
  }
}