import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/habit.dart';
import '../data/models/habit_log.dart';
import '../data/repositories/habit_log_repository.dart';
import '../utils/streak_calculator.dart';
import '../utils/date_utils.dart';

class HabitLogProvider with ChangeNotifier {
  final HabitLogRepository _repository = HabitLogRepository();
  Map<int, Map<String, int>> _habitCompletions = {}; 
  Map<int, int> _habitStreaks = {}; 

  Map<int, Map<String, int>> get habitCompletions => _habitCompletions;

  int getStreak(int habitId) => _habitStreaks[habitId] ?? 0;

  Future<void> loadTodayLogs() async {
    await loadWindowCompletions();
  }

  Future<void> loadWindowCompletions() async {
     final now = DateTime.now();
     // Reduced from 365 days to 30 days to limit memory bloat
     final startStr = AppDateUtils.formatDate(now.subtract(const Duration(days: 30)));
     final endStr = AppDateUtils.formatDate(now.add(const Duration(days: 30)));
     
     final windowLogs = await _repository.getLogsBetweenDates(startStr, endStr);
     
     Map<int, Map<String, int>> newCompletions = {};
     for (var log in windowLogs) {
         if (log.completionsCount > 0) {
             newCompletions.putIfAbsent(log.habitId, () => {})[log.logDate] = log.completionsCount;
         }
     }
     _habitCompletions = newCompletions;
     notifyListeners();
  }

  Future<void> calculateAllStreaks(Map<int, int> habitTargets) async {
    final allCompletedDates = await _repository.getAllCompletedDates(habitTargets);
    
    Map<int, int> newStreaks = {};
    for (var habitId in habitTargets.keys) {
      final completedDates = allCompletedDates[habitId] ?? [];
      newStreaks[habitId] = StreakCalculator.currentStreakFromDates(completedDates);
    }
    _habitStreaks = newStreaks;
    notifyListeners();
  }

  Map<String, int> getCompletionsForHabit(int habitId) {
      return _habitCompletions[habitId] ?? {};
  }

  Future<void> toggleCompletion(int habitId, String date, int targetCount) async {
    final existing = await _repository.getLogForDate(habitId, date);
    int currentCount = existing?.completionsCount ?? 0;
    
    int newCount = currentCount >= targetCount ? 0 : currentCount + 1;
    
    final log = HabitLog(
      habitId: habitId,
      logDate: date,
      completionsCount: newCount,
    );
    
    await _repository.insertOrUpdate(log);
    
    if (newCount > 0) {
      _habitCompletions.putIfAbsent(habitId, () => {})[date] = newCount;
    } else {
      _habitCompletions[habitId]?.remove(date);
      if (_habitCompletions[habitId]?.isEmpty ?? false) {
        _habitCompletions.remove(habitId);
      }
    }
    
    final completedDates = await _repository.getCompletedDatesForHabit(habitId, targetCount);
    _habitStreaks[habitId] = StreakCalculator.currentStreakFromDates(completedDates);
    
    notifyListeners();
    
    notifyListeners();
  }
  
  bool isCompleted(int habitId, String date, int targetCount) {
      final count = _habitCompletions[habitId]?[date] ?? 0;
      return count >= targetCount;
  }
}

