class HabitRecord {
  String date;
  bool completed;
  double? value;

  HabitRecord({
    required this.date,
    required this.completed,
    this.value,
  });

  factory HabitRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return HabitRecord(
      date: json['date'],
      completed: json['completed'],
      value: (json['value'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'completed': completed,
      'value': value,
    };
  }
}