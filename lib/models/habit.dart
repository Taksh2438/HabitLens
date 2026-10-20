import 'habit_record.dart';
import 'habit_type.dart';

class Habit {
  String id;
  String name;
  bool hasGoal;
  String? unit;
  HabitType type;
  bool isArchived;
  String icon;
  int currentStreak;
  int longestStreak;
  double? targetValue;
  double incrementStep;
  DateTime createdDate;
  int totalCompletions;
  List<HabitRecord> records;

  Habit({
    required this.id,
    required this.name,
    this.hasGoal = false,
    this.unit,
    this.icon = '✅',
    this.type = HabitType.checkbox,
    this.isArchived = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.targetValue,
    this.incrementStep = 1,
    required this.createdDate,
    this.totalCompletions = 0,
    List<HabitRecord>? records,
  }) : records = records ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
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
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final createdDate = DateTime.tryParse(
          json['createdDate']?.toString() ?? '',
        ) ??
        DateTime.now();

    final typeName = json['type']?.toString();

    return Habit(
      id: json['id']?.toString() ??
          'legacy-${createdDate.microsecondsSinceEpoch}',
      name: json['name']?.toString() ?? 'Untitled habit',
      icon: json['icon']?.toString() ?? '✅',
      unit: json['unit']?.toString(),
      hasGoal: json['hasGoal'] == true,
      type: HabitType.values.firstWhere(
        (type) => type.name == typeName,
        orElse: () => HabitType.checkbox,
      ),
      isArchived: json['isArchived'] == true,
      currentStreak: _toInt(json['currentStreak']) ?? 0,
      longestStreak: _toInt(json['longestStreak']) ?? 0,
      totalCompletions: _toInt(json['totalCompletions']) ?? 0,
      createdDate: createdDate,
      records: _readRecords(json['records']),
      targetValue: _toDouble(json['targetValue']),
      incrementStep: _toDouble(json['incrementStep']) ?? 1,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static List<HabitRecord> _readRecords(dynamic value) {
    if (value is! List) return [];

    final result = <HabitRecord>[];

    for (final item in value) {
      if (item is! Map) continue;

      try {
        result.add(
          HabitRecord.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (_) {
        // Ignore malformed records while loading saved habits.
      }
    }

    return result;
  }
}