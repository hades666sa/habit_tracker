import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';

class Habit {
  final int? id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String category;
  final String effortLevel;
  final int streakGoal;
  final int completionsPerDay;
  final String alarmSound;
  final String? reminderTime;
  final bool isActive;
  final DateTime createdAt;
  final int sortOrder;

  Color get parsedColor => color.toHabitColor();

  final String frequency;
  final String? frequencyDays; // e.g., '1,2,3' for Mon, Tue, Wed

  Habit({
    this.id,
    required this.name,
    this.description = '',
    required this.icon,
    required this.color,
    required this.category,
    this.effortLevel = 'MEDIUM',
    this.streakGoal = 0,
    this.completionsPerDay = 1,
    this.frequency = 'DAILY',
    this.frequencyDays,
    this.alarmSound = 'Default Alarm',
    this.reminderTime,
    this.isActive = true,
    required this.createdAt,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'category': category,
      'effort_level': effortLevel,
      'streak_goal': streakGoal,
      'completions_per_day': completionsPerDay,
      'frequency': frequency,
      'frequency_days': frequencyDays,
      'alarm_sound': alarmSound,
      'reminder_time': reminderTime,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
      category: map['category'] ?? '',
      effortLevel: map['effort_level'] ?? 'MEDIUM',
      streakGoal: map['streak_goal'] ?? 0,
      completionsPerDay: map['completions_per_day'] ?? 1,
      frequency: map['frequency'] ?? 'DAILY',
      frequencyDays: map['frequency_days'],
      alarmSound: map['alarm_sound'] ?? 'Default Alarm',
      reminderTime: map['reminder_time'],
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      sortOrder: map['sort_order'] ?? 0,
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    String? category,
    String? effortLevel,
    int? streakGoal,
    int? completionsPerDay,
    String? frequency,
    Object? frequencyDays = const Object(),
    String? alarmSound,
    Object? reminderTime = const Object(),
    bool? isActive,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      effortLevel: effortLevel ?? this.effortLevel,
      streakGoal: streakGoal ?? this.streakGoal,
      completionsPerDay: completionsPerDay ?? this.completionsPerDay,
      frequency: frequency ?? this.frequency,
      frequencyDays: frequencyDays == const Object() ? this.frequencyDays : frequencyDays as String?,
      alarmSound: alarmSound ?? this.alarmSound,
      reminderTime: reminderTime == const Object() ? this.reminderTime : reminderTime as String?,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
