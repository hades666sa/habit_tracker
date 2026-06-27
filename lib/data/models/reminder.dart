class Reminder {
  final int? id;
  final int habitId;
  final String reminderTime; // 'HH:mm'
  final bool isActive;

  Reminder({
    this.id,
    required this.habitId,
    required this.reminderTime,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habit_id': habitId,
      'reminder_time': reminderTime,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      habitId: map['habit_id'],
      reminderTime: map['reminder_time'],
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }

  Reminder copyWith({
    int? id,
    int? habitId,
    String? reminderTime,
    bool? isActive,
  }) {
    return Reminder(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
    );
  }
}
