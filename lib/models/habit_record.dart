class HabitRecord {
  String date;
  bool completed;
  double? value;

  HabitRecord({
    required this.date,
    required this.completed,
    this.value,
  });

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    final rawValue = json['value'];

    return HabitRecord(
      date: json['date']?.toString() ?? '',
      completed: json['completed'] == true,
      value: rawValue is num
          ? rawValue.toDouble()
          : double.tryParse(rawValue?.toString() ?? ''),
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