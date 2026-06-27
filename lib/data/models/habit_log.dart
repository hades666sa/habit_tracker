class HabitLog {
  final int? id;
  final int habitId;
  final String logDate; // 'YYYY-MM-DD'
  final int completionsCount;

  HabitLog({
    this.id,
    required this.habitId,
    required this.logDate,
    this.completionsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habit_id': habitId,
      'log_date': logDate,
      'completions_count': completionsCount,
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'],
      habitId: map['habit_id'],
      logDate: map['log_date'],
      completionsCount: map['completions_count'] ?? 0,
    );
  }

  HabitLog copyWith({
    int? id,
    int? habitId,
    String? logDate,
    int? completionsCount,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      logDate: logDate ?? this.logDate,
      completionsCount: completionsCount ?? this.completionsCount,
    );
  }
}
