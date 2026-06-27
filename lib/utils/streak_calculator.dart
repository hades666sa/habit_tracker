import 'date_utils.dart';

class StreakCalculator {
  static int currentStreak(Map<String, int> logs, int targetCount) {
    if (logs.isEmpty) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    final todayStr = AppDateUtils.formatDate(today);
    final yesterdayStr = AppDateUtils.formatDate(yesterday);
    
    bool isCompleted(String date) => (logs[date] ?? 0) >= targetCount;

    // Streak breaks if not completed today AND not completed yesterday
    if (!isCompleted(todayStr) && !isCompleted(yesterdayStr)) {
      return 0;
    }
    
    int streak = 0;
    DateTime checkDate = isCompleted(todayStr) ? today : yesterday;
    
    while (isCompleted(AppDateUtils.formatDate(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (streak > 3650) break; // Safety break
    }
    
    return streak;
  }

  static int currentStreakFromDates(List<String> descendingDates) {
    if (descendingDates.isEmpty) return 0;
    
    final now = DateTime.now();
    final todayStr = AppDateUtils.formatDate(now);
    final yesterdayStr = AppDateUtils.formatDate(now.subtract(const Duration(days: 1)));
    
    bool completedToday = descendingDates.contains(todayStr);
    bool completedYesterday = descendingDates.contains(yesterdayStr);
    
    if (!completedToday && !completedYesterday) {
      return 0;
    }
    
    int streak = 0;
    DateTime checkDate = completedToday ? now : now.subtract(const Duration(days: 1));
    
    // Create a Set for fast lookup instead of .contains on list
    final dateSet = descendingDates.toSet();
    
    while (dateSet.contains(AppDateUtils.formatDate(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (streak > 3650) break; // Safety break
    }
    
    return streak;
  }

  static int longestStreak(Map<String, int> logs, int targetCount) {
    if (logs.isEmpty) return 0;
    
    final completedDates = logs.entries
      .where((e) => e.value >= targetCount)
      .map((e) => AppDateUtils.parseDate(e.key))
      .toList()
      ..sort((a, b) => a.compareTo(b));

    if (completedDates.isEmpty) return 0;

    int maxStreak = 0;
    int currentRun = 1;
    
    for (int i = 0; i < completedDates.length - 1; i++) {
      final d1 = DateTime(completedDates[i].year, completedDates[i].month, completedDates[i].day);
      final d2 = DateTime(completedDates[i+1].year, completedDates[i+1].month, completedDates[i+1].day);
        
      if (d2.difference(d1).inDays == 1) {
        currentRun++;
      } else if (d2.difference(d1).inDays > 1) {
        if (currentRun > maxStreak) maxStreak = currentRun;
        currentRun = 1;
      }
    }
    
    if (currentRun > maxStreak) maxStreak = currentRun;
    return maxStreak;
  }

  static bool isCompletedOnDate(Map<String, int> logs, DateTime date, int targetCount) {
    return (logs[AppDateUtils.formatDate(date)] ?? 0) >= targetCount;
  }
}
