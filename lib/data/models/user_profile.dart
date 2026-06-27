import 'dart:convert';

class UserProfile {
  final int id;
  final String name;
  final List<String> focusAreas;
  final String themeMode;
  final bool onboardingComplete;
  final String? dailyReminderTime;
  final String dailyReminderSound;

  UserProfile({
    this.id = 1,
    required this.name,
    required this.focusAreas,
    this.themeMode = 'dark',
    this.onboardingComplete = false,
    this.dailyReminderTime,
    this.dailyReminderSound = 'default',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'focus_areas': jsonEncode(focusAreas),
      'theme_mode': themeMode,
      'onboarding_complete': onboardingComplete ? 1 : 0,
      'daily_reminder_time': dailyReminderTime,
      'daily_reminder_sound': dailyReminderSound,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? 1,
      name: map['name'] ?? '',
      focusAreas: List<String>.from(jsonDecode(map['focus_areas'] ?? '[]')),
      themeMode: map['theme_mode'] ?? 'dark',
      onboardingComplete: (map['onboarding_complete'] ?? 0) == 1,
      dailyReminderTime: map['daily_reminder_time'],
      dailyReminderSound: map['daily_reminder_sound'] ?? 'default',
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    List<String>? focusAreas,
    String? themeMode,
    bool? onboardingComplete,
    Object? dailyReminderTime = const Object(),
    String? dailyReminderSound,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      focusAreas: focusAreas ?? this.focusAreas,
      themeMode: themeMode ?? this.themeMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      dailyReminderTime: dailyReminderTime == const Object() ? this.dailyReminderTime : dailyReminderTime as String?,
      dailyReminderSound: dailyReminderSound ?? this.dailyReminderSound,
    );
  }
}
