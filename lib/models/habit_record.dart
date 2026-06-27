class HabitRecord {
  final String date;
  bool completed;

  HabitRecord({
    required this.date,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'completed': completed,
    };
  }

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      date: json['date'],
      completed: json['completed'],
    );
  }
}