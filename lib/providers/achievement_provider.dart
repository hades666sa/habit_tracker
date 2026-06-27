import 'package:flutter/foundation.dart';
import '../data/models/achievement.dart';
import '../data/repositories/achievement_repository.dart';
import '../utils/streak_calculator.dart';

class AchievementProvider with ChangeNotifier {
  final AchievementRepository _repository = AchievementRepository();
  List<Achievement> _achievements = [];

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => _achievements.where((a) => !a.isUnlocked).toList();

  Future<void> loadAchievements() async {
    _achievements = await _repository.getAll();
    notifyListeners();
  }

  Future<void> checkAchievements(Map<int, Map<String, int>> habitLogs, Map<int, int> targetCounts) async {
    bool updated = false;
    
    // Calculate global stats
    int totalCompletions = 0;
    int maxStreak = 0;
    
    habitLogs.forEach((habitId, logs) {
      final target = targetCounts[habitId] ?? 1;
      
      // Total completions for this habit
      int habitCompletions = 0;
      logs.forEach((date, count) {
        if (count >= target) habitCompletions++;
      });
      totalCompletions += habitCompletions;

      // Max streak for this habit
      final currentStreak = StreakCalculator.currentStreak(logs, target);
      final longestStreak = StreakCalculator.longestStreak(logs, target);
      if (currentStreak > maxStreak) maxStreak = currentStreak;
      if (longestStreak > maxStreak) maxStreak = longestStreak;
    });

    // Check each locked achievement
    for (int i = 0; i < _achievements.length; i++) {
      final ach = _achievements[i];
      if (ach.isUnlocked) continue;

      bool shouldUnlock = false;
      if (ach.category == 'STREAK' && maxStreak >= ach.threshold) {
        shouldUnlock = true;
      } else if (ach.category == 'TOTAL_COMPLETIONS' && totalCompletions >= ach.threshold) {
        shouldUnlock = true;
      }

      if (shouldUnlock) {
        final unlockedAch = ach.copyWith(unlockedAt: DateTime.now().toIso8601String());
        await _repository.update(unlockedAch);
        _achievements[i] = unlockedAch;
        updated = true;
      }
    }

    if (updated) {
      notifyListeners();
    }
  }
}
