import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/user_repository.dart';
import '../utils/notification_service.dart';
import '../utils/widget_service.dart';
import '../data/models/habit.dart';

class SettingsProvider with ChangeNotifier {
  final UserRepository _repository = UserRepository();
  UserProfile? _profile;
  ThemeMode _themeMode = ThemeMode.system;
  List<int> _widgetHabitIds = []; // IDs of habits shown in widget

  // General Settings
  int _weekStartDay = 1; // 1 = Monday, 7 = Sunday
  bool _showViewModeBottomBar = true;
  bool _showCategoryFilter = true;
  bool _showStreakCount = true;
  bool _showStreakGoal = true;
  bool _showMonthLabels = true;
  bool _showDayLabels = true;
  bool _showCategories = true;
  bool _legacyPerformanceMode = true;
  bool _allowCrashlytics = true;

  List<int> get widgetHabitIds => _widgetHabitIds;
  int get weekStartDay => _weekStartDay;
  bool get showViewModeBottomBar => _showViewModeBottomBar;
  bool get showCategoryFilter => _showCategoryFilter;
  bool get showStreakCount => _showStreakCount;
  bool get showStreakGoal => _showStreakGoal;
  bool get showMonthLabels => _showMonthLabels;
  bool get showDayLabels => _showDayLabels;
  bool get showCategories => _showCategories;
  bool get legacyPerformanceMode => _legacyPerformanceMode;
  bool get allowCrashlytics => _allowCrashlytics;

  Future<void> updateWidgetForHabit(Habit habit, Map<String, int> logs) async {
    bool changed = false;
    if (!_widgetHabitIds.contains(habit.id!)) {
      _widgetHabitIds.add(habit.id!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('widget_habit_ids', _widgetHabitIds.map((id) => id.toString()).toList());
      changed = true;
    }

    // Do not await this if it blocks UI unnecessarily, but we already added a delay in WidgetService
    await WidgetService.updateWidgetDataForHabit(habit: habit, logs: logs);
    
    if (changed) {
      notifyListeners();
    }
  }

  UserProfile? get profile => _profile;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    _profile = await _repository.getProfile();
    final prefs = await SharedPreferences.getInstance();
    
    final themeStr = prefs.getString('themeMode') ?? _profile?.themeMode ?? 'system';
    _themeMode = _parseThemeMode(themeStr);

    final widgetIds = prefs.getStringList('widget_habit_ids');
    if (widgetIds != null) {
      _widgetHabitIds = widgetIds.map((s) => int.parse(s)).toList();
    }

    _weekStartDay = prefs.getInt('weekStartDay') ?? 1;
    _showViewModeBottomBar = prefs.getBool('showViewModeBottomBar') ?? true;
    _showCategoryFilter = prefs.getBool('showCategoryFilter') ?? true;
    _showStreakCount = prefs.getBool('showStreakCount') ?? true;
    _showStreakGoal = prefs.getBool('showStreakGoal') ?? true;
    _showMonthLabels = prefs.getBool('showMonthLabels') ?? true;
    _showDayLabels = prefs.getBool('showDayLabels') ?? true;
    _showCategories = prefs.getBool('showCategories') ?? true;
    _legacyPerformanceMode = prefs.getBool('legacyPerformanceMode') ?? true;
    _allowCrashlytics = prefs.getBool('allowCrashlytics') ?? true;

    notifyListeners();
  }

  ThemeMode _parseThemeMode(String themeStr) {
    switch (themeStr) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      case 'system': return ThemeMode.system;
      default: return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: return 'system';
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    notifyListeners(); // Instant UI update
    
    await _repository.updateProfile(profile);

    // Handle check-ins reminders asynchronously
    if (profile.dailyReminderTime != null) {
      final parts = profile.dailyReminderTime!.split(':');
      final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      NotificationService.scheduleDailyCheckIn(time);
    } else {
      NotificationService.cancelDailyCheckIn();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners(); // Instant UI update

    final prefs = await SharedPreferences.getInstance();
    final themeStr = _themeModeToString(mode);
    await prefs.setString('themeMode', themeStr);
    
    if (_profile != null) {
        _profile = _profile!.copyWith(themeMode: themeStr);
        await _repository.updateProfile(_profile!);
    }
  }

  Future<void> setWeekStartDay(int day) async {
    _weekStartDay = day;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('weekStartDay', day);
    notifyListeners();
  }



  Future<void> _setBoolPref(String key, bool value, void Function(bool) updateState) async {
    updateState(value);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> setShowViewModeBottomBar(bool value) => _setBoolPref('showViewModeBottomBar', value, (val) => _showViewModeBottomBar = val);
  Future<void> setShowCategoryFilter(bool value) => _setBoolPref('showCategoryFilter', value, (val) => _showCategoryFilter = val);
  Future<void> setShowStreakCount(bool value) => _setBoolPref('showStreakCount', value, (val) => _showStreakCount = val);
  Future<void> setShowStreakGoal(bool value) => _setBoolPref('showStreakGoal', value, (val) => _showStreakGoal = val);
  Future<void> setShowMonthLabels(bool value) => _setBoolPref('showMonthLabels', value, (val) => _showMonthLabels = val);
  Future<void> setShowDayLabels(bool value) => _setBoolPref('showDayLabels', value, (val) => _showDayLabels = val);
  Future<void> setShowCategories(bool value) => _setBoolPref('showCategories', value, (val) => _showCategories = val);
  Future<void> setLegacyPerformanceMode(bool value) => _setBoolPref('legacyPerformanceMode', value, (val) => _legacyPerformanceMode = val);
  Future<void> setAllowCrashlytics(bool value) => _setBoolPref('allowCrashlytics', value, (val) => _allowCrashlytics = val);

  Future<void> completeOnboarding() async {
      if (_profile != null) {
          await updateProfile(_profile!.copyWith(onboardingComplete: true));
      }
  }

}
