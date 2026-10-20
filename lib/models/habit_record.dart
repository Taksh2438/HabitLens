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
    final rawDate = json['date']?.toString() ?? '';
    final parsedValue = _parseValue(json['value']);

    return HabitRecord(
      date: rawDate,
      completed: json['completed'] == true,
      value: parsedValue,
    );
  }

  static double? _parseValue(dynamic raw) {
    if (raw is! num && raw is! String) return null;

    final parsed = double.tryParse(raw.toString());
    return parsed != null && parsed.isFinite ? parsed : null;
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'completed': completed,
        'value': value,
      };
}