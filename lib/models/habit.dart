import 'habit_record.dart';
import 'habit_type.dart';

class Habit {
  String id;
  String name;
  bool hasGoal;
  String? unit;
  HabitType type;
  bool isArchived;
  int currentStreak;
  int longestStreak;
  double? targetValue;
  double incrementStep;
  DateTime createdDate;
  int totalCompletions;
  List<HabitRecord> records;

  Habit({
    this.unit,
    this.targetValue,
    required this.id,
    required this.name,
    this.hasGoal = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.incrementStep = 1,
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
      'unit': unit,
      'type': type.name,
      'hasGoal': hasGoal,
      'isArchived': isArchived,
      'targetValue': targetValue,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'incrementStep': incrementStep,
      'totalCompletions': totalCompletions,
      'createdDate': createdDate.toIso8601String(),
      'records': records.map((r) => r.toJson()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      unit: json['unit'],
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
      incrementStep: (json['incrementStep'] ?? 1).toDouble(),
    );
  }
}